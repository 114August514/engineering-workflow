#!/usr/bin/env bash
# Validate the repository's deliberately small Markdown task-ledger v2 contract.
set -uo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: scripts/check-task-ledger.sh <todo.md> <done.md>" >&2
  exit 2
fi

TODO=$1
DONE=$2

[ -f "$TODO" ] || { echo "ledger input not found: $TODO" >&2; exit 2; }
[ -f "$DONE" ] || { echo "ledger input not found: $DONE" >&2; exit 2; }

TODO_NAME=${TODO##*/}
DONE_NAME=${DONE##*/}

awk -v todo_path="$TODO" -v done_path="$DONE" \
    -v todo_name="$TODO_NAME" -v done_name="$DONE_NAME" '
function trim(value) {
  sub(/^[[:space:]]+/, "", value)
  sub(/[[:space:]]+$/, "", value)
  return value
}

function report(message) {
  print "error: " message > "/dev/stderr"
  errors++
}

function field_key(record, name) {
  return record SUBSEP name
}

function set_scalar(record, name, value, key) {
  key=field_key(record, name)
  field_count[key]++
  if (field_count[key] == 1) field_value[key]=trim(value)
}

function need(record, name, key, value) {
  key=field_key(record, name)
  if (!(key in field_count)) {
    report("缺少字段 " name ": " task_id[record])
    return ""
  }
  if (field_count[key] > 1) report("字段 " name " 重复: " task_id[record])
  value=field_value[key]
  if (value == "") report("字段 " name " 为空: " task_id[record])
  return value
}

function check_optional_scalar(record, name, key) {
  key=field_key(record, name)
  if ((key in field_count) && field_count[key] > 1) report("字段 " name " 重复: " task_id[record])
}

function add_list(record, name, value, key, number) {
  key=record SUBSEP name
  number=++list_count[key]
  list_value[key SUBSEP number]=trim(value)
}

function list_size(record, name) {
  return list_count[record SUBSEP name] + 0
}

function list_item(record, name, number) {
  return list_value[record SUBSEP name SUBSEP number]
}

function valid_task_id(value) {
  return value ~ /^TASK-[A-Z0-9][A-Z0-9-]*$/ && value !~ /--/ && value !~ /-$/
}

function safe_repo_path(value, path, count, parts, number) {
  if (value == "none") return 1
  if (substr(value, 1, 5) != "repo:") return 0
  path=substr(value, 6)
  if (path == "" || substr(path, 1, 1) == "/") return 0
  if (index(path, "*") || index(path, "?") || index(path, "[") || index(path, "]")) return 0
  count=split(path, parts, "/")
  for (number=1; number<=count; number++) {
    if ((parts[number] == "" && number != count) || parts[number] == "." || parts[number] == "..") return 0
  }
  return 1
}

function validate_paths(record, name, state, number, value, concrete, saw_none) {
  if (list_size(record, name) == 0) {
    report("缺少字段 " name ": " task_id[record])
    return
  }
  for (number=1; number<=list_size(record, name); number++) {
    value=list_item(record, name, number)
    if (value == "none") {
      saw_none=1
      continue
    }
    concrete++
    if (!safe_repo_path(value)) report(name " 路径不安全: " task_id[record] " " value)
  }
  if (saw_none && concrete) report(name " 不得同时使用 none 和具体路径: " task_id[record])
  if ((state == "ready" || state == "claimed") && concrete == 0) {
    report(state " 缺少具体 " name ": " task_id[record])
  }
}

function scope_overlap(left, right, left_length, right_length) {
  sub(/\/+$/, "", left)
  sub(/\/+$/, "", right)
  if (left == right) return 1
  left_length=length(left)
  right_length=length(right)
  if (substr(right, 1, left_length + 1) == left "/") return 1
  if (substr(left, 1, right_length + 1) == right "/") return 1
  return 0
}

function parse_tracking(record, raw, count, items, number, item) {
  raw=trim(raw)
  if (raw == "none") return
  count=split(raw, items, ";")
  for (number=1; number<=count; number++) {
    item=trim(items[number])
    if (item == "none" || item == "") {
      report("tracking 格式错误: " task_id[record] " " item)
      continue
    }
    if (item ~ /^github:milestone#[0-9][0-9]*$/) continue
    if (item !~ /^github:(issue|pr)#[0-9][0-9]*$/) {
      report("tracking 格式错误: " task_id[record] " " item)
      continue
    }
    if (item in primary_owner) {
      if (!primary_reported[item]) {
        report("primary tracking 被复用: " item " (" primary_owner[item] ", " task_id[record] ")")
        primary_reported[item]=1
      }
    } else {
      primary_owner[item]=task_id[record]
    }
  }
}

function validate_ci_bucket(record, bucket, raw, count, items, number, item, key) {
  raw=trim(raw)
  if (raw == "none") return
  if (raw ~ /(^|,)none(,|$)/) {
    report("ci-scope none 不得与 check 并存: " task_id[record] " " bucket)
    return
  }
  if (raw == "") {
    report("ci-scope 格式错误: " task_id[record])
    return
  }
  count=split(raw, items, ",")
  for (number=1; number<=count; number++) {
    item=trim(items[number])
    if (item !~ /^[A-Za-z0-9][A-Za-z0-9._-]*$/) {
      report("ci-scope 格式错误: " task_id[record])
      continue
    }
    key=record SUBSEP item
    if (key in ci_bucket && ci_bucket[key] != bucket) {
      report("ci-scope check 冲突: " task_id[record] " " item)
    } else if (key in ci_bucket) {
      report("ci-scope check 重复: " task_id[record] " " item)
    } else {
      ci_bucket[key]=bucket
    }
  }
}

function validate_ci_scope(record, raw, count, pieces, required, advisory, na, reason) {
  count=split(raw, pieces, ";")
  if (count != 4) {
    report("ci-scope 格式错误: " task_id[record])
    return
  }
  pieces[1]=trim(pieces[1]); pieces[2]=trim(pieces[2])
  pieces[3]=trim(pieces[3]); pieces[4]=trim(pieces[4])
  if (substr(pieces[1], 1, 9) != "required=" ||
      substr(pieces[2], 1, 9) != "advisory=" ||
      substr(pieces[3], 1, 4) != "n/a=" ||
      substr(pieces[4], 1, 7) != "reason=") {
    report("ci-scope 格式错误: " task_id[record])
    return
  }
  required=trim(substr(pieces[1], 10))
  advisory=trim(substr(pieces[2], 10))
  na=trim(substr(pieces[3], 5))
  reason=trim(substr(pieces[4], 8))
  if (required == "" || advisory == "" || na == "" || reason == "" || reason == "none") {
    report("ci-scope 格式错误: " task_id[record])
    return
  }
  validate_ci_bucket(record, "required", required)
  validate_ci_bucket(record, "advisory", advisory)
  validate_ci_bucket(record, "n/a", na)
}

function effect_id(value, copy, pieces) {
  copy=trim(value)
  split(copy, pieces, ";")
  return trim(pieces[1])
}

function collect_effects(record, side, number, value, id, key) {
  for (number=1; number<=list_size(record, side); number++) {
    value=list_item(record, side, number)
    if (value == "none") {
      effect_none[record SUBSEP side]++
      continue
    }
    id=effect_id(value)
    if (id !~ /^FX-[A-Z0-9][A-Z0-9-]*$/ || id ~ /--/ || id ~ /-$/) {
      report(side " ID 格式错误: " task_id[record] " " id)
      continue
    }
    key=record SUBSEP side SUBSEP id
    if (key in effect_seen) report(side " ID 重复: " task_id[record] " " id)
    effect_seen[key]=1
    effect_named_count[record SUBSEP side]++
    effect_single_id[record SUBSEP side]=id
  }
  if (effect_none[record SUBSEP side] && list_size(record, side) > 1) {
    report(side ": none 不能与 FX-* 并存: " task_id[record])
  }
}

function validate_effects(record, key, parts, id, opposite, effect_count, undo_count, effect_one, undo_one) {
  if (list_size(record, "effect") == 0) {
    report("缺少字段 effect: " task_id[record])
    return
  }
  collect_effects(record, "effect")
  collect_effects(record, "undo")
  effect_count=effect_named_count[record SUBSEP "effect"] + 0
  undo_count=effect_named_count[record SUBSEP "undo"] + 0
  effect_one=effect_single_id[record SUBSEP "effect"]
  undo_one=effect_single_id[record SUBSEP "undo"]
  if (effect_count == 1 && undo_count == 1 && effect_one != undo_one) {
    report("effect/undo 不匹配: " task_id[record] " " effect_one " " undo_one)
    return
  }
  for (key in effect_seen) {
    split(key, parts, SUBSEP)
    if (parts[1] != record || parts[2] != "effect") continue
    id=parts[3]
    opposite=record SUBSEP "undo" SUBSEP id
    if (!(opposite in effect_seen)) report("effect 缺少匹配 undo: " task_id[record] " " id)
  }
  for (key in effect_seen) {
    split(key, parts, SUBSEP)
    if (parts[1] != record || parts[2] != "undo") continue
    id=parts[3]
    opposite=record SUBSEP "effect" SUBSEP id
    if (!(opposite in effect_seen)) report("undo 缺少匹配 effect: " task_id[record] " " id)
  }
}

function visit(node, number, target) {
  color[node]=1
  for (number=1; number<=edge_count; number++) {
    if (edge_from[number] != node) continue
    target=edge_to[number]
    if (color[target] == 1) {
      if (!cycle_reported) {
        report("依赖成环: " node " -> " target)
        cycle_reported=1
      }
    } else if (color[target] == 0) {
      visit(target)
    }
  }
  color[node]=2
}

FNR == 1 {
  current=0
  ledger=(FILENAME == todo_path ? "todo" : "done")
  ledger_name=(ledger == "todo" ? todo_name : done_name)
}

$0 == "<!-- ledger:v2 -->" {
  marker[ledger]++
  next
}

/^## TASK-/ {
  header=$0
  sub(/^## /, "", header)
  header_count=split(header, header_parts, "[[:space:]]+\\|[[:space:]]+")
  id=header_parts[1]
  records++
  current=records
  task_id[current]=id
  task_ledger[current]=ledger
  task_ledger_name[current]=ledger_name
  ledger_records[ledger]++
  if (header_count < 2 || trim(header_parts[2]) == "") report("Task 标题格式错误: " id)
  if (!valid_task_id(id)) report("Task ID 格式错误: " id)
  local_key=ledger SUBSEP id
  ledger_id_count[local_key]++
  if (ledger_id_count[local_key] == 2) report("TASK ID 在 " ledger_name " 内重复: " id)
  if ((id in first_ledger) && first_ledger[id] != ledger) cross_ledger_id[id]=1
  if (!(id in first_ledger)) {
    first_ledger[id]=ledger
    first_record[id]=current
    all_id[id]=1
  }
  next
}

current == 0 { next }

/^- / {
  line=substr($0, 3)
  colon=index(line, ":")
  if (!colon) next
  name=substr(line, 1, colon - 1)
  value=trim(substr(line, colon + 1))
  if (name ~ /^accept AC-/) {
    ac=substr(name, 8)
    if (ac !~ /^AC-[0-9][0-9]*$/) report("acceptance ID 格式错误: " task_id[current] " " ac)
    acceptance_count[current SUBSEP ac]++
    acceptance[current SUBSEP ac]=1
    next
  }
  if (name ~ /^evidence AC-/) {
    ac=substr(name, 10)
    if (ac !~ /^AC-[0-9][0-9]*$/) report("evidence ID 格式错误: " task_id[current] " " ac)
    evidence_count[current SUBSEP ac]++
    evidence[current SUBSEP ac]=1
    if (evidence_count[current SUBSEP ac] == 1) evidence_value[current SUBSEP ac]=value
    next
  }
  if (name == "write" || name == "artifact" || name == "effect" || name == "undo") {
    add_list(current, name, value)
    next
  }
  if (name == "state" || name == "rev" || name == "rq" || name == "deps" ||
      name == "owner" || name == "claim" || name == "tracking" || name == "updated" ||
      name == "evidence" || name == "blocker" || name == "handoff" || name == "ci-scope" ||
      name == "move" || name == "cancellation-reason" || name == "superseded-by" ||
      name == "rollback-reason" || name == "outcome" || name == "successor-route" ||
      name == "amendment-receipt" || name == "move-receipt") {
    set_scalar(current, name, value)
  }
  next
}

END {
  if (marker["todo"] != 1) report(todo_name " 必须声明 <!-- ledger:v2 -->")
  if (marker["done"] != 1) report(done_name " 必须声明 <!-- ledger:v2 -->")
  if (ledger_records["todo"] == 0) report(todo_name " 中没有 TASK 记录")
  if (ledger_records["done"] == 0) report(done_name " 中没有 TASK 记录")
  for (id in cross_ledger_id) report("TASK ID 同时出现在 " todo_name " 和 " done_name ": " id)

  for (record=1; record<=records; record++) {
    id=task_id[record]
    state=need(record, "state")
    rev=need(record, "rev")
    rq=need(record, "rq")
    deps=need(record, "deps")
    owner=need(record, "owner")
    claim=need(record, "claim")
    tracking=need(record, "tracking")
    updated=need(record, "updated")
    generic_evidence=field_value[field_key(record, "evidence")]
    blocker=need(record, "blocker")
    handoff=need(record, "handoff")
    ci_scope=need(record, "ci-scope")
    if (rev != "" && rev !~ /^[1-9][0-9]*$/) report("rev 必须是正整数: " id " " rev)
    if (!(id in state_by_id)) {
      state_by_id[id]=state
      outcome_by_id[id]=field_value[field_key(record, "outcome")]
    }

    check_optional_scalar(record, "evidence")
    check_optional_scalar(record, "move")
    check_optional_scalar(record, "cancellation-reason")
    check_optional_scalar(record, "superseded-by")
    check_optional_scalar(record, "rollback-reason")
    check_optional_scalar(record, "outcome")
    check_optional_scalar(record, "successor-route")
    check_optional_scalar(record, "amendment-receipt")
    check_optional_scalar(record, "move-receipt")

    if (task_ledger[record] == "todo") {
      if (state != "ready" && state != "claimed" && state != "blocked") {
        report("todo state 非法: " id " " state)
      }
      if (state == "claimed") {
        if (owner == "none" || claim == "none" || owner == "" || claim == "") report("state/claim 不一致: " id)
      } else if ((state == "ready" || state == "blocked") && (owner != "none" || claim != "none")) {
        report("state/claim 不一致: " id)
      }
      if ((state == "ready" || state == "claimed") && blocker != "none") report(state " 不得保留 blocker: " id)
      if (state == "blocked" && (blocker == "" || blocker == "none")) report("blocked 缺少具体 blocker: " id)
    } else {
      if (state != "accepted" && state != "cancelled" && state != "rolled-back") {
        report("done state 非法: " id " " state)
      }
      if ((owner == "none") != (claim == "none")) report("state/claim 不一致: " id)
    }

    validate_paths(record, "write", state)
    validate_paths(record, "artifact", state)
    parse_tracking(record, tracking)
    if (ci_scope != "") validate_ci_scope(record, ci_scope)
    validate_effects(record)

    task_acceptances=0
    task_evidence=0
    for (key in acceptance) {
      split(key, parts, SUBSEP)
      if (parts[1] != record) continue
      task_acceptances++
      if (acceptance_count[key] > 1) report("acceptance ID 重复: " id " " parts[2])
      if (state == "accepted" && !(key in evidence)) {
        report("accepted 缺少 evidence " parts[2] ": " id)
      } else if (state == "accepted" && (evidence_value[key] == "" || evidence_value[key] == "none")) {
        report("accepted evidence " parts[2] " 为空: " id)
      }
    }
    for (key in evidence) {
      split(key, parts, SUBSEP)
      if (parts[1] != record) continue
      task_evidence++
      if (evidence_count[key] > 1) report("evidence ID 重复: " id " " parts[2])
      if (state == "accepted" && !(key in acceptance)) report("evidence 无对应 acceptance: " id " " parts[2])
    }
    if (task_acceptances == 0) report("缺少 acceptance: " id)
    if (state != "accepted") {
      if (!(field_key(record, "evidence") in field_count)) report("缺少字段 evidence: " id)
      else if (generic_evidence != "none") report("evidence 必须为 none: " id)
    }
    if (state == "cancelled" && task_evidence > 0) report("cancelled 不得登记 AC evidence: " id)

    if (state == "cancelled") {
      reason=need(record, "cancellation-reason")
      successor=need(record, "superseded-by")
      if (reason == "" || reason == "none") report("cancelled 缺少 cancellation-reason: " id)
      if (successor == "" || successor == "none") report("cancelled 缺少 superseded-by: " id)
    }
    if (state == "rolled-back") {
      rollback=need(record, "rollback-reason")
      if (rollback == "" || rollback == "none") report("rolled-back 缺少 rollback-reason: " id)
    }
    if (task_ledger[record] == "done") {
      move=need(record, "move")
      if (move == "none") report("done 缺少 move token: " id)
      else if (move != "" && move in move_owner) {
        if (!move_reported[move]) {
          report("done move token 重复: " move " (" move_owner[move] ", " id ")")
          move_reported[move]=1
        }
      } else if (move != "") {
        move_owner[move]=id
      }
    }

    clean_deps=deps
    gsub(/[[:space:]]/, "", clean_deps)
    if (clean_deps != "" && clean_deps != "none") {
      dep_count=split(clean_deps, dep_items, ",")
      for (number=1; number<=dep_count; number++) {
        dep=dep_items[number]
        base=dep
        conditional=(index(dep, "@") > 0)
        if (conditional) sub(/@.*/, "", base)
        if (conditional && !(id == "TASK-OPS-R1-BOOTSTRAP-001" && dep == "TASK-GATE-R0-002@continue")) {
          report("非法条件依赖: " id " -> " dep)
        }
        if (!valid_task_id(base)) {
          report("依赖 Task ID 格式错误: " id " -> " dep)
          continue
        }
        dep_key=record SUBSEP base
        if (dep_key in dependency_seen) report("依赖重复: " id " -> " dep)
        dependency_seen[dep_key]=1
        dependency_count[record]++
        dependency[record SUBSEP dependency_count[record]]=dep
        dependency_base[record SUBSEP dependency_count[record]]=base
        edge_count++
        edge_from[edge_count]=id
        edge_to[edge_count]=base
      }
    }
    if (id == "TASK-OPS-R1-BOOTSTRAP-001" && clean_deps != "TASK-GATE-R0-002@continue") {
      report("bootstrap bridge 必须仅依赖 TASK-GATE-R0-002@continue")
    }
  }

  for (record=1; record<=records; record++) {
    id=task_id[record]
    state=field_value[field_key(record, "state")]
    for (number=1; number<=dependency_count[record]; number++) {
      dep=dependency[record SUBSEP number]
      base=dependency_base[record SUBSEP number]
      if (!(base in all_id)) {
        report("依赖不存在: " id " -> " dep)
        continue
      }
      if ((state == "ready" || state == "claimed" || state == "accepted") && state_by_id[base] != "accepted") {
        report(state " 依赖尚未 accepted: " id " -> " base)
      }
      if ((state == "ready" || state == "claimed" || state == "accepted") &&
          index(dep, "@") > 0 && outcome_by_id[base] != "continue") {
        report(state " 条件依赖尚未 continue: " id " -> " dep)
      }
      if (id == "TASK-GATE-R0-002" && base == "TASK-OPS-003") report("R0 Gate 不得依赖 TASK-OPS-003")
    }
    if (state == "cancelled") {
      successor=field_value[field_key(record, "superseded-by")]
      if (successor != "" && successor != "none" && !(successor in all_id)) {
        report("superseded-by 不存在: " id " -> " successor)
      }
    }
  }

  if (!("TASK-GATE-R0-002" in all_id)) report("缺少 TASK-GATE-R0-002")
  if (!("TASK-OPS-R1-BOOTSTRAP-001" in all_id)) report("缺少 TASK-OPS-R1-BOOTSTRAP-001")
  if ("TASK-GATE-R0-002" in all_id) {
    gate_record=first_record["TASK-GATE-R0-002"]
    gate_state=field_value[field_key(gate_record, "state")]
    gate_outcome_key=field_key(gate_record, "outcome")
    gate_outcome=field_value[gate_outcome_key]
    if (!(gate_outcome_key in field_count) || gate_outcome == "" ||
        (gate_state == "accepted" && gate_outcome == "none")) {
      if (gate_state == "accepted") report("accepted Gate 缺少 outcome: TASK-GATE-R0-002")
      else report("缺少字段 outcome: TASK-GATE-R0-002")
    } else if (gate_state == "accepted" && gate_outcome != "continue" && gate_outcome != "pivot" && gate_outcome != "stop") {
      report("accepted Gate outcome 非法: TASK-GATE-R0-002 " gate_outcome)
    } else if (gate_state != "accepted" && gate_outcome != "none") {
      report("Gate 未 accepted 不得记录 outcome: " gate_outcome)
    }
  }

  active_count=0
  for (record=1; record<=records; record++) {
    if (task_ledger[record] == "todo" && field_value[field_key(record, "state")] == "claimed") {
      active[++active_count]=record
    }
  }
  for (left_number=1; left_number<=active_count; left_number++) {
    left=active[left_number]
    for (right_number=left_number + 1; right_number<=active_count; right_number++) {
      right=active[right_number]
      conflict=0
      for (left_scope=1; left_scope<=list_size(left, "write") && !conflict; left_scope++) {
        left_value=list_item(left, "write", left_scope)
        if (left_value == "none") continue
        for (right_scope=1; right_scope<=list_size(right, "write"); right_scope++) {
          right_value=list_item(right, "write", right_scope)
          if (right_value != "none" && scope_overlap(left_value, right_value)) {
            conflict=1
            break
          }
        }
      }
      if (conflict) report("active write scope 冲突: " task_id[left] " <-> " task_id[right])
    }
  }

  for (id in all_id) color[id]=0
  for (id in all_id) if (color[id] == 0) visit(id)

  if (errors == 0) {
    print "✓ task ledger v2 valid (" records " tasks)"
    exit 0
  }
  print "ledger validation failed: " errors " error(s)" > "/dev/stderr"
  exit 1
}
' "$TODO" "$DONE"
