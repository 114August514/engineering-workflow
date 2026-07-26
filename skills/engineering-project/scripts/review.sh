#!/usr/bin/env bash
# 里程碑复盘的机器部分：全仓库扫描，把能机器查的查掉，
# 人的 30 分钟留给判断（见 references/review.md 第六节的八条）。
#
# 和 audit.sh 的区别：audit 是**增量**的（一次改动，每个 PR 跑），
# 这个是**全量**的（整个仓库，阶段结束时跑）。
#
# 用法：review.sh [--since <ref>]   # --since 给出"上次复盘以来"的对比基线
set -uo pipefail

SINCE=""
[ "${1:-}" = "--since" ] && SINCE="${2:-}"

SRC=$([ -d src ] && echo src || echo .)
EX='node_modules|/.git/|/dist/|/build/|/target/|/.venv/|/vendor/'
FLAG=0
note() { echo "- $1"; }
warn() { echo "- ⚠️ $1"; FLAG=1; }

echo "# 里程碑复盘：机器部分"
echo
echo "生成于 \`$(git rev-parse --short HEAD 2>/dev/null || echo '尚无提交')\`"
[ -n "$SINCE" ] && echo "对比基线：\`$SINCE\`"
echo
echo "> 这份只覆盖能机器查的。\`references/review.md\` 第六节那八条里，"
echo "> 第 1、5、8 条（spec 还成立吗 / 技术债登记了吗 / 下阶段最大风险）"
echo "> **必须人看**，脚本查不了。"
echo

# ── 1. 架构侵蚀：domain 层被 IO 污染 ─────────────────────────
echo "## 架构侵蚀"
echo
DOMDIRS=$(find "$SRC" -type d -name domain 2>/dev/null | grep -vE "$EX" || true)
if [ -z "$DOMDIRS" ]; then
  note "没有 \`*/domain/\` 目录，跳过（如果项目本来就没分层，忽略这条）"
else
  DIRTY=""
  for d in $DOMDIRS; do
    HIT=$(grep -rlnE '\b(import|require|use|from)\b.*(sqlx|sqlalchemy|psycopg|prisma|mongoose|knex|diesel|axios|fetch\(|requests|reqwest|http\.|express|fastapi|fs\.|os\.path|open\()' \
      "$d" 2>/dev/null | grep -vE "$EX" || true)
    [ -n "$HIT" ] && DIRTY="$DIRTY $HIT"
  done
  if [ -n "$DIRTY" ]; then
    warn "**domain 层出现了 IO 调用** —— 依赖方向朝内这条被破坏了："
    for f in $DIRTY; do echo "  - \`$f\`"; done
    echo "  → 领域层一旦碰 IO，就没法再用纯单元测试密集覆盖。见 \`backend.md\` 第一节。"
  else
    note "✓ domain 层干净，没有直接的 IO 调用"
  fi

  # 上下文之间直连（A 的代码 import 了 B 的 infra/domain 内部）
  CTXS=$(find "$SRC" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | grep -vE "$EX" | sed 's|.*/||' || true)
  CROSS=""
  for c in $CTXS; do
    for other in $CTXS; do
      [ "$c" = "$other" ] && continue
      H=$(grep -rlE "$other/(domain|infra)/" "$SRC/$c" 2>/dev/null | grep -vE "$EX" || true)
      [ -n "$H" ] && CROSS="$CROSS $c→$other"
    done
  done
  [ -n "$CROSS" ] && warn "**上下文之间直连内部实现**：$CROSS —— 跨上下文只能走明确接口" \
    || note "✓ 上下文之间没有直接引用对方内部"
fi
echo

# ── 2. 术语漂移 ─────────────────────────────────────────────
echo "## 术语漂移"
echo
if [ -f docs/glossary.md ]; then
  IDS=$(grep -oE '\| *`[A-Za-z_][A-Za-z0-9_]*` *\|' docs/glossary.md 2>/dev/null \
    | tr -d '|` ' | sort -u || true)
  if [ -z "$IDS" ]; then
    warn "术语表里没有「代码标识」列 —— 没有它就没法查漂移，见 \`domain.md\`"
  else
    UNUSED=""
    for id in $IDS; do
      grep -rqE "\b$id\b" "$SRC" --include='*.*' 2>/dev/null || UNUSED="$UNUSED $id"
    done
    [ -n "$UNUSED" ] && warn "**术语表里有、代码里找不到**：\`$(echo $UNUSED)\` → 术语表过期了，或者这些概念没实现" \
      || note "✓ 术语表里的每个标识都在代码里出现了"
    note "术语表共 $(echo "$IDS" | wc -w) 个概念"
    echo
    echo "  > 反方向（代码里有、术语表里没有的**核心**名词）机器判不了——"
    echo "  > 人扫一遍 \`$SRC\` 里的主要类型/表名，看有没有没进术语表的。"
  fi
else
  warn "没有 \`docs/glossary.md\` —— 没有通用语言，命名迟早分叉"
