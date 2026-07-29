# GitHub Roadmap 迁移映射

本文只记录从原 R0 路线到“可演化 Mother + 可替换 Capsule + 独立 Domain +
lab-only composition”的身份迁移。`planned` 表示尚未发生，不能作为实现或验收证据。

## Keep

以下对象保留原身份、URL 和历史语义，不通过本次迁移改写：

| 对象 | 原身份 | 原 URL | 保留事实 |
| --- | --- | --- | --- |
| Issue #1 | `[TASK-DOC-001] 建立协作底座研究规格与任务账本` | [#1](https://github.com/114August514/engineering-workflow/issues/1) | 保留原 acceptance 与交付历史 |
| Issue #2 | `[TASK-OPS-001] 为任务账本增加机器检查` | [#2](https://github.com/114August514/engineering-workflow/issues/2) | 保留原任务语义 |
| Issue #3 | `[TASK-RES-004] 设计四基线与预注册评测` | [#3](https://github.com/114August514/engineering-workflow/issues/3) | 继续产生 R0 评测证据 |
| Issue #7 | `[TASK-RES-003] 核验 MCP/ACP/A2A/AG-UI 协议边界` | [#7](https://github.com/114August514/engineering-workflow/issues/7) | 继续产生 R0 协议证据 |
| Issue #8 | `[TASK-RES-005] 收集第二垂直任务与领域评审者` | [#8](https://github.com/114August514/engineering-workflow/issues/8) | 继续产生 R0 领域证据 |
| Issue #9 | `[TASK-RES-001] 建立 claim/evidence 登记册` | [#9](https://github.com/114August514/engineering-workflow/issues/9) | 继续维护 R0 证据登记 |
| Issue #10 | `[TASK-RES-002] 固化 harness 能力与缺陷矩阵` | [#10](https://github.com/114August514/engineering-workflow/issues/10) | 继续产生 R0 harness 证据 |
| Milestone #1 | `R0 — Evidence & Boundary` | [Milestone #1](https://github.com/114August514/engineering-workflow/milestone/1) | 保留旧路线投影，不重命名为新 R0 |
| PR #12 | `docs: TASK-DOC-001 建立协作底座研究规格与任务账本` | [PR #12](https://github.com/114August514/engineering-workflow/pull/12) | 保持 draft；原 head 为 `agent/research-foundation@60b768c1fe6e118bc66d126577fe5b32930c62b3` |

## Supersede

这些是迁移决定，不表示外部对象已经被修改：

| 原对象或路线 | 新身份或路线 | 状态 |
| --- | --- | --- |
| `TASK-FORK-001` / [Issue #11](https://github.com/114August514/engineering-workflow/issues/11) | `[TASK-CAPSULE-000] 选择并验证首个 Substrate Capsule` | planned |
| 旧 R0 gate / [Issue #13](https://github.com/114August514/engineering-workflow/issues/13) | `[TASK-GATE-R0-002] 验收 Evidence & Mother Choice` | planned |
| 先抽象 Core、Adapter、Assurance 再运行实验的任务顺序 | 由 `TASK-DEC-002` 追加 superseding decision；后续实现只从保留 Issue 的证据和独立 `TASK-EXP-*` / `TASK-PROMOTE-*` 路线产生 | planned |

旧 Task、Issue、Milestone、PR 和 acceptance 均不原地换义；新路线不继承未完成旧任务的
完成状态。

## Create

| 新对象 | 身份 | 状态 |
| --- | --- | --- |
| 迁移 PR | `TASK-DEC-002`；目标 `main`；独立 [draft PR #14](https://github.com/114August514/engineering-workflow/pull/14) | completed |
| R0 successor Milestone | `R0 - Evidence & Mother Choice` | planned, not created |
| R0 Issue 1/6 | `[TASK-CAPSULE-000] 选择并验证首个 Substrate Capsule` | planned, not created |
| R0 Issue 2/6 | `[TASK-PACK-SWE-000] 切分软件工程 discovery 与 sealed holdout` | planned, not created |
| R0 Issue 3/6 | `[TASK-EXP-000] 完成首个窄幅 proof-of-mechanism` | planned, not created |
| R0 Issue 4/6 | `[TASK-OPS-002] 建立 R0 Tag 保护与相关 CI 规则` | planned, not created |
| R0 Issue 5/6 | `[TASK-GATE-R0-002] 验收 Evidence & Mother Choice` | planned, not created |
| R0 Issue 6/6 | `[TASK-OPS-003] 迁移 PR 合入后归档旧路线对象` | planned, not created |

## Effects And Undo

- `FX-R0-PROJECTION` (planned): 迁移 PR 合入后才创建 successor Milestone 与六个 Issue；
  新 gate 链接保留的证据 Issue，#11、#13 和 Milestone #1 只追加 supersession/归档记录。
  创建前可通过撤销迁移决定停止；创建后不删除历史，而以关闭说明和后继决定撤销投影。
- `FX-LATER-SUPERSESSION` (standing rule): 若新证据再次改变路线，新增 decision 与映射，
  保留本 PR、Milestone 和 Issue。撤销后继决定也使用新的 append-only decision，不回写历史。

## Receipts

| 动作 | 状态 | Receipt |
| --- | --- | --- |
| 核对 PR #12 身份与 head | completed | [PR #12](https://github.com/114August514/engineering-workflow/pull/12), `60b768c1fe6e118bc66d126577fe5b32930c62b3` |
| 写入迁移映射 | completed | `docs/research/github-roadmap-migration.md` |
| 创建或复用迁移 draft PR | completed | [PR #14](https://github.com/114August514/engineering-workflow/pull/14) |
| 创建 successor Milestone | planned | not created |
| 创建六个 R0 Issue | planned | not created |
| 修改 #11、#13 或 Milestone #1 | planned for later archival task | not changed by this task |
