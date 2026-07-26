#!/usr/bin/env bash
# audit.sh 的 spec↔测试 追溯。这是整套流程里最容易给出**虚假安全感**的机制：
# 它一旦在该报的时候报绿，人就会以为需求和测试还对得上。
#
# 三条都来自实测复现的漏洞：
#   1. spec 里的 REQ 被删光时，孤儿测试检测曾经写在 else 分支里 → 追溯静默关闭
#   2. REQ-ID 不变、内容 180 度反转（拒绝→转预售），测试没动 → 曾经报 ✓
#   3. 需求变更经常只动「例：」那一行，REQ 标题一个字不变
#      → 只找"含 REQ-ID 的变更行"抓不到，必须把变更行归属到所属 REQ 块
set -uo pipefail
A="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/skills/engineering-project/scripts/audit.sh"
[ -x "$A" ] || { echo "✗ 找不到 audit.sh：$A"; exit 1; }

T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
cd "$T" && git init -q && git config user.name t && git config user.email t@e

mkdir -p docs tests
cat > docs/spec.md <<'SPEC'
# 测试项目

## 验收标准

### 订单
- **REQ-ORD-001** 当用户提交订单时，系统应当在库存不足时拒绝
  - 例：库存 2，提交 3 → 409
SPEC
cat > tests/order_test.txt <<'T2'
// REQ-ORD-001 库存不足时拒绝
func TestReject() { assertEqual(place(3,2), 409) }
T2
git add -A && git commit -qm base
BASE=$(git rev-parse HEAD)

fail=0
ck() { if eval "$2"; then echo "  ✓ $1"; else echo "  ✗ $1"; fail=1; fi; }
run() { "$A" --base "$BASE" 2>&1 || true; }   # audit.sh 有标红项时非零退出；
                                              # pipefail 下裸管道会挂在退出码上
reset() { git reset -q --hard "$BASE"; }

# ── 1. 只改「例」那一行，测试没动 → 必须报 ─────────────────
sed 's|→ 409|→ 201 且状态=预售|' docs/spec.md > s.t && mv s.t docs/spec.md
git commit -qam "需求变了，测试没跟"
ck "只改「例」也算需求变更，会被报出来" 'run | grep -q "需求改了，但引用它的测试/代码这次没动"'
ck "该情况会挡住合并（非零退出）"        '! "$A" --base "$BASE" >/dev/null 2>&1'
reset

# ── 2. 需求和测试一起改 → 必须安静（不能狼来了）─────────────
sed 's|→ 409|→ 201 且状态=预售|' docs/spec.md > s.t && mv s.t docs/spec.md
sed 's|409|201|' tests/order_test.txt > t.t && mv t.t tests/order_test.txt
git commit -qam "需求和测试一起改"
ck "需求与测试同时改时不误报"            '! run | grep -q "需求改了，但引用它"'
reset

# ── 3. 完全没碰 spec → 必须安静 ─────────────────────────────
echo "// tweak" >> tests/order_test.txt && git commit -qam "无关改动"
ck "没碰 spec 时不误报"                  '! run | grep -q "需求改了，但引用它"'
reset

# ── 4. REQ 被删光，测试还在 → 孤儿测试必须照报 ──────────────
grep -v 'REQ-ORD-001' docs/spec.md | grep -v '例：' > s.t && mv s.t docs/spec.md
git commit -qam "砍掉这条需求"
ck "spec 清空后孤儿测试仍被报出（不静默关闭）" 'run | grep -q "孤儿测试"'
reset

# ── 5. 需求存在但没人实现 → 孤儿需求 ────────────────────────
rm tests/order_test.txt && git commit -qam "删掉测试"
ck "删掉实现后报孤儿需求"                'run | grep -q "孤儿需求"'
reset

[ $fail -eq 0 ] && echo "✓ spec 追溯测试全过（6 条）"
exit $fail