fi
echo

# ── 3. 测试还可信吗 ─────────────────────────────────────────
echo "## 测试可信度"
echo
SKIP=$(grep -rnE '\b(it|test|describe)\.(skip|todo)|@pytest\.mark\.skip|#\[ignore\]|t\.Skip' \
  . --include='*.ts' --include='*.tsx' --include='*.js' --include='*.py' --include='*.rs' --include='*.go' 2>/dev/null \
  | grep -vE "$EX" || true)
NSKIP=$(echo "$SKIP" | grep -c . || true)
if [ "${NSKIP:-0}" -gt 0 ]; then
  warn "**$NSKIP 处被 skip 的测试** —— skip 掉的测试等于没有，而且会一直假装存在"
  echo "$SKIP" | head -8 | sed 's/^/  - `/;s/$/`/'
else
  note "✓ 没有被 skip 的测试"
fi

if [ -f docs/spec.md ]; then
  NIF=$(grep -cE '如果.*那么|^[[:space:]]*-[[:space:]]*\*\*REQ-[A-Z]+-[0-9]+\*\*[[:space:]]*如果' docs/spec.md 2>/dev/null || echo 0)
  note "spec 里的异常路径（「如果……那么……」）：$NIF 条"
  [ "${NIF:-0}" -eq 0 ] && warn "一条异常路径都没有 —— 每三条正常路径至少该配一条，见 \`intake.md\`"
fi
echo

# ── 4. spec ↔ 测试 全量追溯 ─────────────────────────────────
echo "## spec ↔ 测试 全量追溯"
echo
if [ -f docs/spec.md ] && git rev-parse --git-dir >/dev/null 2>&1; then
  SPEC_IDS=$(grep -oE 'REQ-[A-Z]+-[0-9]+' docs/spec.md | grep -v '^REQ-XXX-' | sort -u)
  if [ -z "$SPEC_IDS" ]; then
    warn "spec 里没有真的 REQ-ID，做不了追溯"
  else
    ORPH=""
    for id in $SPEC_IDS; do
      git grep -qF "$id" -- ':(exclude)docs/' >/dev/null 2>&1 || ORPH="$ORPH $id"
    done
    TOTAL=$(echo "$SPEC_IDS" | wc -w); NORPH=$(echo $ORPH | wc -w)
    if [ "${NORPH:-0}" -gt 0 ]; then
      warn "**$NORPH/$TOTAL 条需求没有对应的代码或测试**：\`$(echo $ORPH)\`"
    else
      note "✓ $TOTAL 条需求全部能追溯到代码/测试"
    fi
  fi
else
  note "没有 \`docs/spec.md\`，跳过"
fi
echo

