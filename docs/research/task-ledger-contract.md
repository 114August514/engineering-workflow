# Task Ledger v2 契约

> 文档类型：Reference
>
> 适用范围：当前仓库的 `todo.md` 与 `done.md`

这是当前迁移需要的最小 Markdown 契约。它保护会制造虚假终态或并行写冲突的
不变量，不是通用 Markdown parser、GitHub 投影框架或 CI 影响分析器。

## 执行边界

`todo.md` 和 `done.md` 都必须存在，并且各自声明 `<!-- ledger:v2 -->`，两份账本
也必须分别至少包含一个 Task。当前仓库是软件工程 Domain，不把研究迁移 checker
作为产品脚本或产品回归测试长期入库；迁移期间使用过的一次性检查器在收尾时删除。

R0 `continue` 之前由 steward 在任务移动和 PR review 时按本契约核对关键不变量。
如果后续确实需要机器执行，应在外置 Mother 控制面中重新定义并以跨 Domain 证据验收，
不能从本仓的临时实现直接推导为通用能力。

Task 块以下列标题开始：

```text
## TASK-<UPPERCASE-ID> | <title>
```

Task ID 在单个账本内不得重复，也不得同时出现在 `todo.md` 和 `done.md`。
未列在下文的历史字段可以保留；不得借它们推导新状态。

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
单一正整数；metadata 迁移也要递增它并更新 `updated`。本契约不伪造分布式事务。

## 依赖

`deps` 是逗号分隔的 Task ID，无依赖时写 `none`。所有目标必须存在，整幅图不得有环。
普通依赖只由 `accepted` 满足；`ready`、`claimed` 和 `accepted` 不得指向未
accepted 的目标。`blocked` 可以保留尚未满足的依赖。

条件依赖在 Task ID 后追加一个 outcome：

```text
TASK-CONDITIONAL-001 -> TASK-DECISION-001@continue
```

后缀只允许 `continue`、`pivot` 或 `stop`。条件只在目标为 `accepted` 且其
`outcome` 与后缀相同时满足；目标必须显式保留 `outcome` 字段。未 accepted 的
Task 若有该字段只能写 `none`，accepted 时只能写三个枚举值之一。

当前路线使用哪一条条件桥、哪些任务不应进入 Gate，直接记录在 `todo.md`、迁移映射
和 decision 中审核，不写进 Domain 产品脚本。

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
- effect: FX-REMOTE-PROJECTION; action=create successor objects
- undo: FX-REMOTE-PROJECTION; action=close created objects and retain audit history
```

每个 `FX-*` effect 都必须有同 ID undo，反向也一样；不允许 `none` 与 `FX-*`
在同一侧并存。不可逆
动作的人工批准引用由 ledger 正文保留；本契约不猜测一段文字是否真的可逆。

## CI Scope

每个 Task 保留一行最小 receipt，键的顺序固定：

```text
- ci-scope: required=<checks|none>; advisory=<checks|none>; n/a=<checks|none>; reason=<why>
```

`required` 只放能推翻当前 acceptance 的检查；`advisory` 有信息价值但不阻塞；
`n/a` 与当前改动无因果关系。列表值由逗号分隔或写 `none`，`reason` 不得为空。
同一分类中 `none` 不得和具体 check 并存，同一 check 也不得同时出现在两个
分类。分类不硬编码当前 runner 或 check 名称，也不根据路径自动推断相关性；
pending CI 本身不改变 Task state。

## 工具边界

本次迁移的一次性检查覆盖过空输入、ID、依赖、条件 outcome、终态 evidence、move token、
write scope、effect/undo 与 CI receipt，并用故障注入确认不是假绿。该检查只构成迁移
receipt，不构成这个 skill 的产品能力，因此不保留 `scripts/check-task-ledger.sh` 或
`tests/task-ledger.sh`。长期约束依靠本契约、账本 diff 和 review；外置 Mother 是否需要
通用 checker，由后续跨 Domain 实验决定。
