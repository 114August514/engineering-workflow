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
- tracking: none
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
- tracking: none
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
- rev: 2
- rq: none
- deps: TASK-DEC-001
- owner: agent:root
- claim: run:research-spec-20260729
- tracking: github:issue#1; github:pr#12; github:milestone#1
- updated: 2026-07-29T02:48:29+08:00
- write: repo:docs/research/agent-collaboration-foundation.md
- write: repo:todo.md
- write: repo:done.md
- write: repo:README.md
- artifact: repo:docs/research/agent-collaboration-foundation.md
- artifact: repo:todo.md
- artifact: repo:done.md
- accept AC-1: 研究规格明确问题、边界、RQ、证据、基线、stage gates、停止条件和协作协议
- evidence AC-1: ref=repo:docs/research/agent-collaboration-foundation.md
- accept AC-2: 任务账本包含固定字段、依赖、claim、tracking、write scope、acceptance 和恢复语义
- evidence AC-2: ref=repo:todo.md; ref=repo:done.md
- accept AC-3: 本仓库要求的文档与 shell 验证全部通过
- evidence AC-3: command=repository-required-verification; exit=0; at=2026-07-29T02:48:29+08:00
- blocker: none
- handoff: none
- effect: none
- move: bootstrap:2026-07-29

## TASK-DEC-002 | 记录可演化 Mother superseding decision
- state: accepted
- rev: 1
- rq: RQ-01,RQ-03,RQ-07,RQ-09,RQ-10
- deps: TASK-DEC-001
- owner: human:user
- claim: conversation:2026-07-29-evolvable-mother-design
- tracking: github:pr#14
- updated: 2026-07-29T17:41:21+08:00
- write: repo:docs/decisions/0001-evolvable-mother-research-platform.md
- write: repo:docs/superpowers/specs/2026-07-29-evolvable-mother-research-platform-design.md
- write: repo:docs/research/github-roadmap-migration.md
- artifact: repo:docs/decisions/0001-evolvable-mother-research-platform.md
- artifact: repo:docs/superpowers/specs/2026-07-29-evolvable-mother-research-platform-design.md
- artifact: repo:docs/research/github-roadmap-migration.md
- accept AC-1: 批准 Mother、Capsule、Domain 与 lab 边界，engineering-workflow 保持软件工程 Domain 与 R0 临时控制面
- evidence AC-1: ref=repo:docs/decisions/0001-evolvable-mother-research-platform.md; sections=组件边界
- accept AC-2: R0 pre-bootstrap manifest 至少记录 experiment/preregistration 版本、当前仓库 commit、不同组件 path、OpenHarness upstream/fork-point、model/prompt/tool/config/evaluator hash、treatment/sham/budget/task-set 及 trace/artifact/result 引用；R1 起才以 submodule 固定外置三仓 commit
- evidence AC-2: ref=repo:docs/decisions/0001-evolvable-mother-research-platform.md; sections=Capsule候选与版本固定,R0-pre-bootstrap例外
- accept AC-3: 只有 TASK-GATE-R0-002 accepted 且 outcome 为 continue 才解锁 R1 bootstrap，continue/pivot/stop 均为合法结果
- evidence AC-3: ref=repo:docs/decisions/0001-evolvable-mother-research-platform.md; sections=R1解锁条件
- accept AC-4: TASK-DEC-001 原文与三项原则保留，只取代 abstract-first 顺序；OpenHarness-derived 保持可深改、可替换候选身份
- evidence AC-4: ref=repo:docs/decisions/0001-evolvable-mother-research-platform.md; sections=Capsule候选与版本固定,对TASK-DEC-001的影响; ref=conversation:2026-07-29; result=approved
- accept AC-5: decision、批准设计、实施计划和迁移映射互相可追踪，且不声称计划中的仓库、实验或 tag 已存在
- evidence AC-5: ref=repo:docs/decisions/0001-evolvable-mother-research-platform.md; sections=当前非事实; ref=repo:docs/superpowers/specs/2026-07-29-evolvable-mother-research-platform-design.md; ref=repo:docs/superpowers/plans/2026-07-29-evolvable-mother-roadmap-migration.md; ref=repo:docs/research/github-roadmap-migration.md; executed-by=agent:root
- blocker: none
- handoff: none
- effect: none
- move: roadmap-migration:task-dec-002:20260729
