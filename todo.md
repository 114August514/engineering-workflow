# TODO
<!-- ledger:v1 -->

通用人机协作底座的当前任务账本。产品边界和 roadmap 以
[`docs/research/agent-collaboration-foundation.md`](docs/research/agent-collaboration-foundation.md)
为唯一事实源；终态任务只进入 [`done.md`](done.md)。

## 控制协议

- 本协调周期的 ledger steward 是 `agent:root`。worker 不直接编辑两个账本。
- 控制面以 `task ID + expected rev + claim token` 做 CAS；成功后递增 `rev`。
- `state` 只允许 `ready`、`claimed`、`blocked`。只有 `accepted` 依赖可解锁任务。
- `tracking` 映射同仓库 GitHub Issue/PR/Milestone；`none` 表示尚未物化为外部工作项。
- `write` 是排他写范围，不包含账本控制文件；路径禁止绝对地址、glob 和 `..`。
- `ready`/`claimed` 必须有具体 write/artifact；等待 ADR 定路径的 blocked 任务使用 `none`。
- handoff 先记录 checkpoint、下一步和风险，再释放 owner/claim；旧 claim 随即失效。
- 完成迁移由一次控制面事务或 Git commit 承载。无事务时先写 done、后删 todo。
- `effect FX-*` 必须匹配 `undo FX-*`；不可逆动作必须记录人工批准引用。
- 新并行任务 ID 由 steward 分配 run namespace，禁止 worker 竞争下一个序号。

## TASK-RES-001 | 建立 claim/evidence 登记册
- state: ready
- rev: 2
- rq: RQ-00,RQ-01,RQ-02,RQ-03,RQ-04,RQ-05,RQ-06,RQ-07,RQ-08,RQ-09,RQ-10
- deps: TASK-RES-000
- owner: none
- claim: none
- tracking: github:issue#9; github:milestone#1
- updated: 2026-07-29T02:47:36+08:00
- write: repo:docs/research/evidence-register.md
- artifact: repo:docs/research/evidence-register.md
- accept AC-1: 每个核心产品 claim 记录证据等级、版本、方法、可支持与不可支持的结论
- accept AC-2: 每个 RQ 至少记录一个反证或失败后的产品决策
- evidence: none
- blocker: none
- handoff: none
- effect: none

## TASK-RES-002 | 固化 harness 能力与缺陷矩阵
- state: ready
- rev: 2
- rq: RQ-07,RQ-08
- deps: TASK-RES-000
- owner: none
- claim: none
- tracking: github:issue#10; github:milestone#1
- updated: 2026-07-29T02:47:36+08:00
- write: repo:docs/research/harness-capability-matrix.md
- artifact: repo:docs/research/harness-capability-matrix.md
- accept AC-1: 覆盖 12-factor-agents、OpenHarness、oh-my-pi、Kimi Code、Claude Code
- accept AC-2: 机制结论链接官方源码或文档，效果未知明确标记且不使用 star 数作证
- evidence: none
- blocker: none
- handoff: none
- effect: none

## TASK-RES-003 | 核验协议边界
- state: ready
- rev: 2
- rq: RQ-03,RQ-07
- deps: TASK-RES-000
- owner: none
- claim: none
- tracking: github:issue#7; github:milestone#1
- updated: 2026-07-29T02:47:36+08:00
- write: repo:docs/research/protocol-boundaries.md
- artifact: repo:docs/research/protocol-boundaries.md
- accept AC-1: MCP、ACP、A2A、AG-UI 的稳定能力和限制均采用官方规范核验
- accept AC-2: 每个拟自定义字段先给出现有 extension、metadata 或 custom event 承载结论
- evidence: none
- blocker: none
- handoff: none
- effect: none

## TASK-RES-004 | 设计四基线与预注册评测
- state: ready
- rev: 2
- rq: RQ-00,RQ-01,RQ-02,RQ-04,RQ-05,RQ-08
- deps: TASK-RES-000
- owner: none
- claim: none
- tracking: github:issue#3; github:milestone#1
- updated: 2026-07-29T02:47:36+08:00
- write: repo:docs/research/evaluation-design.md
- artifact: repo:docs/research/evaluation-design.md
- accept AC-1: 定义任务语料、评分量表、H/A/C/R 基线、机制消融、主指标和混淆因素
- accept AC-2: 主因果对比固定为同条件 R-C，pilot 只定标 MME 和功效而不宣告成功
- evidence: none
- blocker: none
- handoff: none
- effect: none

