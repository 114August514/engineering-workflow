#!/usr/bin/env bash
# journal.sh 三项检测的回归测试。每一条都来自一个真实 bug：
#   1. 标题含 % 时 printf 把它当格式串 → 输出错乱并报 invalid format
#   2. slug 含 ../ 能写到 docs/journal 外面，且写失败仍报告成功
#   3. \s 在 BSD sed 上不生效 → 字段解析全废 → 在途/孤儿检测静默失灵
set -uo pipefail
J="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/skills/engineering-project/scripts/journal.sh"
[ -x "$J" ] || { echo "✗ 找不到 journal.sh：$J"; exit 1; }

T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
cd "$T" && git init -q && git config user.name tester

fail=0
ck() { if eval "$2"; then echo "  ✓ $1"; else echo "  ✗ $1"; fail=1; fi; }
# journal.sh 在有悬空副作用时会**故意**非零退出。本脚本开了 pipefail，
# 所以 `"$J" | grep` 会整体判失败 —— 挂的是退出码，不是被断言的行为。
# 先把输出抓进变量，再对变量做断言。
out() { "$J" "$@" 2>&1 || true; }

"$J" --new alpha src/order/ >/dev/null
A=$(ls docs/journal/*alpha.md)
[ -f "$A" ] || { echo "✗ --new 没有产出文件"; exit 1; }
ck "在途条目能被识别（字段解析没坏）" 'out | grep -q "在途 1"'

sed 's/^# .*/# 覆盖率 100% 达成/' "$A" > "$A.t" && mv "$A.t" "$A"
ck "标题含 % 时原样输出"        'out | grep -q "100% 达成"'
ck "标题含 % 时不报 printf 错"  '! out | grep -q "invalid format"'

# 断言拒绝的**理由**，不只是"没成功"。只断言退出码的话，
# 把校验整个删掉、让它靠写入失败来退出，这条测试照样绿 —— 那就是假测试。
ck "含 / 的 slug 被校验拒绝"    'out --new ../escaped | grep -q "slug 不能含"'
ck "以 . 开头的 slug 被拒绝"    'out --new .hidden   | grep -q "slug 不能含"'
ck "拒绝后没留下文件"           '[ ! -e "$T/escaped.md" ] && [ ! -e "$T/../escaped.md" ]'

"$J" --new beta src/pay/ >/dev/null
B=$(ls docs/journal/*beta.md)
touch -d '30 hours ago' "$B" 2>/dev/null || touch -t 202001010000 "$B"
ck "超期条目被判为孤儿锁"       'out | grep -q "孤儿 1"'

# 「无。」后面带解释是人最自然的写法，不能被当成有副作用。
# 这条来自真实使用：写"无。（本次只动代码，没跑迁移）"被误报成悬空副作用。
sed 's|^无。$|无。（本次只动代码和测试，没跑迁移、没部署）|' "$B" > "$B.t" && mv "$B.t" "$B"
ck "「无。」带解释时不误报"        '! out | grep -q "悬空的仓外副作用"'

# 必须写进「## 仓外副作用」那一节里 —— 追加到文件末尾会落在 ## 禁区 段下，
# 那时候脚本不认它才是对的（副作用不在自己的段里就等于没登记）。
sed 's|^无。$|- 在预发库跑了 0007.sql —— 撤销：make migrate-down|' "$A" > "$A.t" && mv "$A.t" "$A"
ck "副作用必须写在自己那一节里" 'grep -A2 "## 仓外副作用" "$A" | grep -q "0007.sql"'
ck "悬空副作用会被报出来"       'out | grep -q "悬空的仓外副作用"'
ck "有悬空副作用时非零退出"     '! "$J" >/dev/null'

[ $fail -eq 0 ] && echo "✓ journal 行为测试全过（11 条）"
exit $fail
