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
- rev: 4
- rq: RQ-00,RQ-01,RQ-02,RQ-03,RQ-04,RQ-05,RQ-06,RQ-07,RQ-08,RQ-09,RQ-10
- deps: TASK-RES-000
- owner: none
- claim: none
- tracking: github:issue#9; github:milestone#8
- updated: 2026-07-30T00:35:28+08:00
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
- rev: 4
- rq: RQ-07,RQ-08
- deps: TASK-RES-000
- owner: none
- claim: none
- tracking: github:issue#10; github:milestone#8
- updated: 2026-07-30T00:35:28+08:00
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
- rev: 4
- rq: RQ-03,RQ-07
- deps: TASK-RES-000
- owner: none
- claim: none
- tracking: github:issue#7; github:milestone#8
- updated: 2026-07-30T00:35:28+08:00
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
- rev: 4
- rq: RQ-00,RQ-01,RQ-02,RQ-04,RQ-05,RQ-08
- deps: TASK-RES-000
- owner: none
- claim: none
- tracking: github:issue#3; github:milestone#8
- updated: 2026-07-30T00:35:28+08:00
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
- rev: 4
- rq: RQ-09
- deps: TASK-RES-000
- owner: none
- claim: none
- tracking: github:issue#8; github:milestone#8
- updated: 2026-07-30T00:35:28+08:00
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
- rev: 2
- rq: RQ-07,RQ-10
- deps: TASK-RES-002,TASK-RES-003
- owner: none
- claim: none
- tracking: github:issue#15; github:milestone#8
- updated: 2026-07-29T23:10:09+08:00
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
- rev: 3
- rq: RQ-01,RQ-04,RQ-08
- deps: TASK-RES-004
- owner: none
- claim: none
- tracking: github:issue#16; github:milestone#8
- updated: 2026-07-29T23:52:06+08:00
- write: repo:experiments/r0/task-packs/software-engineering/
- artifact: repo:experiments/r0/task-packs/software-engineering/
- accept AC-1: discovery、pilot 与 sealed holdout 有互斥任务身份、版本和泄漏审计
- accept AC-2: 任务、评分量表、H/A/C/R 基线与 evaluator 在揭示 holdout 前冻结
- accept AC-3: sealed holdout 记录版本、digest 与 reveal receipt；R0 proof 只能使用 discovery/pilot，不能消费 sealed holdout 内容
- evidence: none
- blocker: deps:TASK-RES-004; need=预注册评测先定义语料与停止条件
- handoff: none
- effect: none
- undo: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=blocked task has no delivered change or acceptance claim

## TASK-EXP-000 | 完成首个窄幅 proof-of-mechanism
- state: blocked
- rev: 3
- rq: RQ-00,RQ-01,RQ-02,RQ-04,RQ-05,RQ-06,RQ-08
- deps: TASK-CAPSULE-000,TASK-PACK-SWE-000,TASK-RES-004
- owner: none
- claim: none
- tracking: github:issue#17; github:milestone#8
- updated: 2026-07-29T23:52:06+08:00
- write: repo:experiments/r0/proof-of-mechanism/
- artifact: repo:experiments/r0/proof-of-mechanism/
- accept AC-1: 同一 Capsule、任务、模型与预算下预注册 treatment、sham、MME 和停止条件；预注册 commit/receipt 早于首次运行，后续修订只追加 amendment
- accept AC-2: 实验只使用 discovery/pilot，不读取 R4 sealed holdout；trace、artifact、结果与失败 episode 可重放，负结果不被改写为机制成功
- accept AC-3: 在 artifact 目录内产出范围受限的 Mother prototype 与 pre-bootstrap composition manifest，后者记录 experiment/preregistration 版本、当前仓库 commit、不同的 Mother/Capsule/Domain path、OpenHarness upstream/fork-point、model/prompt/tool/config/evaluator hash、treatment/sham/budget/task-set 与 trace/artifact/result 引用
- accept AC-4: clean checkout 能按 manifest 的具名 commit 与引用重放 proof-of-mechanism，并留下 replay receipt
- evidence: none
- blocker: deps:TASK-CAPSULE-000,TASK-PACK-SWE-000,TASK-RES-004; need=Capsule、任务包与评测设计就绪
- handoff: none
- effect: none
- undo: none
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=blocked task has no delivered change or acceptance claim

