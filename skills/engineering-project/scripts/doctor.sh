#!/usr/bin/env bash
# 工程基线体检。在项目根目录跑。
# 对照 references/skeleton.md 的清单，缺什么就说缺什么、怎么补。
set -uo pipefail

PASS=0; WARN=0; FAIL=0
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; PASS=$((PASS+1)); }
warn() { printf '  \033[33m!\033[0m %s\n     → %s\n' "$1" "$2"; WARN=$((WARN+1)); }
bad()  { printf '  \033[31m✗\033[0m %s\n     → %s\n' "$1" "$2"; FAIL=$((FAIL+1)); }
head_() { printf '\n\033[1m%s\033[0m\n' "$1"; }

printf '\n\033[1m工程基线体检\033[0m  (%s)\n' "$(pwd)"

# ── 版本控制 ────────────────────────────────────────────────
head_ 版本控制
git rev-parse --git-dir >/dev/null 2>&1 && ok "是 git 仓库" || bad "不是 git 仓库" "git init"

if [ -f .gitignore ]; then
  ok ".gitignore 存在"
  grep -qE '^\.env$|^\.env' .gitignore && ok ".env 已被忽略" \
    || bad ".env 没有被 .gitignore 忽略" "立刻加一行 .env"
else
  bad "没有 .gitignore" "从模板拷一份"
fi

if git rev-parse --git-dir >/dev/null 2>&1; then
  if git ls-files --error-unmatch .env >/dev/null 2>&1; then
    bad ".env 已被 git 跟踪" "git rm --cached .env，并且把里面的密钥全部换掉"
  else
    ok ".env 没进仓库"
  fi
  if git log --all --oneline -- .env 2>/dev/null | grep -q .; then
    bad ".env 出现在历史提交里" "当作已泄露：轮换所有密钥"
  fi
fi

# ── 标准动词 ────────────────────────────────────────────────
head_ "标准动词（make 接口）"
if [ -f Makefile ]; then
  ok "Makefile 存在"
  for v in setup dev fmt fmt-check lint typecheck test check build ship; do
    grep -qE "^$v:" Makefile && ok "make $v" \
      || bad "缺 make $v" "见 references/conventions.md 的动词表"
  done
else
  bad "没有 Makefile" "标准动词接口是这套规范的核心，从模板拷一份"
fi
[ -f stack.mk ] && ok "stack.mk 存在（语言相关命令都在这里）" \
  || warn "没有 stack.mk" "从 templates/adapters/ 拷一个，或把命令直接写进 Makefile"

# ── 质量闸 ──────────────────────────────────────────────────
head_ 质量闸
FMT_CFG=$(ls .prettierrc* biome.json* .rustfmt.toml rustfmt.toml ruff.toml pyproject.toml setup.cfg 2>/dev/null | head -1)
[ -n "$FMT_CFG" ] && ok "格式化配置：$FMT_CFG" || warn "没找到格式化配置" "配一个格式化器，让格式问题永远不进人的评审视野"

LINT_CFG=$(ls .eslintrc* eslint.config.* biome.json* .golangci.y*ml ruff.toml 2>/dev/null | head -1)
[ -n "$LINT_CFG" ] && ok "lint 配置：$LINT_CFG" || warn "没找到 lint 配置" "配一个 linter"

HOOKS=$(git config core.hooksPath 2>/dev/null || echo .git/hooks)
if [ -x "$HOOKS/pre-commit" ]; then
  ok "pre-commit 钩子已启用"
  grep -q 'make test\|make check' "$HOOKS/pre-commit" 2>/dev/null \
    && warn "钩子里跑了全量测试" "太慢的钩子会被 --no-verify 绕过。只跑 fmt + lint"
else
  warn "没有 pre-commit 钩子" "加一个只跑 make fmt + make lint 的钩子"
fi

# ── 测试 ────────────────────────────────────────────────────
head_ 测试
TESTS=$(find . -path ./node_modules -prune -o -path ./.git -prune -o \
  \( -name '*test*' -o -name '*spec*' \) -type f -print 2>/dev/null | grep -cE '\.(ts|js|py|rs|go)$' || true)
if [ "${TESTS:-0}" -gt 0 ]; then
  ok "找到 $TESTS 个测试文件"
  SKIPPED=$(grep -rlE '\b(it|test|describe)\.(skip|todo)|@pytest\.mark\.skip|#\[ignore\]|t\.Skip' \
    --include='*.ts' --include='*.js' --include='*.py' --include='*.rs' --include='*.go' . 2>/dev/null \
    | grep -v node_modules | head -5 || true)
  [ -n "$SKIPPED" ] && bad "有被 skip 的测试" "$(echo "$SKIPPED" | tr '\n' ' ')—— skip 掉的测试等于没有" \
    || ok "没有被 skip 的测试"
