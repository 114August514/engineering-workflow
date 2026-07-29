# ADR 0001：采用可演化 Mother 研究平台路线

- 状态：accepted
- 日期：2026-07-29
- 决策任务：`TASK-DEC-002`
- 批准设计：[可演化母体研究平台设计](../superpowers/specs/2026-07-29-evolvable-mother-research-platform-design.md)
- 实施计划：[可演化 Mother 研究路线迁移计划](../superpowers/plans/2026-07-29-evolvable-mother-roadmap-migration.md)
- 迁移映射：[GitHub Roadmap 迁移映射](../research/github-roadmap-migration.md)
- 被取代决定：`TASK-DEC-001` 的 abstract-first 研发顺序；原决定及其 acceptance 保持不变

## 背景

原路线先冻结 harness-neutral Core、Adapter contract 和通用对象，再接入执行后端与软件工程
Domain。当前没有运行实验足以支持这些抽象成为初始架构前提；继续按该顺序投入，会让待验证的
通用性先固化在接口中。

已批准设计改为先在固定执行组合上产生可反驳证据，再从重复实验、第二 Capsule 和第二垂直中
晋升通用机制。本 ADR 记录该 superseding decision，不把计划中的仓库、实验或阶段结果写成
已经存在的事实。

## 决定

### 组件边界

- **Mother** 是可演化研究母体，拥有 Workbench、实验协议、规范化 trace/artifact、evaluator、
  机制孵化与晋升记录。它不由某个执行 harness 定义，也不预先冻结尚未经实验需要的通用 Core。
- **Capsule** 封装具体执行底座，并通过当前实验所需的最小 Capsule Port 向 Mother 提供能力。
  Capsule 可以使用私有类型；跨边界的信息必须转换为 Mother 当前版本理解的最小结构。
- **Domain** 拥有领域产品语义与资产。`engineering-workflow` 继续是软件工程 Domain，并在 R0
  同时承担临时研究控制面；软件工程字段不因复用方便进入 Mother。
- **lab workspace** 只保存具体实验组合、预注册与运行 receipt，不成为 Mother、Capsule 或
  Domain 的业务源码仓。

### Capsule 候选与版本固定

OpenHarness-derived 只是第一个可替换的 Capsule 候选。它可以被深度修改、重构或替换；上游
类型、生命周期和 roadmap 不因此成为 Mother 的标准。

R1 起，lab workspace 使用 Git submodule 固定 Mother、Capsule 和 Domain 三个独立仓库的
具名 exact commit。submodule 只表达一次实验用了哪个版本，不表达 Mother 对 Capsule 或 Domain
源码的所有权。

### R0 pre-bootstrap 例外

R0 不创建或假设独立的 Mother、Capsule、lab 仓库。pre-bootstrap composition manifest 至少
记录以下可复现身份、版本和引用：

- experiment/preregistration 版本；
- 当前 `engineering-workflow` 仓库 commit；
- 彼此不同的 Mother prototype、Capsule spike 和 Domain path；
- OpenHarness upstream 与 fork-point；
- model、prompt、tool、config 和 evaluator hash；
- treatment、sham、budget 和 task-set；
- trace、artifact 和 result 引用。

同一个当前仓库 commit 不得被复制成三条 repository commit，借此伪造 three-repo composition。
R0 的路径组合是过渡性事实，不支持“外置三仓已经建立”的声明。

### R1 解锁条件

只有 `TASK-GATE-R0-002` 同时满足 `state: accepted` 和 `outcome: continue`，才解锁
`TASK-OPS-R1-BOOTSTRAP-001`，并在 R1 建立外置 Mother、Capsule 与 lab workspace，将当前
`engineering-workflow` 作为 Domain 接入。Gate 的 accepted 只证明方法与证据审计完整，不能
单独解锁 bootstrap。

`continue`、`pivot`、`stop` 都是合法结果。`pivot` 保留已有证据并登记 successor route；
`stop` 停止投入；二者都不能为了维持 roadmap 连贯性而改写成 `continue`。

### 对 TASK-DEC-001 的影响

`TASK-DEC-001` 的原文、acceptance 与历史证据保持不变。本 ADR 只 supersede 其
abstract-first 研发顺序，并继续保留三项原则：

1. 不从零重写完整 execution harness。
2. 优先复用经过 Component Intake 的成熟实现。
3. 用证据检验通用性，不把通用性当作预设结论。

## 后果

- R0 可以先检验材料性失败、首个 Capsule 的可维护性和窄机制的因果信号，不必先兑现完整
  通用 Runtime。
- Mother、Capsule、Domain 和 lab 的所有权边界可独立演化，但 R1 起必须显式维护跨仓 commit
  组合与重放 receipt。
- 首个 Capsule 或首个垂直的成功只能支持具名组合，不能发布 harness-neutral 或
  domain-neutral 声明。
- 负结果可以成为 accepted evidence；只有 Gate 的 `continue` 才推进到外置仓库 bootstrap。

## 撤销与后续取代

本决定可以由后续 ADR 取代。后续 ADR 必须引用本记录和触发它的具名证据，说明选择
`continue`、`pivot` 或 `stop` 的理由，并为仍需执行的工作登记 successor Task。撤销或取代只
改变后续路线，不回写 `TASK-DEC-001`、本 ADR 或既有实验 receipt 的历史含义。

若证据不支持平台化，可以退回松散项目组合；若证据否定首个 Capsule，可以替换 Capsule；若
通用性失败，可以把机制收缩到 Capsule 或 Domain。以上路径都不要求保留当前抽象或仓库拓扑。

## 当前非事实

本 ADR 的 accepted 不会自动创建 Mother、Capsule 或 lab 仓库，不会产生任何实验、Gate
outcome 或 tag，也不证明 OpenHarness-derived 已被选为 R1 Capsule。这些对象和结论只有在各自
任务交付并留下可核验 receipt 后才存在。
