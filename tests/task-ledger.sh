#!/usr/bin/env bash
# Ledger v2 contract tests. Negative cases assert the reason, not only exit status.
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
  dir="$1"
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
  dir="$1"
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

## TASK-GATE-R0-002 | gate fixture
- state: blocked
- rev: 1
- rq: none
- deps: TASK-READY-001
- owner: none
- claim: none
- tracking: github:issue#102; github:milestone#7
- updated: 2026-07-29T18:00:00+08:00
- write: repo:docs/gate.md
- artifact: repo:docs/gate.md
- accept AC-1: gate evidence is audited
- evidence: none
- blocker: deps:TASK-READY-001; need=fixture evidence
- handoff: none
- effect: none
- ci-scope: required=none; advisory=ubuntu,macos; n/a=none; reason=blocked gate fixture
- outcome: none

## TASK-OPS-R1-BOOTSTRAP-001 | conditional bridge fixture
- state: blocked
- rev: 1
- rq: none
- deps: TASK-GATE-R0-002@continue
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T18:00:00+08:00
- write: none
- artifact: none
- accept AC-1: bootstrap is reproducible
- evidence: none
- blocker: gate:TASK-GATE-R0-002; need=accepted outcome continue
- handoff: none
- effect: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=blocked bridge fixture
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
- accept AC-1: first acceptance is satisfied
- evidence AC-1: ref=repo:docs/done.md
- accept AC-2: second acceptance is satisfied
- evidence AC-2: command=fixture-check; exit=0
- blocker: none
- handoff: none
- effect: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=accepted fixture
- move: move-fixture-accepted-001

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

## TASK-ROLLBACK-001 | rolled back fixture
- state: rolled-back
- rev: 2
- rq: none
- deps: TASK-DONE-001
- owner: agent:test
- claim: run:fixture-rollback-001
- tracking: none
- updated: 2026-07-29T18:00:00+08:00
- write: repo:docs/rollback.md
- artifact: repo:docs/rollback.md
- accept AC-1: original acceptance remains visible
- evidence: none
- blocker: none
- handoff: none
- effect: none
- rollback-reason: fixture reversal
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=rolled-back fixture
- move: move-fixture-rollback-001
EOF
}

make_terminal_bridge() {
  dir="$1"
  outcome_value="$2"
  mkdir -p "$dir"
  cat > "$dir/todo.md" <<'EOF'
# TODO
<!-- ledger:v2 -->

## TASK-WORK-001 | active work fixture
- state: ready
- rev: 1
- rq: none
- deps: TASK-DONE-001
- owner: none
- claim: none
- tracking: github:issue#201; github:milestone#8
- updated: 2026-07-29T18:00:00+08:00
- write: repo:docs/work.md
- artifact: repo:docs/work.md
- accept AC-1: work is delivered
- evidence: none
- blocker: none
- handoff: none
- effect: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=terminal bridge fixture
EOF

  cat > "$dir/done.md" <<'EOF'
# DONE
<!-- ledger:v2 -->

## TASK-DONE-001 | accepted prerequisite fixture
- state: accepted
- rev: 1
- rq: none
- deps: none
- owner: agent:test
- claim: run:fixture-terminal-prerequisite
- tracking: github:issue#200; github:milestone#8
- updated: 2026-07-29T18:00:00+08:00
- write: repo:docs/done.md
- artifact: repo:docs/done.md
- accept AC-1: prerequisite is satisfied
- evidence AC-1: ref=repo:docs/done.md
- blocker: none
- handoff: none
- effect: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=terminal bridge fixture
- move: move-fixture-terminal-prerequisite

## TASK-GATE-R0-002 | accepted gate fixture
- state: accepted
- rev: 2
- rq: none
- deps: TASK-DONE-001
- owner: agent:test
- claim: run:fixture-terminal-gate
- tracking: github:issue#202; github:milestone#8
- updated: 2026-07-29T18:00:00+08:00
- write: repo:docs/gate.md
- artifact: repo:docs/gate.md
- accept AC-1: gate audit is complete
- evidence AC-1: ref=repo:docs/gate.md
- blocker: none
- handoff: none
- effect: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=terminal bridge fixture
EOF
  if [ "$outcome_value" != "missing" ]; then
    printf '%s\n' "- outcome: $outcome_value" >> "$dir/done.md"
  fi
  cat >> "$dir/done.md" <<'EOF'
- move: move-fixture-terminal-gate

## TASK-OPS-R1-BOOTSTRAP-001 | accepted bootstrap fixture
- state: accepted
- rev: 2
- rq: none
- deps: TASK-GATE-R0-002@continue
- owner: agent:test
- claim: run:fixture-terminal-bootstrap
- tracking: none
- updated: 2026-07-29T18:00:00+08:00
- write: repo:ops/bootstrap.md
- artifact: repo:ops/bootstrap.md
- accept AC-1: bootstrap is complete
- evidence AC-1: ref=repo:ops/bootstrap.md
- blocker: none
- handoff: none
- effect: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=terminal bridge fixture
- move: move-fixture-terminal-bootstrap
EOF
}

