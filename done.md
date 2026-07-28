# DONE
<!-- ledger:v1 -->

通用人机协作底座的 append-only 完成账本。终态只允许 `accepted`、`cancelled`、
`rolled-back`；只有 `accepted` 可以满足依赖。对应 ID 不得继续出现在
[`todo.md`](todo.md)。

## TASK-RES-000 | 完成初始证据扫描
- state: accepted
- rev: 1
- rq: RQ-00,RQ-01,RQ-02,RQ-03,RQ-04,RQ-05,RQ-06,RQ-07,RQ-08,RQ-09,RQ-10
- deps: none
- owner: agent:root
- claim: run:initial-research-20260729
- updated: 2026-07-29T02:14:24+08:00
- write: repo:docs/research/agent-collaboration-foundation.md
- artifact: repo:docs/research/agent-collaboration-foundation.md
- accept AC-1: 核验五个 harness/方法项目、四个协议和高信度人机协作研究
- evidence AC-1: ref=repo:docs/research/agent-collaboration-foundation.md; sections=二,三,四,八
- accept AC-2: 非官方或无效果证据的来源不被提升为成熟度结论
- evidence AC-2: ref=repo:docs/research/agent-collaboration-foundation.md; result=114August514/claude-code 已降级为来源边界
- blocker: none
- handoff: none
- effect: none
- move: bootstrap:2026-07-29

## TASK-DEC-001 | 批准产品边界
- state: accepted
- rev: 1
- rq: RQ-01,RQ-03,RQ-07,RQ-09,RQ-10
- deps: TASK-RES-000
- owner: human:user
- claim: conversation:2026-07-29
- updated: 2026-07-29T02:14:24+08:00
- write: repo:docs/research/agent-collaboration-foundation.md
- artifact: repo:docs/research/agent-collaboration-foundation.md
- accept AC-1: 产品不重写完整 execution harness，自研协作语义、保障、评测和 adapter contract
- evidence AC-1: ref=conversation:2026-07-29; result=approved
- accept AC-2: 成熟开源组件通过 Component Intake Gate 后优先 fork/适配
- evidence AC-2: ref=conversation:2026-07-29; result=approved
- blocker: none
- handoff: none
- effect: none
- move: bootstrap:2026-07-29

## TASK-DOC-001 | 建立研究规格与协作账本
- state: accepted
- rev: 1
- rq: none
- deps: TASK-DEC-001
- owner: agent:root
- claim: run:research-spec-20260729
- updated: 2026-07-29T02:22:45+08:00
- write: repo:docs/research/agent-collaboration-foundation.md
- write: repo:todo.md
- write: repo:done.md
- write: repo:README.md
- artifact: repo:docs/research/agent-collaboration-foundation.md
- artifact: repo:todo.md
- artifact: repo:done.md
- accept AC-1: 研究规格明确问题、边界、RQ、证据、基线、stage gates、停止条件和协作协议
- evidence AC-1: ref=repo:docs/research/agent-collaboration-foundation.md
- accept AC-2: 任务账本包含固定字段、依赖、claim、write scope、acceptance 和恢复语义
- evidence AC-2: ref=repo:todo.md; ref=repo:done.md
- accept AC-3: 本仓库要求的文档与 shell 验证全部通过
- evidence AC-3: command=repository-required-verification; exit=0; at=2026-07-29T02:22:45+08:00
- blocker: none
- handoff: none
- effect: none
- move: bootstrap:2026-07-29
