#!/usr/bin/env bash
# Representative tests for the reusable task-ledger v2 validator.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHECK="$ROOT/scripts/check-task-ledger.sh"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

fail=0
checks=0

pass() { printf '  ✓ %s\n' "$1"; checks=$((checks + 1)); }
bad() { printf '  ✗ %s\n' "$1"; fail=1; checks=$((checks + 1)); }

task_count() {
  grep -h '^## TASK-' "$@" 2>/dev/null | wc -l | tr -d ' '
}

assert_tasks() {
  dir=$1
  todo_count=$(task_count "$dir/todo.md")
  done_count=$(task_count "$dir/done.md")
  [ "${todo_count:-0}" -gt 0 ] || {
    printf '✗ fixture %s 的 todo.md 没有 TASK，测试本身已空转\n' "$dir"
    exit 1
  }
  [ "${done_count:-0}" -gt 0 ] || {
    printf '✗ fixture %s 的 done.md 没有 TASK，测试本身已空转\n' "$dir"
    exit 1
  }
}

make_valid() {
  dir=$1
  mkdir -p "$dir"
  cat > "$dir/todo.md" <<'EOF'
# TODO
<!-- ledger:v2 -->

## TASK-READY-001 | ready fixture
- state: ready
- rev: 1
- rq: none
- deps: TASK-DONE-001
- owner: none
- claim: none
- tracking: github:issue#101; github:milestone#7
- updated: 2026-07-29T18:00:00+08:00
- write: repo:docs/ready.md
- artifact: repo:docs/ready.md
- accept AC-1: ready work is delivered
- evidence: none
- blocker: none
- handoff: none
- effect: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=documentation fixture

## TASK-CLAIMED-001 | claimed fixture
- state: claimed
- rev: 1
- rq: none
- deps: TASK-DONE-001
- owner: agent:test
- claim: run:fixture-claimed-001
- tracking: github:pr#501; github:milestone#7
- updated: 2026-07-29T18:00:00+08:00
- write: repo:scripts/claimed.sh
- artifact: repo:scripts/claimed.sh
- accept AC-1: claimed work is delivered
- evidence: none
- blocker: none
- handoff: none
- effect: FX-FIXTURE-001; action=create fixture
- undo: FX-FIXTURE-001; action=remove fixture
- ci-scope: required=ubuntu,macos; advisory=none; n/a=none; reason=shell fixture

## TASK-BLOCKED-001 | blocked fixture
- state: blocked
- rev: 1
- rq: none
- deps: TASK-READY-001
- owner: none
- claim: none
- tracking: github:issue#102; github:milestone#7
- updated: 2026-07-29T18:00:00+08:00
- write: none
- artifact: none
- accept AC-1: blocked work is delivered
- evidence: none
- blocker: deps:TASK-READY-001; need=fixture evidence
- handoff: none
- effect: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=blocked fixture

## TASK-CONDITIONAL-001 | conditional fixture
- state: ready
- rev: 1
- rq: none
- deps: TASK-DECISION-001@continue
- owner: none
- claim: none
- tracking: github:issue#103; github:milestone#7
- updated: 2026-07-29T18:00:00+08:00
- write: repo:docs/conditional.md
- artifact: repo:docs/conditional.md
- accept AC-1: conditional work is delivered
- evidence: none
- blocker: none
- handoff: none
- effect: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=conditional fixture
EOF

  cat > "$dir/done.md" <<'EOF'
# DONE
<!-- ledger:v2 -->

## TASK-DONE-001 | accepted fixture
- state: accepted
- rev: 1
- rq: none
- deps: none
- owner: agent:test
- claim: run:fixture-done-001
- tracking: github:issue#100; github:milestone#7
- updated: 2026-07-29T18:00:00+08:00
- write: repo:docs/done.md
- artifact: repo:docs/done.md
- accept AC-1: acceptance is satisfied
- evidence AC-1: ref=repo:docs/done.md
- blocker: none
- handoff: none
- effect: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=accepted fixture
- move: move-fixture-accepted-001

## TASK-DECISION-001 | accepted decision fixture
- state: accepted
- rev: 2
- rq: none
- deps: TASK-DONE-001
- owner: agent:test
- claim: run:fixture-decision-001
- tracking: github:issue#104; github:milestone#7
- updated: 2026-07-29T18:00:00+08:00
- write: repo:docs/decision.md
- artifact: repo:docs/decision.md
- accept AC-1: decision evidence is complete
- evidence AC-1: ref=repo:docs/decision.md
- blocker: none
- handoff: none
- effect: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=decision fixture
- outcome: continue
- move: move-fixture-decision-001

## TASK-CANCELLED-001 | cancelled fixture
- state: cancelled
- rev: 2
- rq: none
- deps: TASK-DONE-001
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T18:00:00+08:00
- write: none
- artifact: none
- accept AC-1: original acceptance remains visible
- evidence: none
- blocker: none
- handoff: none
- effect: none
- cancellation-reason: superseded fixture route
- superseded-by: TASK-READY-001
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=cancelled fixture
- move: move-fixture-cancelled-001
EOF
}

