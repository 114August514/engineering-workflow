# GitHub Roadmap 迁移映射

本文只记录从原 R0 路线到“可演化 Mother + 可替换 Capsule + 独立 Domain +
lab-only composition”的身份迁移。`planned` 表示尚未发生，不能作为实现或验收证据。

当前产品边界与 R0-R6 路线以
[`agent-collaboration-foundation.md`](agent-collaboration-foundation.md) 为唯一事实源；本文只负责
历史身份、外部对象与 mutation receipt。

`engineering-workflow` 仓库本身不归档、不改名为 Mother。它保留为软件工程 Domain，并在 R0
暂时承载研究控制面；只有 `accepted + continue` 后才把控制面迁入新建的外置 Mother。

## Keep

以下对象保留原身份、URL 和历史语义，不通过本次迁移改写：

| 对象 | 原身份 | 原 URL | 保留事实 |
| --- | --- | --- | --- |
| Issue #1 | `[TASK-DOC-001] 建立协作底座研究规格与任务账本` | [#1](https://github.com/114August514/engineering-workflow/issues/1) | 保留原 acceptance 与交付历史；由包含原交付物的 PR #14 使用 `Closes #1` 在 squash merge 时关闭 |
| Issue #2 | `[TASK-OPS-001] 为任务账本增加机器检查` | [#2](https://github.com/114August514/engineering-workflow/issues/2) | 保留原标题、正文与历史语义；外部对象本次未改动，本地实现路线因产品边界 cancelled |
| Issue #3 | `[TASK-RES-004] 设计四基线与预注册评测` | [#3](https://github.com/114August514/engineering-workflow/issues/3) | 继续产生 R0 评测证据 |
| Issue #7 | `[TASK-RES-003] 核验 MCP/ACP/A2A/AG-UI 协议边界` | [#7](https://github.com/114August514/engineering-workflow/issues/7) | 继续产生 R0 协议证据 |
| Issue #8 | `[TASK-RES-005] 收集第二垂直任务与领域评审者` | [#8](https://github.com/114August514/engineering-workflow/issues/8) | 继续产生 R0 领域证据 |
| Issue #9 | `[TASK-RES-001] 建立 claim/evidence 登记册` | [#9](https://github.com/114August514/engineering-workflow/issues/9) | 继续维护 R0 证据登记 |
| Issue #10 | `[TASK-RES-002] 固化 harness 能力与缺陷矩阵` | [#10](https://github.com/114August514/engineering-workflow/issues/10) | 继续产生 R0 harness 证据 |
| Milestone #1 | `R0 — Evidence & Boundary` | [Milestone #1](https://github.com/114August514/engineering-workflow/milestone/1) | 保留旧路线投影；不属于 `TASK-OPS-003`，待原任务全部终态后单独 closeout |
| PR #12 | `docs: TASK-DOC-001 建立协作底座研究规格与任务账本` | [PR #12](https://github.com/114August514/engineering-workflow/pull/12) | 保持 draft 且不合并；原 head 为 `agent/research-foundation@60b768c1fe6e118bc66d126577fe5b32930c62b3`；PR #14 squash merge 后由 `TASK-OPS-003` 关闭 |

