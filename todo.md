# TODO
<!-- ledger:v2 -->

通用人机协作底座的当前任务账本。产品边界和 roadmap 以
[`docs/research/agent-collaboration-foundation.md`](docs/research/agent-collaboration-foundation.md)
为唯一事实源；账本格式见
[`docs/research/task-ledger-contract.md`](docs/research/task-ledger-contract.md)，终态任务只进入
[`done.md`](done.md)。

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
- rev: 3
- rq: RQ-00,RQ-01,RQ-02,RQ-03,RQ-04,RQ-05,RQ-06,RQ-07,RQ-08,RQ-09,RQ-10
- deps: TASK-RES-000
- owner: none
- claim: none
- tracking: github:issue#9; github:milestone#1
- updated: 2026-07-29T18:23:49+08:00
- write: repo:docs/research/evidence-register.md
- artifact: repo:docs/research/evidence-register.md
- accept AC-1: 每个核心产品 claim 记录证据等级、版本、方法、可支持与不可支持的结论
- accept AC-2: 每个 RQ 至少记录一个反证或失败后的产品决策
- evidence: none
- blocker: none
- handoff: none
- effect: none
- undo: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=current checks do not validate this research artifact

## TASK-RES-002 | 固化 harness 能力与缺陷矩阵
- state: ready
- rev: 3
- rq: RQ-07,RQ-08
- deps: TASK-RES-000
- owner: none
- claim: none
- tracking: github:issue#10; github:milestone#1
- updated: 2026-07-29T18:23:49+08:00
- write: repo:docs/research/harness-capability-matrix.md
- artifact: repo:docs/research/harness-capability-matrix.md
- accept AC-1: 覆盖 12-factor-agents、OpenHarness、oh-my-pi、Kimi Code、Claude Code
- accept AC-2: 机制结论链接官方源码或文档，效果未知明确标记且不使用 star 数作证
- evidence: none
- blocker: none
- handoff: none
- effect: none
- undo: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=current checks do not validate this research artifact

## TASK-RES-003 | 核验协议边界
- state: ready
- rev: 3
- rq: RQ-03,RQ-07
- deps: TASK-RES-000
- owner: none
- claim: none
- tracking: github:issue#7; github:milestone#1
- updated: 2026-07-29T18:23:49+08:00
- write: repo:docs/research/protocol-boundaries.md
- artifact: repo:docs/research/protocol-boundaries.md
- accept AC-1: MCP、ACP、A2A、AG-UI 的稳定能力和限制均采用官方规范核验
- accept AC-2: 每个拟自定义字段先给出现有 extension、metadata 或 custom event 承载结论
- evidence: none
- blocker: none
- handoff: none
- effect: none
- undo: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=current checks do not validate this research artifact

## TASK-RES-004 | 设计四基线与预注册评测
- state: ready
- rev: 3
- rq: RQ-00,RQ-01,RQ-02,RQ-04,RQ-05,RQ-08
- deps: TASK-RES-000
- owner: none
- claim: none
- tracking: github:issue#3; github:milestone#1
- updated: 2026-07-29T18:23:49+08:00
- write: repo:docs/research/evaluation-design.md
- artifact: repo:docs/research/evaluation-design.md
- accept AC-1: 定义任务语料、评分量表、H/A/C/R 基线、机制消融、主指标和混淆因素
- accept AC-2: 主因果对比固定为同条件 R-C，pilot 只定标 MME 和功效而不宣告成功
- evidence: none
- blocker: none
- handoff: none
- effect: none
- undo: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=current checks do not validate this research artifact

## TASK-RES-005 | 收集第二垂直任务与领域评审者
- state: ready
- rev: 3
- rq: RQ-09
- deps: TASK-RES-000
- owner: none
- claim: none
- tracking: github:issue#8; github:milestone#1
- updated: 2026-07-29T18:23:49+08:00
- write: repo:docs/research/second-vertical-corpus.md
- artifact: repo:docs/research/second-vertical-corpus.md
- accept AC-1: 至少比较 research-to-decision 与两个替代垂直的对象、副作用和验证器差异
- accept AC-2: 每个候选都有真实领域 owner、可取得任务、评审方式和隐私边界
- evidence: none
- blocker: none
- handoff: none
- effect: none
- undo: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=current checks do not validate this research artifact