## TASK-RES-005 | 收集第二垂直任务与领域评审者
- state: ready
- rev: 2
- rq: RQ-09
- deps: TASK-RES-000
- owner: none
- claim: none
- tracking: github:issue#8; github:milestone#1
- updated: 2026-07-29T02:47:36+08:00
- write: repo:docs/research/second-vertical-corpus.md
- artifact: repo:docs/research/second-vertical-corpus.md
- accept AC-1: 至少比较 research-to-decision 与两个替代垂直的对象、副作用和验证器差异
- accept AC-2: 每个候选都有真实领域 owner、可取得任务、评审方式和隐私边界
- evidence: none
- blocker: none
- handoff: none
- effect: none

## TASK-DOC-002 | 迁移 canonical roadmap 与历史映射
- state: claimed
- rev: 1
- rq: none
- deps: TASK-DEC-002
- owner: agent:root
- claim: run:canonical-roadmap-migration-20260729T174209p0800
- tracking: github:pr#14
- updated: 2026-07-29T17:42:09+08:00
- write: repo:docs/research/agent-collaboration-foundation.md
- write: repo:docs/superpowers/specs/2026-07-29-review-remediation-design.md
- write: repo:README.md
- write: repo:docs/superpowers/specs/2026-07-29-evolvable-mother-research-platform-design.md
- write: repo:docs/research/github-roadmap-migration.md
- artifact: repo:docs/research/agent-collaboration-foundation.md
- artifact: repo:docs/superpowers/specs/2026-07-29-review-remediation-design.md
- artifact: repo:README.md
- artifact: repo:docs/superpowers/specs/2026-07-29-evolvable-mother-research-platform-design.md
- artifact: repo:docs/research/github-roadmap-migration.md
- accept AC-1: canonical roadmap 保留既有来源、RQ、H/A/C/R、证据等级与多 Agent ledger 协议，并写明 Mother/Capsule/Domain/lab、R0/R1 manifest 和 R0-R6 Gate
- accept AC-2: decision history 明确保留与取代范围，且 canonical roadmap 能回答 continue、pivot 和 stop
- accept AC-3: 历史补救设计追加 supersession notice，README、design、migration map 与 ledger 指向同一当前事实源且文档链接通过
- evidence: none
- blocker: none
- handoff: none
- effect: none

## TASK-FORK-001 | 运行 Component Intake Gate
- state: ready
- rev: 2
- rq: RQ-07,RQ-10
- deps: TASK-RES-000
- owner: none
- claim: none
- tracking: github:issue#11; github:milestone#1
- updated: 2026-07-29T02:47:36+08:00
- write: repo:docs/research/component-intake.md
- artifact: repo:docs/research/component-intake.md
- accept AC-1: Kimi Code、OpenHarness、oh-my-pi、Claude SDK 均有 adopt/fork/adapt/build 结论
- accept AC-2: 记录硬能力、许可证、上游 commit、测试、安全、patch budget、12 个月 TCO 和退出方案
- accept AC-3: 至少完成一次候选升级演练设计，外部仓库保持只读
- evidence: none
- blocker: none
- handoff: none
- effect: none

## TASK-OPS-001 | 为任务账本增加机器检查
- state: claimed
- rev: 3
- rq: none
- deps: TASK-DOC-001
- owner: agent:root
- claim: run:task-ledger-validator-20260729T174121p0800
- tracking: github:issue#2; github:pr#14; github:milestone#1
- updated: 2026-07-29T17:41:21+08:00
- write: repo:docs/research/task-ledger-contract.md
- write: repo:scripts/check-task-ledger.sh
- write: repo:tests/task-ledger.sh
- write: repo:.github/workflows/ci.yml
- write: repo:AGENTS.md
- artifact: repo:docs/research/task-ledger-contract.md
- artifact: repo:scripts/check-task-ledger.sh
- artifact: repo:tests/task-ledger.sh
- accept AC-1: 校验器先断言 fixture 非空，再检查字段、ID、依赖、claim、tracking、scope、evidence 和 effect/undo
- accept AC-2: 重复 ID、todo/done 重叠、依赖环、scope 冲突、tracking 复用和缺证据分别给出准确失败原因
- accept AC-3: 故意破坏实现可使对应负例变红，脚本通过 Bash 3.2 与 BSD 工具链约束
- accept AC-4: CI 和 AGENTS.md 的验证入口都调用任务账本检查
- evidence: none
- blocker: none
- handoff: none
- effect: none

