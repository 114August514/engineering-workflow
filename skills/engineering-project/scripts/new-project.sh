#!/usr/bin/env bash
# 从语言无关的骨架建一个新项目，adapter 只决定 stack.mk 里的命令。
set -euo pipefail

# readlink -f 是 GNU 的，macOS 默认没有 —— 用 pwd -P 逐层解析软链
resolve() {
  local t="$1"
  while [ -L "$t" ]; do
    local d; d="$(cd "$(dirname "$t")" && pwd -P)"
    t="$(readlink "$t")"; case "$t" in /*) ;; *) t="$d/$t" ;; esac
  done
  printf '%s/%s\n' "$(cd "$(dirname "$t")" && pwd -P)" "$(basename "$t")"
}
SELF="$(resolve "${BASH_SOURCE[0]}")"
SKILL_DIR="$(dirname "$(dirname "$SELF")")"
TPL="${EW_TEMPLATES:-$(dirname "$(dirname "$SKILL_DIR")")/templates}"

die() { printf '\033[31m错误：\033[0m%s\n' "$*" >&2; exit 1; }

[ -d "$TPL/project-skeleton" ] || die "找不到模板目录：$TPL
用 EW_TEMPLATES 环境变量指定 engineering-workflow/templates 的位置。"

list_adapters() {
  printf '可用的 adapter：\n\n'
  for mk in "$TPL"/adapters/*.mk; do
    [ -e "$mk" ] || continue
    local name desc needs
    name=$(sed -n 's/^# name: *//p' "$mk" | head -1)
    desc=$(sed -n 's/^# desc: *//p' "$mk" | head -1)
    needs=$(sed -n 's/^# needs: *//p' "$mk" | head -1)
    printf '  \033[36m%-14s\033[0m %s\n' "$name" "$desc"
    [ -n "$needs" ] && printf '  %-14s 需要：%s\n' "" "$needs"
  done
  printf '\n骨架本身与语言无关。写一个新 adapter = 填八个变量，见 %s/adapters/\n' "$TPL"
}

usage() {
  cat <<EOF
用法：
  new-project.sh <目标目录> --adapter <名字> [--name <项目名>]
  new-project.sh --list

例：
  new-project.sh ~/Projects/shop --adapter ts-bun
EOF
}

[ $# -eq 0 ] && { usage; exit 1; }
case "$1" in
  --list|-l) list_adapters; exit 0 ;;
  -h|--help) usage; exit 0 ;;
esac

TARGET=""; ADAPTER=""; NAME=""
while [ $# -gt 0 ]; do
  case "$1" in
    --adapter) ADAPTER="${2:-}"; shift 2 ;;
    --name)    NAME="${2:-}";    shift 2 ;;
    -*)        die "未知参数：$1" ;;
    *)         TARGET="$1";      shift ;;
  esac
done

[ -n "$TARGET" ]  || die "要指定目标目录。$(printf '\n')$(usage)"
[ -n "$ADAPTER" ] || die "要指定 --adapter。跑 --list 看有哪些。"
MK="$TPL/adapters/$ADAPTER.mk"
[ -f "$MK" ] || die "没有名为 '$ADAPTER' 的 adapter。跑 --list 看有哪些。"
[ -e "$TARGET" ] && [ -n "$(ls -A "$TARGET" 2>/dev/null)" ] && die "$TARGET 已存在且非空"

NAME="${NAME:-$(basename "$TARGET")}"

mkdir -p "$TARGET"
cp -R "$TPL/project-skeleton/." "$TARGET/"
cp "$MK" "$TARGET/stack.mk"

# CI 里插入这个语言的运行时安装步骤
CI="$TARGET/.github/workflows/ci.yml"
SNIP="$TPL/adapters/$ADAPTER.ci.yml"
if [ -f "$SNIP" ] && [ -f "$CI" ]; then
  awk -v snip="$SNIP" '
    /# \{\{RUNTIME_SETUP\}\}/ { while ((getline line < snip) > 0) print line; next }
    { print }
  ' "$CI" > "$CI.tmp" && mv "$CI.tmp" "$CI"
else
  [ -f "$CI" ] && { sed 's|# {{RUNTIME_SETUP}}|# 在这里加语言运行时的 setup action|' "$CI" > "$CI.tmp" && mv "$CI.tmp" "$CI"; }
fi

# 占位符
grep -rl '{{PROJECT_NAME}}' "$TARGET" 2>/dev/null | while read -r f; do
  sed "s/{{PROJECT_NAME}}/$NAME/g" "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done

# 把 audit/doctor 拷进项目，让生成的项目自包含 ——
# 它不该依赖某个人的 ~/.claude 才能跑 make audit，CI 里也没有那个目录。
mkdir -p "$TARGET/scripts"
cp "$SKILL_DIR/scripts/audit.sh" "$SKILL_DIR/scripts/doctor.sh" "$SKILL_DIR/scripts/review.sh" "$SKILL_DIR/scripts/journal.sh" "$TARGET/scripts/"
chmod +x "$TARGET/scripts/audit.sh" "$TARGET/scripts/doctor.sh" "$TARGET/scripts/review.sh" "$TARGET/scripts/journal.sh"

mkdir -p "$TARGET/src" "$TARGET/tests" "$TARGET/migrations"
mkdir -p "$TARGET/docs/journal"
for d in src tests migrations contracts docs/decisions docs/journal; do
  [ -d "$TARGET/$d" ] && [ -z "$(ls -A "$TARGET/$d")" ] && touch "$TARGET/$d/.gitkeep"
done

# pre-commit：只跑 fmt + lint。跑全量测试的钩子太慢，一定会被 --no-verify 绕过。
mkdir -p "$TARGET/.githooks"
cat > "$TARGET/.githooks/pre-commit" <<'HOOK'
#!/usr/bin/env bash
set -e
make fmt
make lint
HOOK
chmod +x "$TARGET/.githooks/pre-commit"

if command -v git >/dev/null; then
  git -C "$TARGET" init -q
  git -C "$TARGET" config core.hooksPath .githooks
fi

cat <<EOF

  ✓ 建好了：$TARGET
    技术栈：${ADAPTER}（只写在 stack.mk 一个文件里）

  接下来（P3 骨架阶段）：

    cd $TARGET
    make help          # 看有哪些标准动词
    make doctor        # 工程基线还缺什么

  然后按 skill 的 references/skeleton.md 打通第一条端到端链路，
  并且**部署上线**，再开始写业务功能。

  注意：docs/spec.md 和 docs/glossary.md 现在是空模板。
  如果还没过 G1 闸（意图 + 术语表），先回 P0。

EOF
