# Task Ledger v2 契约

> 文档类型：Reference
>
> 适用范围：当前仓库的 `todo.md` 与 `done.md`

这是当前迁移需要的最小 Markdown 契约。它保护会制造虚假终态或并行写冲突的
不变量，不是通用 Markdown parser、GitHub 投影框架或 CI 影响分析器。

## 验证入口

```bash
scripts/check-task-ledger.sh todo.md done.md
```

两个输入都必须存在，并且各自声明 `<!-- ledger:v2 -->`。`todo.md` 和
`done.md` 必须分别至少解析到一个 `TASK`；任意一份空转都必须失败。成功返回
0，契约违反返回 1，用法或输入文件错误返回 2。

Task 块以下列标题开始：

```text
## TASK-<UPPERCASE-ID> | <title>
```

Task ID 在单个账本内不得重复，也不得同时出现在 `todo.md` 和 `done.md`。
未列在下文的历史字段可以保留；validator 不借它们推导新状态。

## 状态与 Claim

`todo.md` 只允许：

- `ready`：依赖已满足，`owner: none` 且 `claim: none`。
- `claimed`：正在写入，`owner` 和 `claim` 都必须是具体值。
- `blocked`：依赖或路径尚未满足，`owner: none` 且 `claim: none`，并记录非空
  `blocker`。

`done.md` 只允许 `accepted`、`cancelled` 和 `rolled-back`。终态块保留历史
owner/claim：两者要么都是 `none`，要么都是具体值，不得只留一个。

每个块有唯一的 `state`、`rev`、`rq`、`deps`、`owner`、`claim`、`tracking`、
`updated`、`blocker`、`handoff` 和 `ci-scope`。另外至少有一行 `write`、一行
`artifact`、一条 `accept AC-*` 和一行 `effect`。`rev` 是 steward 做 CAS 时使用的
单一正整数；metadata 迁移也要递增它并更新 `updated`。Validator 不伪造分布式事务。

## 依赖

`deps` 是逗号分隔的 Task ID，无依赖时写 `none`。所有目标必须存在，整幅图不得有环。
普通依赖只由 `accepted` 满足；`ready`、`claimed` 和 `accepted` 不得指向未
accepted 的目标。`blocked` 可以保留尚未满足的依赖。

当前唯一条条件依赖是：

```text
TASK-OPS-R1-BOOTSTRAP-001 -> TASK-GATE-R0-002@continue
```

bootstrap bridge 必须精确使用这条 `deps`，任何其他 Task、目标或条件后缀都是
错误。该条件只在 Gate 为 `accepted` 且记录 `outcome: continue` 时满足；
`pivot` 或 `stop` 不能解锁 R1。Gate 的 `accepted` 只证明方法和证据完整，
`outcome` 是独立结论：未 accepted 时只能是 `none`，accepted 时必须且只能是
`continue`、`pivot` 或 `stop`。`TASK-OPS-003` 这类 GitHub 清理任务不得成为 R0 Gate 依赖。

## Acceptance 与终态

- `accepted` 的每个 `accept AC-N` 必须有同号 `evidence AC-N`。GitHub Issue 关闭或
  commit 存在不能自动代替 evidence；该 evidence 的值不得为空或 `none`。
- `cancelled` 保留原 `accept AC-*`，不得登记 `evidence AC-*` 伪造完成；它必须记录非空
  `cancellation-reason` 和指向现存 Task 的 `superseded-by`。
- `rolled-back` 保留原 acceptance 与历史 claim，并记录非空 `rollback-reason`。
- `done.md` 的每个 Task 必须有非空 `move` token，且 token 在整份 done ledger
  中唯一。它是一次 todo -> done 控制面移动的幂等 receipt，不能被多个 Task 共用。

## Write Scope

`write` 和 `artifact` 只允许 `none` 或 `repo:` 开头的相对路径。路径不得是
绝对地址，不得包含 glob、`.`、`..` 或中间空路径段；目录末尾的 `/`
可以保留。`ready` 和 `claimed` 必须同时有
具体 write 和 artifact；尚等待路径决定的 `blocked` 任务可写 `none`。

只有 `claimed` 任务的 scope 是当前 active write scope。两个 active scope 完全相同，
或一个是另一个的目录前缀，都算冲突。`todo.md` 和 `done.md` 是 steward 控制面，
worker 的 write scope 不借此授权改账本。

## Tracking

`tracking` 是分号分隔的以下 token，或 `none`：

```text
github:issue#<number>
github:pr#<number>
github:milestone#<number>
```

同一个 Issue 或 PR token 在两份 ledger 中只能作为一个 Task 的 primary tracking。
Milestone 是分组，可以共享。同一 PR 交付多个 Task 时，只在一个 Task 上作 primary
tracking；其他 Task 在 `evidence` 或 PR body 中列出该 PR，不重复 `tracking`。

## Effect 与 Undo

没有仓外效果时只需记录：

```text
- effect: none
```

`undo: none` 可以保留，但不是必填的冗余字段。

有效果时，每个可重复的 `effect`/`undo` 行使用同一个 `FX-*` ID：

```text
- effect: FX-GH-R0-PROJECTION; action=create successor objects
- undo: FX-GH-R0-PROJECTION; action=close created objects and retain audit history
```

每个 `FX-*` effect 都必须有同 ID undo，反向也一样；不允许 `none` 与 `FX-*`
在同一侧并存。不可逆
动作的人工批准引用由 ledger 正文保留；validator 不猜测一段文字是否真的可逆。

## CI Scope

每个 Task 保留一行最小 receipt，键的顺序固定：

```text
- ci-scope: required=<checks|none>; advisory=<checks|none>; n/a=<checks|none>; reason=<why>
```

`required` 只放能推翻当前 acceptance 的检查；`advisory` 有信息价值但不阻塞；
`n/a` 与当前改动无因果关系。列表值由逗号分隔或写 `none`，`reason` 不得为空。
同一分类中 `none` 不得和具体 check 并存，同一 check 也不得同时出现在两个
分类。Validator 只校验这四个键、token 结构与
分类不冲突，不硬编码当前 runner 或 check 名称，也不根据路径推断相关性。

本 Task 的 validator 只检查 receipt 存在与最小结构，不根据 diff 推导分类，也不等待远端 CI。
Task 4 负责统一 PR receipt 词汇、让 CI 调用 validator、在 AGENTS.md 公开入口，并为
分类一致性增加独立测试。pending CI 本身不改变 Task state。

## 测试边界

`tests/task-ledger.sh` 使用真实临时 Markdown fixture，先断言 fixture 确实抓到 Task，
再检查合法图与具体失败原因。`TASK_LEDGER_SKIP_ACTUAL=1` 只用于 ledger 迁移期间
单独跑 unit fixtures；常规运行始终验收仓库真实的 `todo.md` 和 `done.md`。
