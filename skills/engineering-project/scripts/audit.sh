#!/usr/bin/env bash
# 生成"待人审清单"：自动标出必审项，让人的十五分钟花在刀刃上。
# 输出是 markdown，可以直接贴进 PR 或 $GITHUB_STEP_SUMMARY。
#
# 用法：audit.sh [--base <ref>] [--max-lines N]
set -uo pipefail

BASE=""; MAX_LINES="${AUDIT_MAX_LINES:-400}"
while [ $# -gt 0 ]; do
  case "$1" in
    --base)      BASE="${2:-}";      shift 2 ;;
    --max-lines) MAX_LINES="${2:-}"; shift 2 ;;
    *) shift ;;
  esac
done

git rev-parse --git-dir >/dev/null 2>&1 || { echo "不是 git 仓库"; exit 1; }

if [ -z "$BASE" ]; then
  for c in origin/main origin/master main master; do
    git rev-parse --verify -q "$c" >/dev/null && { BASE="$c"; break; }
  done
  [ -z "$BASE" ] && BASE="HEAD~1"
fi
git rev-parse --verify -q "$BASE" >/dev/null || { echo "找不到基线 $BASE"; exit 1; }

FILES=$(git diff --name-only "$BASE"...HEAD 2>/dev/null || git diff --name-only "$BASE")
[ -z "$FILES" ] && { echo "## 待审清单"; echo; echo "相对 \`$BASE\` 没有改动。"; exit 0; }

ADDED=$(git diff -U0 "$BASE"...HEAD 2>/dev/null | grep '^+' | grep -v '^+++' || true)
STAT=$(git diff --shortstat "$BASE"...HEAD 2>/dev/null)
NLINES=$(git diff --numstat "$BASE"...HEAD 2>/dev/null \
  | grep -vE '(lock|sum)$|\.lock|package-lock|\.generated\.' \
  | awk '{a+=$1; d+=$2} END {print a+d+0}')

BLOCK=0
echo "## 待人审清单"
echo
echo "基线 \`$BASE\` · $STAT"
echo

# ── 🔴 必审 ──────────────────────────────────────────────────
echo "### 🔴 必审（不可逆或有放大效应）"
echo
FOUND=0
flag() { echo "- **$1** — $2"; FOUND=1; BLOCK=1; }

echo "$FILES" | grep -qE '^contracts/'   && flag "对外契约变更" "逐字看：字段必填与单位、**错误路径**、破坏性变更是否三步走"
echo "$FILES" | grep -qE '^migrations/'  && flag "数据库迁移" "\`down\` 实际跑过吗？破坏性变更是否向前兼容一个版本？"
echo "$FILES" | grep -qiE 'auth|login|permission|role|token|session|password|jwt' \
  && flag "认证/授权相关" "越权能不能拿到别人的数据？有没有'忘了检查'的路径？"
echo "$FILES" | grep -qiE 'package\.json|requirements|pyproject|Cargo\.toml|go\.mod|Gemfile' \
  && flag "依赖清单变更" "维护状态 / 许可证 / 间接依赖 / 自己写 50 行能不能替代"
echo "$FILES" | grep -qiE 'payment|billing|invoice|refund|price|amount|charge' \
  && flag "涉及钱的代码" "金额精度与舍入、幂等、并发下的重复扣款"
echo "$FILES" | grep -qiE '\.env|secret|credential|\.pem$|\.key$' \
  && flag "密钥/配置边界" "有没有真实值进仓库？日志会不会打出来？"
echo "$FILES" | grep -qE '^docs/decisions/' && flag "架构决策(ADR)" "后果和反悔成本写清楚了吗？有没有引入需求没要求的复杂度？"
[ "$FOUND" -eq 0 ] && echo "- 无。这次没碰不可逆的东西。"
echo

# 契约与实现混在一起 —— 混着就审不动了
if echo "$FILES" | grep -qE '^(contracts|migrations)/' \
   && [ "$(echo "$FILES" | grep -cvE '^(contracts|migrations|docs)/')" -gt 3 ]; then
  echo "> ⚠️ **契约/迁移和实现代码混在同一批改动里。** 契约的 diff 恰恰是最该被"
  echo "> 认真看的部分，埋在几百行实现里就会被跳过。拆成两个提交。"
  echo
  BLOCK=1
fi

# ── 尺寸 ────────────────────────────────────────────────────
echo "### 规模"
echo
if [ "${NLINES:-0}" -gt "$MAX_LINES" ]; then
  echo "- ⚠️ **$NLINES 行（上限 $MAX_LINES）**。超过这个体积，评审会从"
  echo "  逐行看退化成扫一眼点同意——闸门就失效了。先拆出纯机械改动"
  echo "  （重命名、移动文件、格式化）单独一个提交，还超就是切片切大了。"
  BLOCK=1
else
  echo "- ✓ $NLINES 行（上限 $MAX_LINES）"
fi
echo

# ── 🟡 自动扫出来的可疑点 ────────────────────────────────────
echo "### 🟡 新增代码里的可疑点"
echo
SUS=0
sus() { echo "- **$1**"; echo '  ```'; echo "$2" | head -5 | sed 's/^/  /'; echo '  ```'; SUS=1; }