旧 Milestone #2 至 #7 采用一条 grouped disposition：
[#2 `R5 — Cross-domain Generalization`](https://github.com/114August514/engineering-workflow/milestone/2)、
[#3 `R4 — Software Engineering Validation`](https://github.com/114August514/engineering-workflow/milestone/3)、
[#4 `R3 — Harness Adapters & Reference Runner`](https://github.com/114August514/engineering-workflow/milestone/4)、
[#5 `R6 — Productization & Standards`](https://github.com/114August514/engineering-workflow/milestone/5)、
[#6 `R1 — Collaboration Semantics & Conformance`](https://github.com/114August514/engineering-workflow/milestone/6)
和 [#7 `R2 — Assurance, Recovery & Human Attention`](https://github.com/114August514/engineering-workflow/milestone/7)
均保持原标题、正文与历史语义，不重命名或复用。本 R0 迁移不创建替代 R1-R6 Milestone；
只有 R0 `continue` 后由 Mother 创建具名 successor 时，才向旧对象追加链接与 closeout。

## Task Identity Closed Set

下表是本次迁移保留的 ledger identity 闭集。标题和状态取自当前 ledger；本映射不改变它们。

| Task | 原标题 | 原状态 | Disposition |
| --- | --- | --- | --- |
| `TASK-RES-000` | 完成初始证据扫描 | accepted | keep |
| `TASK-DEC-001` | 批准产品边界 | accepted | keep；新决定只追加，不改写原 acceptance |
| `TASK-DOC-001` | 建立研究规格与协作账本 | accepted | keep |
| `TASK-RES-001` | 建立 claim/evidence 登记册 | ready | keep 原状态与语义 |
| `TASK-RES-002` | 固化 harness 能力与缺陷矩阵 | ready | keep 原状态与语义 |
| `TASK-RES-003` | 核验协议边界 | ready | keep 原状态与语义 |
| `TASK-RES-004` | 设计四基线与预注册评测 | ready | keep 原状态与语义 |
| `TASK-RES-005` | 收集第二垂直任务与领域评审者 | ready | keep 原状态与语义 |
| `TASK-OPS-001` | 为任务账本增加机器检查 | cancelled | 保留原 AC，不在 Domain 仓库伪装实现；successor 指向条件化 Mother bootstrap |
| `TASK-EVAL-000` | 证明静态 skill 的行为价值 | blocked | keep 原状态与语义 |

## Supersede

下表记录旧 ledger 身份、已创建的 successor 与仍保持 open 的历史对象：

| 原对象或路线 | 新身份或路线 | 状态 |
| --- | --- | --- |
| `TASK-FORK-001` / [Issue #11](https://github.com/114August514/engineering-workflow/issues/11) | [`TASK-CAPSULE-000` / Issue #15](https://github.com/114August514/engineering-workflow/issues/15) | ledger cancelled；successor created/blocked；旧 Issue open，已追加 proposed-successor comment |
| 旧 R0 gate / [Issue #13](https://github.com/114August514/engineering-workflow/issues/13) | [`TASK-GATE-R0-002` / Issue #19](https://github.com/114August514/engineering-workflow/issues/19) | successor created/blocked；旧 Issue open，已追加 proposed-successor comment |
| `TASK-EVAL-001` | [`TASK-EXP-000` / Issue #17](https://github.com/114August514/engineering-workflow/issues/17) | ledger cancelled；successor created/blocked |
| `TASK-OPS-001` / [Issue #2](https://github.com/114August514/engineering-workflow/issues/2) | `TASK-OPS-R1-BOOTSTRAP-001` 后由外置 Mother 重新决定机器控制面 | ledger cancelled；原 Issue 未改动，不继承完成状态 |
| `TASK-ADR-001` | `TASK-DEC-002` + R1 topology evidence route | ledger cancelled；`TASK-DEC-002` accepted；successor route recorded |
| `TASK-CORE-001` | `TASK-DEC-002` + R1/R3 semantics and promotion evidence route | ledger cancelled；`TASK-DEC-002` accepted；successor route recorded |
| `TASK-CORE-002` | `TASK-DEC-002` + R1/R3 trace and promotion evidence route | ledger cancelled；`TASK-DEC-002` accepted；successor route recorded |
| `TASK-ADP-001` | `TASK-DEC-002` + R1/R3 Capsule Port evidence route | ledger cancelled；`TASK-DEC-002` accepted；successor route recorded |
| `TASK-ADP-002` | `TASK-DEC-002` + R1/R3 Capsule and portability evidence route | ledger cancelled；`TASK-DEC-002` accepted；successor route recorded |
| `TASK-ASR-001` | `TASK-DEC-002` + R2 mechanism evidence route | ledger cancelled；`TASK-DEC-002` accepted；successor route recorded |
| `TASK-SWE-001` | `TASK-DEC-002` + R1/R4 software-engineering evidence route | ledger cancelled；`TASK-DEC-002` accepted；successor route recorded |
| `TASK-SWE-002` | `TASK-DEC-002` + R4 confirmation evidence route | ledger cancelled；`TASK-DEC-002` accepted；successor route recorded |
| `TASK-GEN-001` | `TASK-DEC-002` + R5 second-vertical evidence route | ledger cancelled；`TASK-DEC-002` accepted；successor route recorded |
| `TASK-GEN-002` | `TASK-DEC-002` + R5 second-vertical evidence route | ledger cancelled；`TASK-DEC-002` accepted；successor route recorded |

旧 Task、Issue、Milestone、PR 和 acceptance 均不原地换义；新路线不继承未完成旧任务的
完成状态。`TASK-DEC-002` 已 accepted，旧 abstract-first Task 已按原 acceptance 进入
cancelled；旧 GitHub 对象仍保持 open，只追加 proposed-successor comment。

## Create

| 新对象 | 身份 | 状态 |
| --- | --- | --- |
| 迁移 PR | 承载已 accepted 的 `TASK-DEC-002` 与迁移工作；目标 `main`；独立 [PR #14](https://github.com/114August514/engineering-workflow/pull/14) | PR created, ready for review, unmerged；必须 squash merge |
| R0 successor Milestone | [`R0 - Evidence & Mother Choice`（#8）](https://github.com/114August514/engineering-workflow/milestone/8) | created, open |
| R0 Issue 1/6 | [`[TASK-CAPSULE-000] 选择并验证首个 Substrate Capsule`（#15）](https://github.com/114August514/engineering-workflow/issues/15) | created, blocked |
| R0 Issue 2/6 | [`[TASK-PACK-SWE-000] 切分软件工程 discovery 与 sealed holdout`（#16）](https://github.com/114August514/engineering-workflow/issues/16) | created, blocked |
| R0 Issue 3/6 | [`[TASK-EXP-000] 完成首个窄幅 proof-of-mechanism`（#17）](https://github.com/114August514/engineering-workflow/issues/17) | created, blocked |
| R0 Issue 4/6 | [`[TASK-OPS-002] 建立 R0 Tag 保护与相关 CI 规则`（#18）](https://github.com/114August514/engineering-workflow/issues/18) | created, ready |
| R0 Issue 5/6 | [`[TASK-GATE-R0-002] 验收 Evidence & Mother Choice`（#19）](https://github.com/114August514/engineering-workflow/issues/19) | created, blocked |
| R0 Issue 6/6 | [`[TASK-OPS-003] 迁移 PR 合入后归档旧路线对象`（#20）](https://github.com/114August514/engineering-workflow/issues/20) | created, blocked |

## Effects And Undo

- `FX-GH-R0-PROJECTION` (completed): effect = 创建 successor Milestone #8、Issue #15-#20，
  并给 #11、#13、PR #12 追加 proposed-successor comment；completed-at = `2026-07-29T15:10:58Z`；
  undo = 关闭新建对象，保留 audit events、评论与本映射。
- `FX-GH-R0-SUPERSEDE` (planned): effect = 仅在迁移 PR squash merge 后关闭 #11、#13 与 PR #12，
  并保留 successor links；undo = 重新打开被关闭对象，保留 successor links 与 audit。

## Receipts

| 动作 | 状态 | Receipt |
| --- | --- | --- |
| 核对 PR #12 身份与 head | completed | [PR #12](https://github.com/114August514/engineering-workflow/pull/12), `60b768c1fe6e118bc66d126577fe5b32930c62b3` |
| 写入迁移映射 | completed | `docs/research/github-roadmap-migration.md` |
| 创建或复用迁移 draft PR | completed | [PR #14](https://github.com/114August514/engineering-workflow/pull/14), created-at `2026-07-29T09:03:38Z` |
| 标记迁移 PR ready 并记录 merge-method decision | completed | [PR #14](https://github.com/114August514/engineering-workflow/pull/14), ready for review, unmerged；merge-method=`squash` |
| 记录 `TASK-DEC-002` superseding decision | completed | [ADR 0001](../decisions/0001-evolvable-mother-research-platform.md), commit `29a1450` |
| 创建 successor Milestone | completed | [Milestone #8](https://github.com/114August514/engineering-workflow/milestone/8), created-at `2026-07-29T15:08:49Z` |
| 创建六个 R0 Issue | completed | [#15](https://github.com/114August514/engineering-workflow/issues/15), [#16](https://github.com/114August514/engineering-workflow/issues/16), [#17](https://github.com/114August514/engineering-workflow/issues/17), [#18](https://github.com/114August514/engineering-workflow/issues/18), [#19](https://github.com/114August514/engineering-workflow/issues/19), [#20](https://github.com/114August514/engineering-workflow/issues/20); created-at `2026-07-29T15:10:09Z..15:10:10Z` |
| 校正 R0 AC 与 merge protocol 投影 | completed | [#16](https://github.com/114August514/engineering-workflow/issues/16) updated-at `2026-07-29T16:06:39Z`; [#17](https://github.com/114August514/engineering-workflow/issues/17) 与 [#20](https://github.com/114August514/engineering-workflow/issues/20) updated-at `2026-07-29T16:06:48Z`; [PR #14](https://github.com/114August514/engineering-workflow/pull/14) updated-at `2026-07-29T16:06:58Z`, code-head `1525d29` |
| 追加 proposed-successor links | completed | [#11 comment](https://github.com/114August514/engineering-workflow/issues/11#issuecomment-5119741963), [#13 comment](https://github.com/114August514/engineering-workflow/issues/13#issuecomment-5119742476), [PR #12 comment](https://github.com/114August514/engineering-workflow/pull/12#issuecomment-5119742752); completed-at `2026-07-29T15:10:58Z` |
| 关闭 #11、#13 与 PR #12 | planned after migration squash merge | not changed；由 [#20](https://github.com/114August514/engineering-workflow/issues/20) 承载 |
| Milestone #1 closeout | planned after its original tasks reach terminal states | not changed；outside `TASK-OPS-003` |