## TASK-DOC-002 | 迁移 canonical roadmap 与历史映射
- state: claimed
- rev: 2
- rq: none
- deps: TASK-DEC-002
- owner: agent:root
- claim: run:canonical-roadmap-migration-20260729T174209p0800
- tracking: none
- updated: 2026-07-29T18:23:49+08:00
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
- undo: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=current checks do not validate canonical roadmap content

## TASK-OPS-001 | 为任务账本增加机器检查
- state: claimed
- rev: 4
- rq: none
- deps: TASK-DOC-001
- owner: agent:root
- claim: run:task-ledger-validator-20260729T174121p0800
- tracking: github:issue#2; github:milestone#1
- updated: 2026-07-29T18:23:49+08:00
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
- undo: none
- ci-scope: required=ubuntu,macos; advisory=none; n/a=none; reason=ledger shell and fixtures must work on both supported runners

## TASK-EVAL-000 | 证明静态 skill 的行为价值
- state: blocked
- rev: 2
- rq: RQ-00
- deps: TASK-RES-004
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T18:23:49+08:00
- write: repo:docs/research/baselines/
- artifact: repo:docs/research/baselines/
- accept AC-1: 裸 harness 与静态 skill 至少完成 30 个同模型、同任务的配对 task-run
- accept AC-2: 盲评一致性达到 kappa 0.7，并报告成功、注意力、严重遗漏和负结果
- evidence: none
- blocker: deps:TASK-RES-004; need=评测设计先冻结任务、量表和停止条件
- handoff: none
- effect: none
- undo: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=blocked task has no delivered change or acceptance claim

## TASK-CAPSULE-000 | 选择并验证首个 Substrate Capsule
- state: blocked
- rev: 1
- rq: RQ-07,RQ-10
- deps: TASK-RES-002,TASK-RES-003
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T18:23:49+08:00
- write: repo:experiments/r0/capsule-spike/
- artifact: repo:experiments/r0/capsule-spike/
- accept AC-1: OpenHarness-derived spike 记录 upstream、fork-point、许可证、实际 patch、测试与可运行 receipt
- accept AC-2: 至少与一个结构不同候选按相同最小任务比较能力、维护成本和退出路径
- accept AC-3: 形成选择或拒绝首个 Capsule 的具名结论，不发布 harness-neutral 声明
- evidence: none
- blocker: deps:TASK-RES-002,TASK-RES-003; need=能力矩阵与协议边界先形成候选输入
- handoff: none
- effect: none
- undo: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=blocked task has no delivered change or acceptance claim

## TASK-PACK-SWE-000 | 切分软件工程 discovery 与 sealed holdout
- state: blocked
- rev: 1
- rq: RQ-01,RQ-04,RQ-08
- deps: TASK-RES-004
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T18:23:49+08:00
- write: repo:experiments/r0/task-packs/software-engineering/
- artifact: repo:experiments/r0/task-packs/software-engineering/
- accept AC-1: discovery、pilot 与 sealed holdout 有互斥任务身份、版本和泄漏审计
- accept AC-2: 任务、评分量表、H/A/C/R 基线与 evaluator 在揭示 holdout 前冻结
- evidence: none
- blocker: deps:TASK-RES-004; need=预注册评测先定义语料与停止条件
- handoff: none
- effect: none
- undo: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=blocked task has no delivered change or acceptance claim

## TASK-EXP-000 | 完成首个窄幅 proof-of-mechanism
- state: blocked
- rev: 1
- rq: RQ-00,RQ-01,RQ-02,RQ-04,RQ-05,RQ-06,RQ-08
- deps: TASK-CAPSULE-000,TASK-PACK-SWE-000,TASK-RES-004
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T18:23:49+08:00
- write: repo:experiments/r0/proof-of-mechanism/
- artifact: repo:experiments/r0/proof-of-mechanism/
- accept AC-1: 同一 Capsule、任务、模型与预算下预注册 treatment、sham、MME 和停止条件
- accept AC-2: trace、artifact、结果与失败 episode 可重放，负结果不被改写为机制成功
- evidence: none
- blocker: deps:TASK-CAPSULE-000,TASK-PACK-SWE-000,TASK-RES-004; need=Capsule、任务包与评测设计就绪
- handoff: none
- effect: none
- undo: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=blocked task has no delivered change or acceptance claim