copy_case() {
  name=$1
  cp -R "$VALID" "$TMP/$name"
  printf '%s\n' "$TMP/$name"
}

replace_line() {
  file=$1
  old=$2
  new=$3
  awk -v old="$old" -v new="$new" '
    $0 == old && !changed { print new; changed=1; next }
    { print }
    END { if (!changed) exit 3 }
  ' "$file" > "$file.tmp" || {
    printf '✗ fixture mutation 找不到: %s\n' "$old"
    exit 1
  }
  mv "$file.tmp" "$file"
}

delete_line() {
  file=$1
  line=$2
  awk -v line="$line" '
    $0 == line && !deleted { deleted=1; next }
    { print }
    END { if (!deleted) exit 3 }
  ' "$file" > "$file.tmp" || {
    printf '✗ fixture mutation 找不到: %s\n' "$line"
    exit 1
  }
  mv "$file.tmp" "$file"
}

append_duplicate_id() {
  file=$1
  cat >> "$file" <<'EOF'

## TASK-READY-001 | duplicate ID fixture
- state: blocked
- rev: 1
- rq: none
- deps: TASK-DONE-001
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T18:00:00+08:00
- write: none
- artifact: none
- accept AC-1: duplicate fixture
- evidence: none
- blocker: duplicate fixture
- handoff: none
- effect: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=duplicate fixture
EOF
}

append_conflicting_claim() {
  file=$1
  cat >> "$file" <<'EOF'

## TASK-CLAIMED-002 | conflicting claimed fixture
- state: claimed
- rev: 1
- rq: none
- deps: TASK-DONE-001
- owner: agent:test-two
- claim: run:fixture-claimed-002
- tracking: github:issue#105; github:milestone#7
- updated: 2026-07-29T18:00:00+08:00
- write: repo:scripts/
- artifact: repo:scripts/claimed-two.sh
- accept AC-1: conflicting work is delivered
- evidence: none
- blocker: none
- handoff: none
- effect: none
- ci-scope: required=ubuntu,macos; advisory=none; n/a=none; reason=shell fixture
EOF
}

out() {
  dir=$1
  "$CHECK" "$dir/todo.md" "$dir/done.md" 2>&1 || true
}

expect_ok() {
  label=$1
  dir=$2
  assert_tasks "$dir"
  if output=$("$CHECK" "$dir/todo.md" "$dir/done.md" 2>&1); then
    pass "$label"
  else
    bad "$label"
    printf '%s\n' "$output" | sed 's/^/    /'
  fi
}

expect_bad() {
  label=$1
  expected=$2
  dir=$3
  assert_tasks "$dir"
  if "$CHECK" "$dir/todo.md" "$dir/done.md" >/dev/null 2>&1; then
    bad "${label}（错误地通过）"
    return
  fi
  output=$(out "$dir")
  if printf '%s\n' "$output" | grep -Fq "$expected"; then
    pass "$label"
  else
    bad "${label}（失败原因不对，期待: ${expected}）"
    printf '%s\n' "$output" | sed 's/^/    /'
  fi
}

[ -x "$CHECK" ] || {
  printf '✗ 找不到可执行的 ledger validator: %s\n' "$CHECK"
  exit 1
}

VALID="$TMP/valid"
make_valid "$VALID"
assert_tasks "$VALID"
[ "$(task_count "$VALID/todo.md" "$VALID/done.md")" -eq 7 ] || {
  printf '✗ valid fixture 应有 7 个 TASK\n'
  exit 1
}

expect_ok "合法通用 v2 账本通过" "$VALID"

case_dir=$(copy_case empty-todo)
printf '# TODO\n<!-- ledger:v2 -->\n' > "$case_dir/todo.md"
if "$CHECK" "$case_dir/todo.md" "$case_dir/done.md" >/dev/null 2>&1; then
  bad "空 todo 错误地通过"
elif out "$case_dir" | grep -Fq 'todo.md 中没有 TASK 记录'; then
  pass "空输入不会假绿"