## TASK-OPS-002 | 建立 R0 Tag 保护与相关 CI 规则
- state: ready
- rev: 4
- rq: none
- deps: TASK-DOC-002
- owner: none
- claim: none
- tracking: github:issue#18; github:milestone#8
- updated: 2026-07-29T23:10:10+08:00
- write: repo:.github/workflows/ci.yml
- write: repo:.github/pull_request_template.md
- write: repo:AGENTS.md
- write: repo:tests/ci-scope-consistent.sh
- write: repo:docs/research/r0-tag-protection.md
- artifact: repo:tests/ci-scope-consistent.sh
- artifact: repo:docs/research/r0-tag-protection.md
- accept AC-1: 相关 required checks、保护目标和终态等待点有版本化规则与 GitHub receipt
- accept AC-2: R0 Gate 未 accepted 且 outcome 非 continue 时不得创建 acceptance tag
- evidence: none
- blocker: none
- handoff: none
- effect: FX-GH-R0-TAG-PROTECTION; action=create or update the scoped R0 ruleset after approval
- undo: FX-GH-R0-TAG-PROTECTION; action=restore the previous ruleset or remove the new ruleset and retain audit
- ci-scope: required=ubuntu,macos; advisory=none; n/a=none; reason=workflow and tag protection change the R0 terminal acceptance path

## TASK-GATE-R0-002 | 验收 Evidence & Mother Choice
- state: blocked
- rev: 2
- rq: RQ-00,RQ-01,RQ-02,RQ-03,RQ-04,RQ-05,RQ-06,RQ-07,RQ-08,RQ-09,RQ-10
- deps: TASK-RES-001,TASK-RES-002,TASK-RES-003,TASK-RES-004,TASK-RES-005,TASK-EVAL-000,TASK-CAPSULE-000,TASK-PACK-SWE-000,TASK-EXP-000,TASK-OPS-002
- owner: none
- claim: none
- tracking: github:issue#19; github:milestone#8
- updated: 2026-07-29T23:10:10+08:00
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
- rev: 2
- rq: none
- deps: TASK-GATE-R0-002@continue
- owner: none
- claim: none
- tracking: none
- updated: 2026-07-29T23:52:06+08:00
- write: none
- artifact: none
- accept AC-1: 仅在 R0 Gate accepted 且 outcome 为 continue 后创建独立 Mother、Capsule 与 lab 仓库
- accept AC-2: lab 以 submodule 固定 Mother、Capsule、engineering-workflow Domain 的具名 exact commit
- accept AC-3: 研究控制面迁出后 engineering-workflow 仍以原仓库身份保留为软件工程 Domain，不因 bootstrap 被归档或改名为 Mother
- evidence: none
- blocker: deps:TASK-GATE-R0-002@continue; need=Gate accepted 与 outcome continue 同时成立
- handoff: none
- effect: FX-GH-R1-BOOTSTRAP; action=create external Mother Capsule and lab repositories and add the Domain submodule
- undo: FX-GH-R1-BOOTSTRAP; action=archive newly created objects remove new submodule links and retain audit history
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=conditional bridge is not unlocked

## TASK-OPS-003 | 迁移 PR 合入后归档旧路线对象
- state: blocked
- rev: 4
- rq: none
- deps: TASK-DOC-002
- owner: none
- claim: none
- tracking: github:issue#20; github:milestone#8
- updated: 2026-07-30T00:19:09+08:00
- write: repo:docs/research/github-roadmap-migration.md
- artifact: repo:docs/research/github-roadmap-migration.md
- accept AC-1: PR #14 以 squash merge 合入 main 后，保留 proposed-successor links 与历史语义，再关闭 #2、#11、#13 与 PR #12；Issue #1 由 PR #14 的 `Closes #1` 关闭
- accept AC-2: 每次 mutation 记录 URL、时间与 undo；旧 Milestone #1-#7 的关闭与活跃 R0 Issue 重投影由 TASK-OPS-004 独立验收
- evidence: none
- blocker: deps:TASK-DOC-002; external=github:pr#14; need=squash-merged-to-main before closing #2,#11,#13,PR#12
- handoff: none
- effect: FX-GH-R0-SUPERSEDE; action=close issue#2 issue#11 issue#13 and pr#12 after migration squash merge
- undo: FX-GH-R0-SUPERSEDE; action=reopen closed objects and retain successor comments and audit
- ci-scope: required=none; advisory=none; n/a=ubuntu,macos; reason=blocked task has no delivered change or acceptance claim
