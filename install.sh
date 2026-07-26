#!/usr/bin/env bash
# 把 skill 软链进 ~/.claude/skills/，这样改仓库就等于改 skill。
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

mkdir -p "$DEST"

for src in "$REPO"/skills/*/; do
  name=$(basename "$src")
  target="$DEST/$name"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    printf '  ! %s 已存在且不是软链，跳过。手动处理：%s\n' "$name" "$target"
    continue
  fi
  ln -sfn "${src%/}" "$target"
  printf '  ✓ %s → %s\n' "$name" "$target"
done

cat <<EOF

  装好了。验证：

    ~/.claude/skills/engineering-project/scripts/new-project.sh --list

  templates 通过软链自动解析到 $REPO/templates。
  如果放到了别的地方，设 EW_TEMPLATES 环境变量。

EOF