else
  bad "空 todo 的失败原因不对"
fi

case_dir=$(copy_case duplicate-id)
append_duplicate_id "$case_dir/todo.md"
expect_bad "重复 Task ID" "TASK ID 在 todo.md 内重复: TASK-READY-001" "$case_dir"

case_dir=$(copy_case missing-dep)
replace_line "$case_dir/todo.md" '- deps: TASK-DONE-001' '- deps: TASK-MISSING-999'
expect_bad "依赖必须存在" "依赖不存在: TASK-READY-001 -> TASK-MISSING-999" "$case_dir"

case_dir=$(copy_case dep-cycle)
replace_line "$case_dir/done.md" '- deps: none' '- deps: TASK-BLOCKED-001'
expect_bad "依赖环会被发现" "依赖成环:" "$case_dir"

case_dir=$(copy_case conditional-pivot)
replace_line "$case_dir/done.md" '- outcome: continue' '- outcome: pivot'
expect_bad "条件结果必须匹配" "ready 条件依赖未满足: TASK-CONDITIONAL-001 -> TASK-DECISION-001@continue" "$case_dir"

case_dir=$(copy_case conditional-suffix)
replace_line "$case_dir/todo.md" '- deps: TASK-DECISION-001@continue' '- deps: TASK-DECISION-001@maybe'
expect_bad "条件后缀必须使用通用枚举" "非法条件依赖: TASK-CONDITIONAL-001 -> TASK-DECISION-001@maybe" "$case_dir"

case_dir=$(copy_case conditional-outcome)
delete_line "$case_dir/done.md" '- outcome: continue'
expect_bad "条件目标必须显式给出 outcome" "条件依赖目标缺少 outcome: TASK-CONDITIONAL-001 -> TASK-DECISION-001" "$case_dir"

case_dir=$(copy_case claim-state)
replace_line "$case_dir/todo.md" '- owner: agent:test' '- owner: none'
expect_bad "claimed 必须有 owner 与 claim" "state/claim 不一致: TASK-CLAIMED-001" "$case_dir"

case_dir=$(copy_case write-conflict)
append_conflicting_claim "$case_dir/todo.md"
expect_bad "active write scope 不得冲突" "active write scope 冲突: TASK-CLAIMED-001 <-> TASK-CLAIMED-002" "$case_dir"

case_dir=$(copy_case unsafe-write)
replace_line "$case_dir/todo.md" '- write: repo:docs/ready.md' '- write: repo:../ready.md'
expect_bad "write scope 必须是安全 repo 路径" "write 路径不安全: TASK-READY-001 repo:../ready.md" "$case_dir"

case_dir=$(copy_case missing-evidence)
delete_line "$case_dir/done.md" '- evidence AC-1: ref=repo:docs/done.md'
expect_bad "accepted 必须有对应 evidence" "accepted 缺少 evidence AC-1: TASK-DONE-001" "$case_dir"

case_dir=$(copy_case fake-cancelled-evidence)
replace_line "$case_dir/done.md" '- evidence: none' '- evidence AC-1: ref=repo:fake.md'
expect_bad "cancelled 不得伪造 AC evidence" "cancelled 不得登记 AC evidence: TASK-CANCELLED-001" "$case_dir"

case_dir=$(copy_case duplicate-move)
replace_line "$case_dir/done.md" '- move: move-fixture-cancelled-001' '- move: move-fixture-accepted-001'
expect_bad "done move token 必须唯一" "done move token 重复: move-fixture-accepted-001" "$case_dir"

case_dir=$(copy_case effect-mismatch)
replace_line "$case_dir/todo.md" '- undo: FX-FIXTURE-001; action=remove fixture' '- undo: FX-FIXTURE-002; action=remove fixture'
expect_bad "effect 必须有同 ID undo" "effect/undo 不匹配: TASK-CLAIMED-001" "$case_dir"

case_dir=$(copy_case ci-conflict)
replace_line "$case_dir/todo.md" '- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=documentation fixture' '- ci-scope: required=ubuntu; advisory=ubuntu; n/a=macos; reason=contradictory fixture'
expect_bad "ci-scope 分类必须互斥" "ci-scope check 冲突: TASK-READY-001 ubuntu" "$case_dir"

expect_ok "当前 todo.md/done.md 符合 v2" "$ROOT"

[ "$fail" -eq 0 ] && printf '✓ ledger v2 代表性测试全过（%s 条）\n' "$checks"
exit "$fail"