## TASK-EVAL-000 | 证明静态 skill 的行为价值
- state: blocked
- rev: 1
- rq: RQ-00
- deps: TASK-RES-004
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T02:14:24+08:00
- write: repo:docs/research/baselines/
- artifact: repo:docs/research/baselines/
- accept AC-1: 裸 harness 与静态 skill 至少完成 30 个同模型、同任务的配对 task-run
- accept AC-2: 盲评一致性达到 kappa 0.7，并报告成功、注意力、严重遗漏和负结果
- evidence: none
- blocker: deps:TASK-RES-004; need=评测设计先冻结任务、量表和停止条件
- handoff: none
- effect: none

## TASK-ADR-001 | 决定仓库拓扑与 fork 布局
- state: blocked
- rev: 1
- rq: RQ-03,RQ-07,RQ-10
- deps: TASK-RES-002,TASK-RES-003,TASK-FORK-001,TASK-EVAL-000
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T02:14:24+08:00
- write: repo:docs/decisions/
- artifact: repo:docs/decisions/
- accept AC-1: ADR 比较原仓扩展、monorepo 和独立 runtime 三条路径
- accept AC-2: 实现语言、fork 上游同步、Domain Pack 边界和退出策略都有明确决定
- evidence: none
- blocker: deps:TASK-RES-002,TASK-RES-003,TASK-FORK-001,TASK-EVAL-000; need=能力、协议、复用和价值基线完成
- handoff: none
- effect: none

## TASK-CORE-001 | 定义协作 glossary 与不变量
- state: blocked
- rev: 1
- rq: RQ-03,RQ-09
- deps: TASK-RES-001,TASK-RES-003
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T02:14:24+08:00
- write: repo:docs/research/collaboration-glossary.md
- artifact: repo:docs/research/collaboration-glossary.md
- accept AC-1: Actor、Objective、WorkItem、Decision、HumanTask、ActionEnvelope、Claim、Evidence、Verification、MemoryRecord、Handoff 均有边界
- accept AC-2: 核心定义不包含软件工程专用字段，冲突术语有唯一裁决
- evidence: none
- blocker: deps:TASK-RES-001,TASK-RES-003; need=证据登记与协议边界完成
- handoff: none
- effect: none

## TASK-CORE-002 | 定义核心 schema 与 golden traces
- state: blocked
- rev: 1
- rq: RQ-03,RQ-09
- deps: TASK-CORE-001,TASK-ADR-001
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T02:14:24+08:00
- write: none
- artifact: none
- accept AC-1: 核心 schema、状态投影、版本规则和三组 golden trace 可被 validator 读取
- accept AC-2: 相同版本输入重建相同状态，Domain Pack 字段只通过 extension 出现
- evidence: none
- blocker: deps:TASK-CORE-001,TASK-ADR-001; need=glossary 与仓库拓扑批准后由 ADR 指定路径
- handoff: none
- effect: none

## TASK-ADP-001 | 定义 Harness Adapter contract
- state: blocked
- rev: 1
- rq: RQ-03,RQ-07
- deps: TASK-RES-002,TASK-RES-003,TASK-CORE-001,TASK-ADR-001
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T02:14:24+08:00
- write: none
- artifact: none
- accept AC-1: 契约覆盖 start、resume、steer、cancel、approve、events、artifacts 和 usage
- accept AC-2: capability 明确区分 observe、advise、enforce，且不引用后端私有工具名
- evidence: none
- blocker: deps:TASK-RES-002,TASK-RES-003,TASK-CORE-001,TASK-ADR-001; need=输入完成并由 ADR 指定路径
- handoff: none
- effect: none

## TASK-ASR-001 | 设计保障、恢复与 Human Task
- state: blocked
- rev: 1
- rq: RQ-04,RQ-05,RQ-06
- deps: TASK-CORE-001,TASK-RES-004,TASK-ADR-001
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T02:14:24+08:00
- write: none
- artifact: none
- accept AC-1: role/decision rights、HumanTask、ActionEnvelope、policy order 和 compensation contract 有明确 schema
- accept AC-2: deny fail-closed，不可逆动作有升级路径，非幂等系统只承诺 receipt 与 reconciliation
- evidence: none
- blocker: deps:TASK-CORE-001,TASK-RES-004,TASK-ADR-001; need=术语、评测和拓扑完成
- handoff: none
- effect: none

