#!/usr/bin/env bash
# 标准动词表在 Makefile / conventions.md / skeleton.md 三处出现。
# 不一致就说明文档在骗人 —— conventions.md 自己警告过"重复的两份一定有一份过期"，
# 这个检查就是那条规则的执行者。
set -uo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

M=$(grep -oE '^[a-z-]+:' templates/project-skeleton/Makefile | tr -d ':' | grep -v '^help$' | sort)
strip() { grep -oE '`make [a-z-]+`' "$1" | sed 's/`make //;s/`//' | sort -u | grep -vE '^(seed|migrate|migrate-down)$'; }
C=$(strip skills/engineering-project/references/conventions.md)
S=$(strip skills/engineering-project/references/skeleton.md)

# 防空断言：三者任一为空，说明抓取方式失效了（路径错、格式变了），
# 而不是"它们一致"。没有这一条，这个测试会在什么都没读到时报绿。
for pair in "Makefile:$M" "conventions.md:$C" "skeleton.md:$S"; do
  [ -n "${pair#*:}" ] || { echo "✗ 从 ${pair%%:*} 一个动词都没抓到 —— 抓取方式失效了"; exit 1; }
done

fail=0
[ "$M" = "$C" ] || { echo "✗ Makefile 与 conventions.md 不一致："; diff <(echo "$M") <(echo "$C"); fail=1; }
[ "$M" = "$S" ] || { echo "✗ Makefile 与 skeleton.md 不一致："; diff <(echo "$M") <(echo "$S"); fail=1; }
[ $fail -eq 0 ] && echo "✓ 标准动词三处一致（$(echo "$M" | wc -w) 个）"
exit $fail