M=$(echo "$ADDED" | grep -E '\b(it|test|describe)\.(skip|todo)|@pytest\.mark\.skip|#\[ignore\]|t\.Skip' || true)
[ -n "$M" ] && { sus "被 skip 的测试 —— 测试红了是代码错了，不是测试该被关掉" "$M"; BLOCK=1; }

M=$(echo "$ADDED" | grep -E 'catch[[:space:]]*\([^)]*\)[[:space:]]*\{[[:space:]]*\}|except.*:[[:space:]]*pass|catch[[:space:]]*\{[[:space:]]*\}' || true)
[ -n "$M" ] && sus "吞掉的异常 —— 故障会在几层之后以更难懂的方式爆出来" "$M"

M=$(echo "$ADDED" | grep -E 'https?://(localhost|127\.0\.0\.1|[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)' || true)
[ -n "$M" ] && sus "硬编码地址 —— 配置该从环境变量读" "$M"

M=$(echo "$ADDED" | grep -iE '(password|token|secret|api_?key)[[:space:]]*[=:][[:space:]]*["'"'"'][^"'"'"']{8,}' || true)
[ -n "$M" ] && { sus "疑似硬编码密钥" "$M"; BLOCK=1; }

M=$(echo "$ADDED" | grep -iE 'log.*\b(password|token|secret|id_?card|phone)\b' || true)
[ -n "$M" ] && { sus "日志里可能有敏感信息" "$M"; BLOCK=1; }

M=$(echo "$ADDED" | grep -E ':[[:space:]]*any\b|as any\b' || true)
[ -n "$M" ] && sus "逃逸的类型 —— any 会让类型检查在这里失效" "$M"

M=$(echo "$ADDED" | grep -E 'onClick|onclick' | grep -E '<div|<span' || true)
[ -n "$M" ] && sus "能点的 div —— 键盘用不了，测试也找不到它。用 button" "$M"

DELTEST=$(git diff "$BASE"...HEAD -- '*test*' '*spec*' 2>/dev/null \
  | grep '^-' | grep -v '^---' | grep -E 'assert|expect|should' || true)
[ -n "$DELTEST" ] && { sus "删掉或改动了已有断言 —— 是需求真的变了（那 spec 也该变），还是为了让新代码过？" "$DELTEST"; BLOCK=1; }

[ "$SUS" -eq 0 ] && echo "- 无。"
echo

# ── spec ↔ 测试 漂移 ────────────────────────────────────────
if [ -f docs/spec.md ]; then
  echo "### spec ↔ 测试 追溯"
  echo
  # REQ-XXX-* 是模板占位符，不参与追溯
  SPEC_IDS=$(grep -oE 'REQ-[A-Z]+-[0-9]+' docs/spec.md | grep -v '^REQ-XXX-' | sort -u)
  if [ -z "$SPEC_IDS" ]; then
    echo "- spec 里没有 REQ-ID（或只有模板占位符），无法做追溯。见 \`references/intake.md\`。"
  else
    ORPHAN_REQ=""
    for id in $SPEC_IDS; do
      git grep -qF "$id" -- ':(exclude)docs/' >/dev/null 2>&1 || ORPHAN_REQ="$ORPHAN_REQ $id"
    done
    CODE_IDS=$(git grep -hoE 'REQ-[A-Z]+-[0-9]+' -- ':(exclude)docs/' 2>/dev/null | grep -v '^REQ-XXX-' | sort -u)
    ORPHAN_TEST=""
    for id in $CODE_IDS; do
      echo "$SPEC_IDS" | grep -qxF "$id" || ORPHAN_TEST="$ORPHAN_TEST $id"
    done

    if [ -n "$ORPHAN_REQ" ]; then
      echo "- ⚠️ **孤儿需求**（spec 里有，代码/测试里搜不到）：\`$(echo $ORPHAN_REQ)\`"
      echo "  → 要么还没做，要么做了没测。"
      BLOCK=1
    else
      echo "- ✓ 每条 REQ 都能在代码/测试里找到"
    fi
    [ -n "$ORPHAN_TEST" ] && {
      echo "- ⚠️ **孤儿测试**（代码里引用了 spec 里不存在的 ID）：\`$(echo $ORPHAN_TEST)\`"
      echo "  → spec 过期了，或者在做范围外的事。"
      BLOCK=1
    }
  fi
  echo
fi

# ── 人还是得自己做的 ────────────────────────────────────────
cat <<'EOF'
### 脚本查不了、必须人做的

- [ ] **自己跑一次 `make check`** —— 不要信 AI 贴的输出
- [ ] **把实现改坏，看测试红不红** —— 没红的测试是假的
- [ ] spec 里每条"如果……那么……"，测试里搜得到吗
- [ ] `git diff --stat` 对照任务卡的**禁区**，有没有越界
- [ ] AI 汇报里"没做什么"和"哪里不确定"那两段，看了吗

EOF

if [ "$BLOCK" -eq 1 ]; then
  echo "---"
  echo
  echo "**有标红项，先处理再合。**"
  exit 1
fi
echo "---"
echo
echo "自动检查没发现问题。人工那几项还是要做。"