copy_case() {
  name="$1"
  cp -R "$VALID" "$TMP/$name"
  printf '%s\n' "$TMP/$name"
}

replace_line() {
  file="$1"
  old="$2"
  new="$3"
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
  file="$1"
  line="$2"
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

duplicate_line() {
  file="$1"
  line="$2"
  awk -v line="$line" '
    { print }
    $0 == line && !duplicated { print; duplicated=1 }
    END { if (!duplicated) exit 3 }
  ' "$file" > "$file.tmp" || {
    printf '✗ fixture mutation 找不到: %s\n' "$line"
    exit 1
  }
  mv "$file.tmp" "$file"
}

append_duplicate_id() {
  file="$1"
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

append_claimed_conflict() {
  file="$1"
  cat >> "$file" <<'EOF'

## TASK-CLAIMED-002 | conflicting claimed fixture
- state: claimed
- rev: 1
- rq: none
- deps: TASK-DONE-001
- owner: agent:test-two
- claim: run:fixture-claimed-002
- tracking: github:issue#103; github:milestone#7
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

append_conflicting_claim() {
  file="$1"
  cat >> "$file" <<'EOF'

## TASK-CLAIMED-002 | conflicting claimed fixture
- state: claimed
- rev: 1
- rq: none
- deps: TASK-DONE-001
- owner: agent:test-two
- claim: run:fixture-claimed-002
- tracking: github:issue#103; github:milestone#7
- updated: 2026-07-29T18:00:00+08:00
- write: repo:scripts/claimed.sh
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
  dir="$1"
  "$CHECK" "$dir/todo.md" "$dir/done.md" 2>&1 || true
}

expect_ok() {
  label="$1"
  dir="$2"
  assert_tasks "$dir"
  if output=$("$CHECK" "$dir/todo.md" "$dir/done.md" 2>&1); then
    pass "$label"
  else
    bad "$label"
    printf '%s\n' "$output" | sed 's/^/    /'
  fi
}

expect_bad() {
  label="$1"
  expected="$2"
  dir="$3"
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

VALID="$TMP/valid"
make_valid "$VALID"
assert_tasks "$VALID"
[ "$(task_count "$VALID/todo.md" "$VALID/done.md")" -eq 7 ] || {
  printf '✗ valid fixture 应有 7 个 TASK\n'
  exit 1
}

[ -x "$CHECK" ] || {
  printf '✗ 找不到可执行的 ledger validator: %s\n' "$CHECK"
  exit 1
}

expect_ok "合法 v2 通过（effect:none 无需 undo，Milestone 可共享）" "$VALID"

EMPTY_TODO=$(copy_case empty-todo)
printf '# TODO\n<!-- ledger:v2 -->\n' > "$EMPTY_TODO/todo.md"
[ "$(task_count "$EMPTY_TODO/todo.md")" -eq 0 ] || {
  printf '✗ empty todo fixture 不是空的\n'
  exit 1
}
if "$CHECK" "$EMPTY_TODO/todo.md" "$EMPTY_TODO/done.md" >/dev/null 2>&1; then
  bad "空 todo 必须拒绝"
else
  output=$(out "$EMPTY_TODO")
  if printf '%s\n' "$output" | grep -Fq 'todo.md 中没有 TASK 记录'; then
    pass "todo 空输入不会假绿"
  else
    bad "空 todo 必须精准拒绝"
  fi
fi

EMPTY_DONE=$(copy_case empty-done)
printf '# DONE\n<!-- ledger:v2 -->\n' > "$EMPTY_DONE/done.md"
[ "$(task_count "$EMPTY_DONE/done.md")" -eq 0 ] || {
  printf '✗ empty done fixture 不是空的\n'
  exit 1
}
if "$CHECK" "$EMPTY_DONE/todo.md" "$EMPTY_DONE/done.md" >/dev/null 2>&1; then
  bad "空 done 必须拒绝"
else
  output=$(out "$EMPTY_DONE")
  if printf '%s\n' "$output" | grep -Fq 'done.md 中没有 TASK 记录'; then
    pass "done 空输入不会假绿"
  else
    bad "空 done 必须精准拒绝"
  fi
fi

case_dir=$(copy_case duplicate-id)
append_duplicate_id "$case_dir/todo.md"
expect_bad "todo 内重复 Task ID" "TASK ID 在 todo.md 内重复: TASK-READY-001" "$case_dir"

case_dir=$(copy_case cross-ledger-id)
replace_line "$case_dir/todo.md" '## TASK-READY-001 | ready fixture' '## TASK-DONE-001 | ready fixture'
expect_bad "Task ID 跨 todo/done 重复" "TASK ID 同时出现在 todo.md 和 done.md: TASK-DONE-001" "$case_dir"

case_dir=$(copy_case malformed-header)
replace_line "$case_dir/todo.md" '## TASK-READY-001 | ready fixture' '## TASK-READY-001'
expect_bad "Task header 必须保留 title 分隔符" "Task 标题格式错误: TASK-READY-001" "$case_dir"

case_dir=$(copy_case missing-scalar)
delete_line "$case_dir/todo.md" '- rev: 1'
expect_bad "必填 scalar 不能缺失" "缺少字段 rev: TASK-READY-001" "$case_dir"

case_dir=$(copy_case duplicate-scalar)
duplicate_line "$case_dir/todo.md" '- state: ready'
expect_bad "scalar 字段不能重复" "字段 state 重复: TASK-READY-001" "$case_dir"

case_dir=$(copy_case missing-dep)
replace_line "$case_dir/todo.md" '- deps: TASK-DONE-001' '- deps: TASK-MISSING-999'
expect_bad "依赖必须存在" "依赖不存在: TASK-READY-001 -> TASK-MISSING-999" "$case_dir"

case_dir=$(copy_case dep-cycle)
replace_line "$case_dir/todo.md" '- deps: TASK-READY-001' '- deps: TASK-GATE-R0-002'
expect_bad "依赖环会被发现" "依赖成环:" "$case_dir"

case_dir=$(copy_case dep-not-accepted)
replace_line "$case_dir/todo.md" '- deps: TASK-READY-001' '- deps: TASK-DONE-001'
replace_line "$case_dir/todo.md" '- deps: TASK-DONE-001' '- deps: TASK-GATE-R0-002'
expect_bad "ready 直接依赖必须 accepted" "ready 依赖尚未 accepted: TASK-READY-001 -> TASK-GATE-R0-002" "$case_dir"

case_dir=$(copy_case illegal-conditional)
replace_line "$case_dir/todo.md" '- deps: TASK-DONE-001' '- deps: TASK-DONE-001@continue'
expect_bad "只允许 bootstrap bridge 使用 @continue" "非法条件依赖: TASK-READY-001 -> TASK-DONE-001@continue" "$case_dir"

case_dir=$(copy_case wrong-bootstrap-bridge)
replace_line "$case_dir/todo.md" '- deps: TASK-GATE-R0-002@continue' '- deps: TASK-GATE-R0-002'
expect_bad "bootstrap bridge 必须是唯一条件依赖" "bootstrap bridge 必须仅依赖 TASK-GATE-R0-002@continue" "$case_dir"

terminal_dir="$TMP/terminal-continue"
make_terminal_bridge "$terminal_dir" continue
expect_ok "accepted bootstrap 只能由 continue Gate 解锁" "$terminal_dir"

terminal_dir="$TMP/terminal-missing-outcome"
make_terminal_bridge "$terminal_dir" missing
expect_bad "accepted Gate 必须有 outcome" "accepted Gate 缺少 outcome: TASK-GATE-R0-002" "$terminal_dir"

terminal_dir="$TMP/terminal-invalid-outcome"
make_terminal_bridge "$terminal_dir" maybe
expect_bad "accepted Gate outcome 必须是枚举" "accepted Gate outcome 非法: TASK-GATE-R0-002 maybe" "$terminal_dir"

terminal_dir="$TMP/terminal-pivot"
make_terminal_bridge "$terminal_dir" pivot
expect_bad "pivot 不得解锁 accepted bootstrap" "accepted 条件依赖尚未 continue: TASK-OPS-R1-BOOTSTRAP-001 -> TASK-GATE-R0-002@continue" "$terminal_dir"

terminal_dir="$TMP/terminal-stop"
make_terminal_bridge "$terminal_dir" stop
expect_bad "stop 不得解锁 accepted bootstrap" "accepted 条件依赖尚未 continue: TASK-OPS-R1-BOOTSTRAP-001 -> TASK-GATE-R0-002@continue" "$terminal_dir"

case_dir=$(copy_case claim-state)
replace_line "$case_dir/todo.md" '- owner: agent:test' '- owner: none'
expect_bad "claimed 必须有 owner 和 claim" "state/claim 不一致: TASK-CLAIMED-001" "$case_dir"

case_dir=$(copy_case write-conflict)
append_conflicting_claim "$case_dir/todo.md"
expect_bad "active write scope 不得冲突" "active write scope 冲突: TASK-CLAIMED-001 <-> TASK-CLAIMED-002" "$case_dir"

case_dir=$(copy_case blocked-reason)
replace_line "$case_dir/todo.md" '- blocker: deps:TASK-READY-001; need=fixture evidence' '- blocker: none'
expect_bad "blocked 必须有准确 blocker" "blocked 缺少具体 blocker: TASK-GATE-R0-002" "$case_dir"

case_dir=$(copy_case unsafe-write)
replace_line "$case_dir/todo.md" '- write: repo:docs/ready.md' '- write: /tmp/ready.md'
expect_bad "active write 必须是安全 repo 路径" "write 路径不安全: TASK-READY-001 /tmp/ready.md" "$case_dir"

case_dir=$(copy_case unsafe-artifact)
replace_line "$case_dir/todo.md" '- artifact: repo:docs/ready.md' '- artifact: repo:../ready.md'
expect_bad "active artifact 必须是安全 repo 路径" "artifact 路径不安全: TASK-READY-001 repo:../ready.md" "$case_dir"

case_dir=$(copy_case dot-scope-alias)
append_conflicting_claim "$case_dir/todo.md"
replace_line "$case_dir/todo.md" '- write: repo:scripts/claimed.sh' '- write: repo:./scripts/claimed.sh'
expect_bad "write scope 拒绝 dot 别名" "write 路径不安全: TASK-CLAIMED-001 repo:./scripts/claimed.sh" "$case_dir"

case_dir=$(copy_case empty-scope-segment)
replace_line "$case_dir/todo.md" '- write: repo:docs/ready.md' '- write: repo:docs//ready.md'
expect_bad "write scope 拒绝空路径段" "write 路径不安全: TASK-READY-001 repo:docs//ready.md" "$case_dir"

case_dir=$(copy_case write-prefix-conflict)
append_claimed_conflict "$case_dir/todo.md"
expect_bad "active write scope 不得目录包含" "active write scope 冲突: TASK-CLAIMED-001 <-> TASK-CLAIMED-002" "$case_dir"

case_dir=$(copy_case reused-issue)
replace_line "$case_dir/todo.md" '- tracking: github:issue#102; github:milestone#7' '- tracking: github:issue#101; github:milestone#7'
expect_bad "Issue primary tracking 不得复用" "primary tracking 被复用: github:issue#101" "$case_dir"

case_dir=$(copy_case reused-pr)
replace_line "$case_dir/todo.md" '- tracking: github:issue#102; github:milestone#7' '- tracking: github:pr#501; github:milestone#7'
expect_bad "PR primary tracking 不得复用" "primary tracking 被复用: github:pr#501" "$case_dir"

case_dir=$(copy_case missing-evidence)
delete_line "$case_dir/done.md" '- evidence AC-2: command=fixture-check; exit=0'
expect_bad "accepted 的每个 AC 都要同 ID evidence" "accepted 缺少 evidence AC-2: TASK-DONE-001" "$case_dir"

case_dir=$(copy_case empty-evidence)
replace_line "$case_dir/done.md" '- evidence AC-2: command=fixture-check; exit=0' '- evidence AC-2:'
expect_bad "accepted evidence 不得为空" "accepted evidence AC-2 为空: TASK-DONE-001" "$case_dir"

case_dir=$(copy_case none-evidence)
replace_line "$case_dir/done.md" '- evidence AC-2: command=fixture-check; exit=0' '- evidence AC-2: none'
expect_bad "accepted evidence 不得是 none" "accepted evidence AC-2 为空: TASK-DONE-001" "$case_dir"

case_dir=$(copy_case fake-cancelled-evidence)
replace_line "$case_dir/done.md" '- evidence: none' '- evidence AC-1: ref=repo:fake.md'
expect_bad "cancelled 不伪造 AC evidence" "cancelled 不得登记 AC evidence: TASK-CANCELLED-001" "$case_dir"

case_dir=$(copy_case missing-cancel-reason)
delete_line "$case_dir/done.md" '- cancellation-reason: superseded fixture route'
expect_bad "cancelled 保留取消原因" "cancelled 缺少 cancellation-reason: TASK-CANCELLED-001" "$case_dir"

case_dir=$(copy_case missing-successor)
delete_line "$case_dir/done.md" '- superseded-by: TASK-READY-001'
expect_bad "cancelled 指向存在的 successor" "cancelled 缺少 superseded-by: TASK-CANCELLED-001" "$case_dir"

case_dir=$(copy_case effect-mismatch)
replace_line "$case_dir/todo.md" '- undo: FX-FIXTURE-001; action=remove fixture' '- undo: FX-FIXTURE-002; action=remove fixture'
expect_bad "effect 必须有同 ID undo" "effect/undo 不匹配: TASK-CLAIMED-001 FX-FIXTURE-001 FX-FIXTURE-002" "$case_dir"

case_dir=$(copy_case duplicate-move)
replace_line "$case_dir/done.md" '- move: move-fixture-cancelled-001' '- move: move-fixture-accepted-001'
expect_bad "done move token 必须唯一" "done move token 重复: move-fixture-accepted-001" "$case_dir"

case_dir=$(copy_case bad-ci-scope)
replace_line "$case_dir/todo.md" '- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=documentation fixture' '- ci-scope: required=none; optional=none; n/a=ubuntu,macos; reason=wrong category fixture'
expect_bad "ci-scope 只使用约定的分类键" "ci-scope 格式错误: TASK-READY-001" "$case_dir"

case_dir=$(copy_case missing-ci-reason)
replace_line "$case_dir/todo.md" '- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=documentation fixture' '- ci-scope: required=none; advisory=none; n/a=ubuntu,macos'
expect_bad "ci-scope 必须保留因果 reason" "ci-scope 格式错误: TASK-READY-001" "$case_dir"

case_dir=$(copy_case mixed-ci-none)
replace_line "$case_dir/todo.md" '- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=documentation fixture' '- ci-scope: required=task-ledger,none; advisory=none; n/a=ubuntu,macos; reason=contradictory fixture'
expect_bad "ci-scope 中 none 不得与 check 并存" "ci-scope none 不得与 check 并存: TASK-READY-001 required" "$case_dir"

case_dir=$(copy_case duplicate-ci-class)
replace_line "$case_dir/todo.md" '- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=documentation fixture' '- ci-scope: required=ubuntu; advisory=ubuntu; n/a=macos; reason=contradictory fixture'
expect_bad "ci-scope 三类必须互斥" "ci-scope check 冲突: TASK-READY-001 ubuntu" "$case_dir"

case_dir=$(copy_case v1-marker)
replace_line "$case_dir/todo.md" '<!-- ledger:v2 -->' '<!-- ledger:v1 -->'
expect_bad "v1 ledger 必须迁移" "todo.md 必须声明 <!-- ledger:v2 -->" "$case_dir"

if [ "${TASK_LEDGER_SKIP_ACTUAL:-0}" = "1" ]; then
  printf '  - 跳过当前 todo.md/done.md（仅跑 fixture）\n'
else
  assert_tasks "$ROOT"
  expect_ok "当前 todo.md/done.md 符合 v2" "$ROOT"
fi

[ "$fail" -eq 0 ] && printf '✓ ledger v2 测试全过（%s 条）\n' "$checks"
exit "$fail"