## TASK-OPS-002 | 建立 R0 Tag 保护与相关 CI 规则
- state: blocked
- rev: 1
- rq: none
- deps: TASK-OPS-001
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T18:23:49+08:00
- write: repo:.github/workflows/ci.yml
- write: repo:docs/research/r0-tag-protection.md
- artifact: repo:docs/research/r0-tag-protection.md
- accept AC-1: 相关 required checks、保护目标和终态等待点有版本化规则与 GitHub receipt
- accept AC-2: R0 Gate 未 accepted 且 outcome 非 continue 时不得创建 acceptance tag
- evidence: none
- blocker: deps:TASK-OPS-001; need=ledger validator 与 CI relevance 入口先完成
- handoff: none
- effect: FX-GH-R0-TAG-PROTECTION; action=create or update the scoped R0 ruleset after approval
- undo: FX-GH-R0-TAG-PROTECTION; action=restore the previous ruleset or remove the new ruleset and retain audit
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=blocked task has no delivered change or acceptance claim

## TASK-GATE-R0-002 | 验收 Evidence & Mother Choice
- state: blocked
- rev: 1
- rq: RQ-00,RQ-01,RQ-02,RQ-03,RQ-04,RQ-05,RQ-06,RQ-07,RQ-08,RQ-09,RQ-10
- deps: TASK-RES-001,TASK-RES-002,TASK-RES-003,TASK-RES-004,TASK-RES-005,TASK-EVAL-000,TASK-CAPSULE-000,TASK-PACK-SWE-000,TASK-EXP-000,TASK-OPS-002
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T18:23:49+08:00
- write: repo:docs/research/gates/r0.md
- artifact: repo:docs/research/gates/r0.md
- accept AC-1: 审计 R0 证据、proof-of-mechanism 与 pre-bootstrap manifest 的方法完整性和可重放性
- accept AC-2: 独立记录 outcome 为 continue、pivot 或 stop，并给出反证、限制与 successor route
- accept AC-3: accepted 只表示审计完整，不自动证明 Mother、Capsule 或通用机制有效
- evidence: none
- blocker: deps:R0-research-and-runtime-artifacts; need=全部具名依赖进入 accepted
- handoff: none
- effect: none
- undo: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=blocked task has no delivered change or acceptance claim
- outcome: none

## TASK-OPS-R1-BOOTSTRAP-001 | 创建 Mother/Capsule/lab 并把本仓作为 Domain 接入
- state: blocked
- rev: 1
- rq: none
- deps: TASK-GATE-R0-002@continue
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T18:23:49+08:00
- write: none
- artifact: none
- accept AC-1: 仅在 R0 Gate accepted 且 outcome 为 continue 后创建独立 Mother、Capsule 与 lab 仓库
- accept AC-2: lab 以 submodule 固定 Mother、Capsule、engineering-workflow Domain 的具名 exact commit
- evidence: none
- blocker: deps:TASK-GATE-R0-002@continue; need=Gate accepted 与 outcome continue 同时成立
- handoff: none
- effect: FX-GH-R1-BOOTSTRAP; action=create external Mother Capsule and lab repositories and add the Domain submodule
- undo: FX-GH-R1-BOOTSTRAP; action=archive newly created objects remove new submodule links and retain audit history
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=conditional bridge is not unlocked

## TASK-OPS-003 | 迁移 PR 合入后归档旧路线对象
- state: blocked
- rev: 1
- rq: none
- deps: TASK-DOC-002
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T18:23:49+08:00
- write: repo:docs/research/github-roadmap-migration.md
- artifact: repo:docs/research/github-roadmap-migration.md
- accept AC-1: PR #14 合入 main 后才给 #11、#13 与 PR #12 追加 successor link 并按历史语义归档
- accept AC-2: 每次 mutation 记录 URL、时间与 undo；Milestone #1 继续等待原任务终态后单独 closeout
- evidence: none
- blocker: deps:TASK-DOC-002; external=github:pr#14; need=merged-to-main before archiving #11,#13,PR#12; excluded=github:milestone#1
- handoff: none
- effect: FX-GH-R0-SUPERSEDE; action=archive issue#11 issue#13 and pr#12 after migration merge
- undo: FX-GH-R0-SUPERSEDE; action=reopen archived objects and retain successor comments and audit
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=blocked task has no delivered change or acceptance claim