## TASK-EVAL-001 | 建立四基线 evaluation harness
- state: blocked
- rev: 1
- rq: RQ-01,RQ-02,RQ-04,RQ-05,RQ-08
- deps: TASK-RES-004,TASK-CORE-001,TASK-EVAL-000,TASK-ADR-001
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T02:14:24+08:00
- write: none
- artifact: none
- accept AC-1: 同一输入可运行 H、A、C、R 并分别计量注意力、风险、时间和成本
- accept AC-2: 支持 Kernel 与 Assurance 消融、冻结 holdout 和故障注入
- evidence: none
- blocker: deps:TASK-RES-004,TASK-CORE-001,TASK-EVAL-000,TASK-ADR-001; need=设计、术语、静态基线和拓扑完成
- handoff: none
- effect: none

## TASK-ADP-002 | 打通两个执行后端
- state: blocked
- rev: 1
- rq: RQ-07,RQ-10
- deps: TASK-ADP-001,TASK-FORK-001,TASK-ADR-001
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T02:14:24+08:00
- write: none
- artifact: none
- accept AC-1: 一个官方商业后端和一个开源后端通过相同 conformance fixtures
- accept AC-2: 单 Agent 崩溃恢复、action ID、pause/resume 和 capability 降级均有证据
- evidence: none
- blocker: deps:TASK-ADP-001,TASK-FORK-001,TASK-ADR-001; need=契约、复用决定和拓扑完成
- handoff: none
- effect: none

## TASK-SWE-001 | 映射软件工程 Domain Pack
- state: blocked
- rev: 1
- rq: RQ-01,RQ-03,RQ-09
- deps: TASK-CORE-002,TASK-ASR-001,TASK-EVAL-001
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T02:14:24+08:00
- write: repo:docs/research/software-engineering-domain-pack.md
- artifact: repo:docs/research/software-engineering-domain-pack.md
- accept AC-1: 风险分流、闸门、journal、undo、审计和 traceability 均映射到 Domain Pack
- accept AC-2: Git、PR、测试、Make 和部署字段没有进入通用核心
- evidence: none
- blocker: deps:TASK-CORE-002,TASK-ASR-001,TASK-EVAL-001; need=核心、保障和评测实现完成
- handoff: none
- effect: none

## TASK-SWE-002 | 执行软件工程对照验证
- state: blocked
- rev: 1
- rq: RQ-00,RQ-01,RQ-02,RQ-04,RQ-05,RQ-06,RQ-08
- deps: TASK-SWE-001,TASK-ADP-002
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T02:14:24+08:00
- write: none
- artifact: none
- accept AC-1: 按预注册阈值报告 R-C、R-H、R-A、机制消融和置信区间
- accept AC-2: joint outcome、注意力、严重风险、恢复和经济性均入档，负结果不删除
- evidence: none
- blocker: deps:TASK-SWE-001,TASK-ADP-002; need=Domain Pack 与两个 adapter 完成
- handoff: none
- effect: none

## TASK-GEN-001 | 选择高对比第二垂直
- state: blocked
- rev: 1
- rq: RQ-09
- deps: TASK-RES-005,TASK-SWE-002
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T02:14:24+08:00
- write: repo:docs/research/second-vertical-selection.md
- artifact: repo:docs/research/second-vertical-selection.md
- accept AC-1: 按对象差异、副作用、验证器、真实任务、领域 owner 和风险评分
- accept AC-2: research-to-decision 默认候选与至少两个替代项有证据化比较
- evidence: none
- blocker: deps:TASK-RES-005,TASK-SWE-002; need=候选语料和第一垂直结果完成
- handoff: none
- effect: none

## TASK-GEN-002 | 实现并评测第二 Domain Pack
- state: blocked
- rev: 1
- rq: RQ-01,RQ-03,RQ-09
- deps: TASK-GEN-001
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T02:14:24+08:00
- write: none
- artifact: none
- accept AC-1: 至少 90% 核心不变且没有新增领域事件，未审批发布为零
- accept AC-2: 四基线结果可复现；失败时收缩通用性声明而不修改验收口径
- evidence: none
- blocker: deps:TASK-GEN-001; need=第二垂直获批且实现路径由 ADR 指定
- handoff: none
- effect: none
