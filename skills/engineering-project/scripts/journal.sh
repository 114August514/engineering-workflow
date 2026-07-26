#!/usr/bin/env bash
# 作业日志：谁在做什么、有没有孤儿锁、有没有悬着的仓外副作用。
# 一个条目一个文件（docs/journal/*.md），并行 agent 各写各的，不会冲突。
#
# 用法：
#   journal.sh                       列出在途、孤儿、悬空副作用
#   journal.sh --new <slug> [上下文]  预写一个新条目（先写意图，再动手）
#   journal.sh --all                 连已完成的一起列
set -uo pipefail

DIR="docs/journal"
STALE_HOURS="${JOURNAL_STALE_HOURS:-24}"

field() { sed -n "s/^- *$2：[[:space:]]*//p" "$1" | head -1; }

# ── 预写一个新条目 ──────────────────────────────────────────
if [ "${1:-}" = "--new" ]; then
  SLUG="${2:-}"
  [ -z "$SLUG" ] && { echo "用法：journal.sh --new <slug> [上下文]"; exit 1; }
  case "$SLUG" in
    */*|.*) echo "slug 不能含 / 或以 . 开头（它只是文件名的一部分）"; exit 1 ;;
  esac
  CTX="${3:-未指定}"
  WHO="${JOURNAL_WHO:-$(git config user.name 2>/dev/null || echo unknown)}"
  mkdir -p "$DIR"
  F="$DIR/$(date +%Y-%m-%d-%H%M)-$SLUG.md"
  [ -e "$F" ] && { echo "已存在：$F"; exit 1; }
  if ! cat > "$F" <<EOF
# $SLUG

- 状态：进行中
- 认领：$WHO
- 上下文：$CTX
- 开始：$(date '+%Y-%m-%d %H:%M')

## 意图
<一两句：要达成什么。指向 REQ-ID>

## 预期改动
- <文件路径>

## 仓外副作用
无。
<有的话逐条写，每条都要写怎么撤销；写不出撤销方式 = 需要人点头；已发出的邮件消息不可撤销要标明>

## 回退方式
git revert <commit>

## 验收
make check；测试名含 <REQ-ID>

## 禁区
- 不动 <别的上下文>
- 不动 contracts/、migrations/
- 不加依赖
EOF
  then
    echo "写入失败：$F" >&2; exit 1
  fi
  echo "$F"
  echo
  echo "  预写完成。**先填完这个文件，再动手。**"
  echo "  顺序反过来的话，会话死在半路就什么都没留下。"
  exit 0
fi

# ── 列出 ────────────────────────────────────────────────────
if [ ! -d "$DIR" ]; then
  echo "还没有 $DIR/ —— 用 journal.sh --new <slug> 开第一条。"
  echo "（单人、单会话、十分钟做完的事不用记，见 references/journal.md 第六节）"
  exit 0
fi

shopt -s nullglob 2>/dev/null || true
FILES=("$DIR"/*.md)
[ ${#FILES[@]} -eq 0 ] && { echo "$DIR/ 是空的，当前没有在途工作。"; exit 0; }

NOW=$(date +%s)
INPROG=0; STALE=0; DANGLING=0
OUT_INPROG=""; OUT_STALE=""; OUT_DANG=""; OUT_DONE=""

for f in "${FILES[@]}"; do
  ST=$(field "$f" 状态);  ST="${ST:-未知}"
  WHO=$(field "$f" 认领); CTX=$(field "$f" 上下文)
  TITLE=$(sed -n '1s/^# *//p' "$f")

  # 仓外副作用是**逐条列**的，所以只认列表项（- / * / 1.）。
  # 曾经用"这一行是不是光秃秃的『无。』"来判断 —— 结果人写
  # "无。（本次只动代码，没跑迁移）" 就被当成有副作用。人自然会写理由。
  SIDE=$(awk '/^## 仓外副作用/{f=1;next} /^## /{f=0} f' "$f" \
    | grep -E '^[[:space:]]*([-*]|[0-9]+\.)[[:space:]]+\S' \
    | grep -vE '^[[:space:]]*[-*][[:space:]]*<' || true)

  if [ "$ST" = "进行中" ]; then
    INPROG=$((INPROG+1))
    # GNU 与 BSD 的 stat 参数不同；两个都失败才退回"当前时间"（= 视为不超期）
    MT=$(stat -c %Y "$f" 2>/dev/null || stat -f %m "$f" 2>/dev/null || echo "$NOW")
    AGE=$(( (NOW - MT) / 3600 ))
    LINE="  · $TITLE\n      认领 $WHO · 上下文 ${CTX:-未指定} · ${AGE}h 未动 · $f"
    if [ "$AGE" -ge "$STALE_HOURS" ]; then
      STALE=$((STALE+1)); OUT_STALE="$OUT_STALE$LINE\n"
    else
      OUT_INPROG="$OUT_INPROG$LINE\n"
    fi
  else
    OUT_DONE="$OUT_DONE  · [$ST] $TITLE\n"
  fi

  # 状态不是"已完成"但有仓外副作用 —— 最危险的一类
  if [ -n "$SIDE" ] && [ "$ST" != "已完成" ]; then
    DANGLING=$((DANGLING+1))
    OUT_DANG="$OUT_DANG  · $TITLE  [$ST]  $f\n$(echo "$SIDE" | head -3 | sed 's/^/        /')\n"
  fi
done

printf '\n\033[1m作业日志\033[0m  (%s)\n' "$DIR"

printf '\n\033[1m在途\033[0m（这些就是锁：要动的上下文被占着就别开工）\n'
[ -n "$OUT_INPROG" ] && printf '%b' "$OUT_INPROG" || printf '  无\n'

if [ "$STALE" -gt 0 ]; then
  printf '\n\033[33m孤儿锁\033[0m（超过 %sh 没动，多半是会话死了）\n' "$STALE_HOURS"
  printf '%b' "$OUT_STALE"
  printf '  → 三选一：接着做（改认领人）/ 按「回退方式」回滚（状态改已回退）/\n'
  printf '     放弃（状态改已放弃，未做的部分回到 spec）。**不许直接删条目。**\n'
fi

if [ "$DANGLING" -gt 0 ]; then
  printf '\n\033[31m悬空的仓外副作用\033[0m（状态未完成，但已经动了仓库外的东西）\n'
  printf '%b' "$OUT_DANG"
  printf '  → 这是最危险的一类：git 撤不掉它们。逐条确认是已经撤销了，\n'
  printf '     还是该登记进 docs/runbook.md。\n'
fi

if [ "${1:-}" = "--all" ] && [ -n "$OUT_DONE" ]; then
  printf '\n\033[2m已归档\033[0m\n'; printf '%b' "$OUT_DONE"
fi

printf '\n在途 %d · 孤儿 %d · 悬空副作用 %d\n\n' "$INPROG" "$STALE" "$DANGLING"

# 悬空的仓外副作用是唯一值得非零退出的 —— 其余是信息，不是缺陷
[ "$DANGLING" -gt 0 ] && exit 1
exit 0