else
  bad "一个测试文件都没有" "至少要有一条真在断言行为的测试才算过 G3"
fi

# ── CI ──────────────────────────────────────────────────────
head_ CI
CI=$(ls .github/workflows/*.y*ml .gitlab-ci.yml 2>/dev/null | head -1)
if [ -n "$CI" ]; then
  ok "CI 配置：$CI"
  grep -q 'make check' "$CI" && ok "CI 跑的是 make check" \
    || warn "CI 没有跑 make check" "CI 和本地必须跑同一条命令，否则迟早不一致"
else
  bad "没有 CI 配置" "没有 CI 的话，闸门全靠人自觉"
fi

# ── 配置与密钥 ──────────────────────────────────────────────
head_ 配置与密钥
if [ -f .env.example ]; then
  ok ".env.example 存在"
  LEAK=$(grep -vE '^\s*#|^\s*$' .env.example 2>/dev/null \
    | grep -E '=(.{24,})' | grep -viE '=(postgres|mysql|redis|http|example|changeme|your)' || true)
  [ -n "$LEAK" ] && bad ".env.example 里可能有真实值" "只留键名和格式示例" || ok ".env.example 没有真实值"
else
  bad "没有 .env.example" "别人和 AI 都不知道要配哪些环境变量"
fi

# ── 文档 ────────────────────────────────────────────────────
head_ 文档
for f in README.md AGENTS.md docs/spec.md docs/glossary.md docs/runbook.md; do
  [ -f "$f" ] && ok "$f" || warn "缺 $f" "见 references/conventions.md 的目录约定"
done
[ -d docs/decisions ] && ok "docs/decisions/（ADR）" || warn "缺 docs/decisions/" "决策不留痕，AI 三周后会顺手改掉你的设计"
[ -f LICENSE ] && ok "LICENSE" || warn "缺 LICENSE" ""

if [ -f docs/spec.md ]; then
  # 模板占位符不算数：'不做 ……' 和 REQ-XXX-001 都是没填的样子
  NONGOALS=$(grep -cE '^\s*-\s*不做\s*\S' docs/spec.md 2>/dev/null | tr -d ' ')
  NONGOALS_REAL=$(grep -E '^\s*-\s*不做' docs/spec.md 2>/dev/null | grep -vcE '……|\.\.\.|＜|<' | tr -d ' ')
  if [ "${NONGOALS_REAL:-0}" -ge 5 ]; then
    ok "spec 写了 $NONGOALS_REAL 条非目标"
  elif [ "${NONGOALS_REAL:-0}" -gt 0 ]; then
    warn "非目标只有 $NONGOALS_REAL 条" "至少写五条——它是用来挡住 AI 和你自己的护栏"
  else
    bad "spec 的非目标还是空模板" "空的非目标 = 范围会在实现中无声膨胀"
  fi

  REQS=$(grep -oE 'REQ-[A-Z]+-[0-9]+' docs/spec.md 2>/dev/null | grep -v 'REQ-XXX-' | sort -u | wc -l)
  if [ "${REQS:-0}" -gt 0 ]; then
    ok "spec 里有 $REQS 条 REQ-ID"
    grep -qE '例：\s*\S' docs/spec.md && ok "验收标准配了具体例子" \
      || warn "验收标准没有配例子" "抽象描述会被各自解读，具体例子不会"
  else
    bad "spec 里还没有真的 REQ-ID（只有模板占位符）" "没有 ID 就做不了 spec↔测试 的漂移检查，见 references/intake.md"
  fi
fi

# ── 汇总 ────────────────────────────────────────────────────
printf '\n\033[1m%s\033[0m  \033[32m通过 %d\033[0m  \033[33m警告 %d\033[0m  \033[31m未过 %d\033[0m\n\n' \
  汇总 "$PASS" "$WARN" "$FAIL"

if [ "$FAIL" -gt 0 ]; then
  printf '  \033[31m还不能过 G3 骨架闸。\033[0m先补上标红的项。\n\n'
  exit 1
fi
printf '  基线齐了。G3 闸还需要人**亲手**做三件事：\n'
printf '    1. 干净目录 clone 后 make setup && make dev 能起来\n'
printf '    2. make check 全绿\n'
printf '    3. 打开部署出来的 URL，骨架链路能走通\n\n'