# ── 5. 边界是否变糊：大文件 ─────────────────────────────────
echo "## 文件规模"
echo
BIG=$(find "$SRC" -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.py' -o -name '*.rs' -o -name '*.go' -o -name '*.js' \) 2>/dev/null \
  | grep -vE "$EX" | while IFS= read -r bf; do wc -l "$bf" 2>/dev/null; done \
  | awk '$1 > 400 && $2 != "total" {print $1" "$2}' | sort -rn || true)
if [ -n "$BIG" ]; then
  warn "**超过 400 行的文件** —— 通常意味着一个文件在做不止一件事，"
  echo "  也意味着 AI 每次改它都要吞掉整个文件的上下文，编辑可靠性会下降："
  echo "$BIG" | head -8 | sed 's/^\([0-9]*\) \(.*\)/  - `\2` （\1 行）/'
else
  note "✓ 没有超过 400 行的源文件"
fi
echo

# ── 6. 过度设计信号 ─────────────────────────────────────────
# 只查机械上能确定的那一条：定义了但没人用的配置项。
# 「只有一个实现的接口」「为想象中的故障写的防御」需要判断，
# 机器查会大量误报 —— 那本身就是 proportion.md 反对的做法。
echo "## 过度设计信号"
echo
if [ -f .env.example ]; then
  KEYS=$(grep -vE '^[[:space:]]*#|^[[:space:]]*$' .env.example 2>/dev/null | cut -d= -f1 | tr -d ' ' || true)
  UNUSEDK=""
  for k in $KEYS; do
    grep -rqF "$k" "$SRC" 2>/dev/null || UNUSEDK="$UNUSEDK $k"
  done
  if [ -n "$UNUSEDK" ]; then
    warn "**配置项定义了但代码里找不到**：\`$(echo $UNUSEDK)\`"
    echo "  → 没人用的配置项不是配置，是伪装成配置的常量。删掉，或者说明谁在用。"
  else
    note "✓ \`.env.example\` 里的每个键都在代码里用到了"
  fi
else
  note "没有 \`.env.example\`，跳过"
fi
echo
echo "  > 其余的过度设计信号（只有一个实现的接口、只调用一次的「通用」函数、"
echo "  > 为没发生过的故障写的防御）**要人判断**，见 \`proportion.md\` 第三节。"
echo "  > 一句话判据：删掉这层，代码会变短吗？会变难懂吗？"
echo

# ── 7. 技术债信号 ───────────────────────────────────────────
echo "## 技术债信号"
echo
TODO=$(grep -rnE '\b(TODO|FIXME|HACK)\b' "$SRC" 2>/dev/null | grep -vE "$EX" | grep -v 'REQ-XXX' | grep -v "$(basename "$0")" || true)
NTODO=$(echo "$TODO" | grep -c . || true)
if [ "${NTODO:-0}" -gt 0 ]; then
  note "代码里 $NTODO 处 TODO/FIXME/HACK"
  echo "$TODO" | head -6 | sed 's/^/  - `/;s/$/`/'
  echo "  > 这些是**没登记的技术债**。复盘时的动作：要么现在修，"
  echo "  > 要么变成一条真任务，要么删掉——不要让它们一直挂着假装被记着。"
else
  note "✓ 代码里没有游离的 TODO/FIXME"
fi
echo

# ── 8. 依赖膨胀 ─────────────────────────────────────────────
echo "## 依赖"
echo
count_deps() {
  [ -f package.json ] && node -e 'const p=require("./package.json");console.log(Object.keys({...p.dependencies,...p.devDependencies}||{}).length)' 2>/dev/null && return
  [ -f pyproject.toml ] && grep -cE '^[[:space:]]*"[a-zA-Z]' pyproject.toml 2>/dev/null && return
  [ -f Cargo.toml ] && awk '/^\[dependencies\]/{f=1;next}/^\[/{f=0}f&&/=/{n++}END{print n+0}' Cargo.toml && return
  [ -f go.mod ] && grep -c '^[[:space:]]*[a-z].*v[0-9]' go.mod 2>/dev/null && return
  echo ""
}
NDEP=$(count_deps)
[ -n "$NDEP" ] && note "直接依赖：$NDEP 个" || note "认不出依赖清单格式，人工看一眼"
if [ -n "$SINCE" ] && git rev-parse --verify -q "$SINCE" >/dev/null 2>&1; then
  DEPDIFF=$(git diff --stat "$SINCE"...HEAD -- package.json pyproject.toml Cargo.toml go.mod 2>/dev/null || true)
  [ -n "$DEPDIFF" ] && warn "**自 \`$SINCE\` 以来依赖清单动过**，逐个过一遍准入五问（见 \`architecture.md\`）：$(echo "$DEPDIFF" | tail -1)"
fi
echo

# ── 9. 文档过期 ─────────────────────────────────────────────
echo "## 文档新鲜度"
echo
if [ -f docs/runbook.md ]; then
  LAST=$(grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' docs/runbook.md 2>/dev/null | sort -r | head -1)
  if [ -n "$LAST" ]; then
    # GNU: date -d ；BSD/macOS: date -j -f
    LASTS=$(date -d "$LAST" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$LAST" +%s 2>/dev/null || echo "")
    if [ -z "$LASTS" ]; then DAYS=""; else DAYS=$(( ( $(date +%s) - LASTS ) / 86400 )); fi
    if [ -z "$DAYS" ]; then
      note "runbook 里有日期 $LAST，但这台机器的 date 解析不了，跳过新鲜度检查"
    elif [ "$DAYS" -gt 90 ]; then
      warn "**runbook 里最近的演练日期是 $LAST（$DAYS 天前）** —— 回滚和恢复演练该重做了"
    else
      note "✓ runbook 最近演练：$LAST（$DAYS 天前）"
    fi
  else
    warn "runbook 里没有演练日期 —— **没演练过的回滚方案等于没有**（\`delivery.md\`）"
  fi
else
  warn "没有 \`docs/runbook.md\`"
fi
NADR=$(ls docs/decisions/*.md 2>/dev/null | grep -vc '0000-template' || echo 0)
note "ADR 数量：$NADR"
[ "${NADR:-0}" -eq 0 ] && warn "一份 ADR 都没有 —— 那些选型决定的理由现在只存在于某次对话里"
echo

# ── 收尾 ────────────────────────────────────────────────────
echo "---"
echo
if [ "$FLAG" -eq 1 ]; then
  echo "**有标 ⚠️ 的项。** 复盘的产出应该是：一段记录 + 若干条新任务 +"
  echo "可能一份新 ADR（如果发现某个原始决策已经不成立）。"
else
  echo "机器部分没查出问题。"
fi
echo
echo "还得人自己看的三条（\`review.md\` 第六节）："
echo
echo "1. **spec 还成立吗** —— 非目标被突破了吗？验收标准和实际行为对得上吗"
echo "2. **技术债登记了吗** —— 这段时间口头说过的「以后再说」，写下来了吗"
echo "3. **下一阶段最大的风险是什么** —— 对照 \`architecture.md\` 的风险表重排一次"
echo
echo "复盘至少要产出一条改动。八条全是「没问题」，通常意味着看得不够仔细。"
