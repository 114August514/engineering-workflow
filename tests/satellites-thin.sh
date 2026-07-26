#!/usr/bin/env bash
# 卫星 skill 的全部价值在于「薄」：精准触发 + 转发，不放内容。
# 一旦壳里开始长内容，就变成了和主 skill 的重复 —— 而无机器检查的重复
# 正是本仓库自己禁止的。这个测试就是那个机器检查。
set -uo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

HUB=skills/engineering-project
MAX_LINES=40
fail=0
n=0

SATS=$(find skills -mindepth 1 -maxdepth 1 -type d ! -name engineering-project | sort)
[ -n "$SATS" ] || { echo "✗ 一个卫星 skill 都没找到 —— 路径失效了"; exit 1; }

for d in $SATS; do
  name=$(basename "$d"); f="$d/SKILL.md"; n=$((n+1))
  [ -f "$f" ] || { echo "  ✗ $name 缺 SKILL.md"; fail=1; continue; }

  # 1. 必须薄
  lines=$(wc -l < "$f")
  [ "$lines" -le "$MAX_LINES" ] \
    && echo "  ✓ $name 薄（$lines 行）" \
    || { echo "  ✗ $name 太厚（$lines 行 > $MAX_LINES）—— 内容该回主 skill 的 references/"; fail=1; }

  # 2. frontmatter 的 name 要和目录名一致，否则装进去会错位
  grep -q "^name: $name$" "$f" \
    || { echo "  ✗ $name 的 frontmatter name 和目录名对不上"; fail=1; }

  # 3. description 要够具体（太短说明没写触发词，精准触发就无从谈起）
  desc=$(sed -n 's/^description: //p' "$f")
  [ "${#desc}" -ge 120 ] \
    || { echo "  ✗ $name 的 description 太短（${#desc} 字符）—— 卫星存在的理由就是精准触发"; fail=1; }

  # 4. 指向的 reference 必须真实存在
  for ref in $(grep -oE 'references/[a-z-]+\.md' "$f" | sort -u); do
    [ -f "$HUB/$ref" ] || { echo "  ✗ $name 指向了不存在的 $ref"; fail=1; }
  done

  # 5. 必须带上三条横切规则，否则只触发卫星时它们就丢了
  grep -q 'always\.md' "$f" \
    || { echo "  ✗ $name 没指向 always.md —— 只触发它时三条横切规则会丢"; fail=1; }
done

# 6. always.md 是唯一事实源：主 skill 不该再内联那三条
grep -q '^1\. \*\*先搜再写\*\*' "$HUB/SKILL.md" \
  && { echo "  ✗ 主 SKILL.md 又内联了三条横切规则 —— 应该只指向 always.md"; fail=1; }

[ $fail -eq 0 ] && echo "✓ $n 个卫星 skill 都是薄壳，指向有效"
exit $fail
