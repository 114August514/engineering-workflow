# 可演化 Mother 研究路线迁移计划

> 状态：completed；PR #14 已 squash merge，旧路线对象已归档并回填 receipt
>
> 本文是执行路线，不是实现 receipt。除已批准设计外，文中出现的 ADR、validator、
> GitHub Milestone/Issue、Mother/Capsule 仓库、实验与 tag 均不得据此声称已经存在或通过。

## 1. 目标

把当前仓库从“先冻结通用协作 Runtime，再接执行底座”的路线，迁移到：

```text
Domain Product -> Evolvable Mother -> Capsule Port -> Substrate Capsule
                         |
                         +-> lab workspace 固定一次实验组合
```

其中：

- `engineering-workflow` 继续是软件工程垂直产品，也是 R0 的临时研究控制面。
- Mother 是可迭代的研究母体：Workbench、实验资产、规范化 trace/artifact、evaluator、
  incubating/promoted mechanisms。
- Capsule 是可替换执行底座。首个候选以 OpenHarness-derived spike 为主，但可以大量修改，
  也可以在证据不支持时被替换。
- lab workspace 只负责组合，不成为业务源码仓；R1 起用 submodule 固定 Mother、Capsule、
  Domain 的具名 commit。
- 通用 Core 不是起点，只能由重复实验、第二 Capsule 和第二垂直的证据晋升出来。

## 2. 非目标

这次迁移不做以下事情：

- 不创建 Mother、Capsule 或 lab 仓库。
- 不 fork OpenHarness，不实现首个机制，不运行确认性实验。
- 不冻结永久 Capsule contract、通用对象模型或 harness-neutral 声明。
- 不创建 `r0-accepted` tag。
- 不归档或把 `engineering-workflow` 改名为 Mother；它继续作为软件工程 Domain，R1 只迁出
  临时研究控制面。
- 不改写旧 Task、Issue、Milestone、PR、commit 或 decision 的原始语义。
- 不为了预防所有可能故障而引入复杂事务层、通用影响分析器或 GitHub 自动化框架。

## 3. 工作原则

### 3.1 鸵鸟原则

默认先解决已经观察到、会影响当前 Gate 的问题。未知或低概率风险记录为 debt，不提前把整个
系统做成防御框架。

只在三类情况硬阻塞：

1. 会污染研究证据，例如 holdout 泄漏、composition 无法复现、treatment/sham 不可比。
2. 会制造虚假终态，例如没有 evidence 却标 accepted、分支状态冒充默认分支、未通过 Gate 却打 tag。
3. 会产生难以恢复的外部效果，例如错误关闭历史对象、覆盖 tag、不可逆权限或发布变更。

其余情况优先：显式记录、允许重试、继续不冲突工作，在对应 Issue 中按真实失败补保护。

### 3.2 不假装实现

- `planned` 不是 `accepted`，commit 也不是实验结果。
- Gate 的 `accepted` 只表示方法与证据审计完整，不表示结果为正。
- Gate 结果单独记录 `outcome: continue | pivot | stop`；只有 `accepted + continue` 解锁下一阶段。
- R0 尚无独立三仓。R0 manifest 只能记录当前仓库 commit 与三个不同 component path，
  不能把一个 commit 冒充 Mother/Capsule/Domain 三个仓库的 commit。
- GitHub Issue 关闭不是 ledger acceptance；远程 CI pending 也不是任务 blocker。

### 3.3 历史身份优先

- 原语义不变的工作保留 Task ID 与 GitHub 对象。
- 语义变化的工作创建新 Task ID、Issue 和 Milestone，通过 supersede map 连接。
- 旧记录只追加 superseding decision、cancellation reason 和 receipt，不回写成“当时就选择了新路线”。
- PR `#12` 保留原 `TASK-DOC-001` 与 abstract-first baseline 身份；迁移使用独立 PR。

### 3.4 CI 只按因果相关性阻塞

统一使用：

```text
ci-scope: required=...; advisory=...; n/a=...; reason=...
```

- `required`：失败可以推翻当前 acceptance，终态动作前等待。
- `advisory`：有信息价值，不阻塞独立工作。
- `n/a`：与当前变更无因果关系。
- 文档路线修改不因为远程 CI pending 而停工。
- 修改 validator、shell、workflow 或跨平台行为时，Ubuntu/macOS 对应检查是 required。
- 无关失败只需留下 URL、理由和直接复现结果，不把它重新包装成普遍 barrier。

## 4. 可探索而非单路线锁死

路线中的每个 Gate 都允许三种结果：

- `continue`：当前机制与架构假设获得足够证据，进入下一阶段。
- `pivot`：保留有效证据，创建 superseding decision 和具名 successor route。
- `stop`：停止投入，不为了维护 roadmap 连贯性而制造正结果。

主动保留四个反证入口：

1. OpenHarness-derived Capsule 与结构不同候选对照，允许更换底座。
2. treatment/sham 与消融，允许否定某个 Mother mechanism。
3. 第二 Capsule portability canary，允许把机制收缩为 Capsule-specific。
4. 第二垂直 sealed holdout，允许把“通用能力”收缩为软件工程产品能力。

任何 pivot 都追加 ADR/decision 与 successor Task；不原地修改原 Gate 的验收口径。

## 5. R0-R6 Roadmap

| 阶段 | 要回答的问题 | 最小产物 | Continue 门槛 | Pivot/Stop 信号 |
|---|---|---|---|---|
| R0 Evidence & Mother Choice | 是否存在值得研发的材料性协作失败，首个 Capsule 是否可用 | evidence register、能力矩阵、协议边界、评测设计、OpenHarness-derived spike、结构不同候选对照、范围受限的 Mother prototype、pre-bootstrap manifest、一个 proof-of-mechanism、Gate report | 现有方案未完整覆盖；可信 treatment/sham；Mother/Capsule 可独立维护；OpenHarness-derived 被选为具名 R1 Capsule | 无材料性失败、现有方案已覆盖、无法构造 sham、底座不可维护或 OpenHarness 被拒绝 |
| R1 Runnable Mother v0 | 三个组件能否组成可记录、可重放的真实闭环 | 独立 Mother/Capsule/lab、软件工程 Domain 接入、真实任务、three-repo manifest、trace/artifact、sham、clean-checkout replay | 具名组合可重复运行且不发布中立性声明 | 记录不稳定、sham 不可信、独立重跑失败 |
| R2 Mechanism Labs | 单一机制是否改善已观察失败 | 每机制独立预注册、MME、预算、treatment/sham、消融、失败 episode | supported 且达到预注册阈值，另建 promotion Task | falsified/inconclusive；换机制或停止，不靠 accepted 解锁晋升 |
| R3 Promotion & Portability | 有效机制属于 Mother、Capsule、Domain 还是 lab-only | versioned mechanism、最小 trace/core、第二 Capsule canary、归属裁决 | 第二 Capsule 不改写机制本体且关键事件无损 | contract breaking、效果消失或反向；收缩声明范围 |
| R4 Software Engineering Confirmation | 在 sealed holdout 上是否有真实人机协作价值 | H/A/C/R、joint outcome、最佳单方、人类注意力、风险、恢复、时间、成本 | 预注册 MME、非劣界与安全 guardrail 成立 | 无材料性收益或安全边界失败 |
| R5 Second Vertical | 已晋升机制能否迁移到高对比领域 | adaptation set、第二垂直 holdout、core-change audit | 无 breaking core change 且收益/安全门槛成立 | 需要 breaking core change；收缩为 Domain/Capsule scope |
| R6 Productization | 哪些部分值得稳定和承诺兼容 | research preview/SDK/领域产品、兼容矩阵、迁移说明、升级演练 | 多次实验、多个具名组合和现场数据共同支持 | 证据不足则保持 experimental、收缩或退役 |

只在当前仓库物化 R0 与一个条件化 R1 bootstrap bridge。R1-R6 可以先创建 direction-only
Milestone，但不挂 Issue、不设 due date；具体 Task、Issue 和可执行 successor Milestone 由未来
Mother 仓库在前一 Gate `accepted + continue` 后创建，避免把方向占位伪装成研发排期。

## 6. R0 Task Graph

下面保留迁移后的任务身份与当前状态；具体 acceptance evidence 仍以 `todo.md` / `done.md` 为准。

| Task | 作用 | 依赖 | 当前状态 |
|---|---|---|---|
| `TASK-DEC-002` | 记录可演化 Mother superseding decision | `TASK-DEC-001` | accepted |
| `TASK-DOC-002` | 迁移 canonical roadmap 与历史映射 | `TASK-DEC-002` | accepted |
| `TASK-RES-001..005` | 保留原 evidence/capability/protocol/evaluation/second-vertical 研究 | 原依赖 | ready |
| `TASK-OPS-001` | 保留原 ledger 机器检查任务语义 | `TASK-DOC-001` | cancelled；实现位置不属于 Domain 产品仓库 |
| `TASK-EVAL-000` | 保留静态 skill 行为基线 | `TASK-RES-004` | blocked |
| `TASK-CAPSULE-000` | OpenHarness-derived runnable spike 与候选对照 | `TASK-RES-002,003` | blocked |
| `TASK-PACK-SWE-000` | discovery/holdout 切分 | `TASK-RES-004` | blocked |
| `TASK-EXP-000` | 首个同底座 proof-of-mechanism | Capsule、Pack、评测设计 | blocked |
| `TASK-OPS-002` | tag 保护与 CI relevance 规则 | `TASK-DOC-002` | ready |
| `TASK-GATE-R0-002` | R0 evidence audit 与 continue/pivot/stop | 全部 R0 研究与运行产物 | blocked |
| `TASK-OPS-R1-BOOTSTRAP-001` | 创建 Mother/Capsule/lab 并把本仓作为 Domain 接入 | `TASK-GATE-R0-002@continue` | blocked，不创建 R0 Issue |
| `TASK-OPS-003` | 迁移 PR 合入后归档旧路线对象 | 迁移 PR 已在默认分支 | accepted，不作为研究 Gate 依赖 |
| `TASK-OPS-004` | 清退旧路线投影并建立方向 Milestone | `TASK-DOC-002` | accepted，不作为研究 Gate 依赖 |

R0 pre-bootstrap manifest 至少记录：experiment/preregistration 版本、当前仓库 commit、
Mother prototype path、Capsule spike path、Domain path、OpenHarness upstream/fork point、
model/prompt/tool/config/evaluator hash、treatment/sham/budget/task-set、trace/artifact/result 引用。

R1 起才改用 lab commit 加 Mother/Capsule/Domain repository URL、exact commit 与 submodule gitlink。

## 7. 旧语义迁移

### 7.1 保留

- `TASK-RES-000`、`TASK-DEC-001`、`TASK-DOC-001` 保持 accepted 与原 acceptance/evidence。
- `TASK-RES-001..005`、`TASK-EVAL-000` 保持 Task ID、Issue 与原验收语义及状态。
- `TASK-OPS-001` 保持 Task ID、Issue 与原验收语义，但因实现位置违反 Domain/Mother
  边界转为 cancelled；不登记 acceptance evidence。
- GitHub Issue `#1,#2,#3,#7,#8,#9,#10` 和 Milestone `#1` 保持原身份。
- PR `#12` 保持原标题、正文和历史任务含义。

### 7.2 取代

| 旧 Task/Object | 新路线 | 处理 |
|---|---|---|
| `TASK-FORK-001` / Issue `#11` | `TASK-CAPSULE-000` | 旧块 cancelled，保留原 acceptance；新 Issue 承载 runnable spike 与候选对照 |
| `TASK-EVAL-001` | `TASK-EXP-000` | 旧块 cancelled；新任务先做窄幅因果实验 |
| `TASK-OPS-001` / Issue `#2` | `TASK-OPS-R1-BOOTSTRAP-001` 后的 Mother 控制面路线 | 旧块 cancelled 并保留原 AC；Task 5A 只追加 successor comment，PR #14 合入后由 `TASK-OPS-003` 关闭 |
| Issue `#13` 的旧 Gate | `TASK-GATE-R0-002` | 不复用 Task ID；新 Gate 分离 accepted 与 outcome |
| `TASK-ADR/CORE/ADP/ASR/SWE/GEN-*` abstract-first 任务 | `TASK-DEC-002` 与 R1-R5 evidence route | cancelled 并逐项记录 cancellation/successor，不伪造完成证据 |

### 7.3 GitHub 历史对象

- 迁移使用新分支 `agent/evolvable-mother-roadmap` 和独立 PR。
- 先提交 old-to-new map，再创建新 Milestone/Issue。
- PR #14 合入前只给 `#2/#11/#13` 与 PR `#12` 追加 proposed-successor link，不关闭对象。
- PR #14 必须 squash merge；合入后 `TASK-OPS-003` 再按历史语义关闭这四个对象。这样 PR #12
  不会因祖先提交进入 main 而被 GitHub 自动判为 merged，关闭后仍可重新打开。
- Issue #1 由包含其原交付物的 PR #14 使用 `Closes #1` 在 squash merge 时关闭；PR #12 仍保留
  原标题、正文、head 与任务身份。
- 旧 Milestone #1-#7 不重命名；Task 5A 把活跃 R0 Issue 重投影后直接关闭这些旧入口，
  不连带关闭其中 Issue/PR。

## 8. GitHub 投影

迁移创建当前可执行的 R0 投影与不承诺实现的阶段方向：

- 一个新 Milestone：`R0 - Evidence & Mother Choice`。
- 六个新 Issue：`TASK-CAPSULE-000`、`TASK-PACK-SWE-000`、`TASK-EXP-000`、
  `TASK-OPS-002`、`TASK-GATE-R0-002`、`TASK-OPS-003`。
- 六个不挂 Issue、不设 due date 的 R1-R6 direction-only Milestone。
- 一个独立 migration PR，目标 `main`。

创建规则保持简单：按精确 Task ID/title 查询一次，存在则核对并复用，不存在才创建；查询失败停止
本次外部写入。每次 mutation 的 URL 和时间回填 `docs/research/github-roadmap-migration.md`。

外部效果只登记三个恢复边界：

```text
FX-GH-R0-PROJECTION: create successor Milestone/Issues/comments
undo: close newly created objects; retain audit events and mapping

FX-GH-R0-SUPERSEDE: after migration merge, close #2/#11/#13 and PR #12
undo: reopen objects; retain successor comments and audit history

FX-GH-MILESTONE-DIRECTIONS: move active R0 issues; create direction milestones;
close old milestones; comment #2; update #20 and PR #14 projections
undo: reopen old milestones; move issues back; close direction milestones;
restore #20/PR #14 projection from prestate commit 9484028; retain comments and audit
```

## 9. 实施工作包

### Task 0：建立独立迁移分支与事实映射

**文件**

- Create: `docs/research/github-roadmap-migration.md`
- Read: PR `#12` metadata and head SHA

**做什么**

1. 使用 `using-git-worktrees`，从 PR `#12` 当前 head 创建
   `agent/evolvable-mother-roadmap`；推荐 worktree 为
   `/tmp/engineering-workflow-evolvable-mother`。
2. 在任何新 GitHub 对象前，写入 keep/supersede/create map 与 effect/undo。
3. 提交、推送，创建独立 draft PR。
4. 回填 migration PR URL；不修改 PR `#12`。

**验收**

- 新 PR 可以解析到批准设计和 migration map。
- PR `#12` 仍保持原语义。
- 此步骤不创建 R0 Milestone/Issue。

### Task 1：记录 superseding decision 与 claim 迁移工作

**文件**

- Create: `docs/decisions/0001-evolvable-mother-research-platform.md`
- Modify: approved design status/pointer
- Modify: `todo.md`, `done.md`

**做什么**

1. 追加 `TASK-DEC-002`，明确 Mother/Capsule/Domain/lab 边界与 R0 pre-bootstrap 例外。
2. 保留 `TASK-DEC-001` 原文；只声明其 abstract-first 顺序被 supersede。
3. 登记并 claim `TASK-DOC-002`、`TASK-OPS-001`。
4. 不在本步骤把尚未完成的文档或 validator 标 accepted。

**验收**

- 新 decision 有批准来源和可撤销/替代路径。
- todo/done 没有重复 Task ID。

### Task 2：建立最小 ledger 契约并迁移任务图

**文件**

- Create: `docs/research/task-ledger-contract.md`
- Modify: `todo.md`, `done.md`

**做什么**

1. 契约只覆盖当前真实需要：Task ID/state、依赖与 `@continue`、accepted/evidence、
   cancellation/successor、write scope、effect/undo、tracking、CI scope、done move token。
2. 用一次性 checker 验证迁移，覆盖非空输入和真正变红的负例；完成后删除，避免把
   研究迁移控制面混入 Domain 产品脚本与回归测试。
3. 原语义不变任务做最小字段补齐；旧 abstract-first 任务移入 done/cancelled，保留原 acceptance，
   不追加假 evidence。
4. 登记 R0 新任务与条件化 bootstrap bridge。
5. `TASK-OPS-001` 保留原标题、tracking 和 AC 后转为 cancelled，机器控制面的 successor
   指向 R0 `continue` 后的外置 Mother bootstrap；Issue #2 本步骤不改动。

**验收**

- 一次性 checker 在删除前通过，且故意破坏时对应负例变红；最终产品树不保留它。
- 原有产品测试全部通过，且没有新增迁移专用 `.sh`。
- 只有 bootstrap bridge 使用 `TASK-GATE-R0-002@continue`。

### Task 3：更新 canonical research 文档

**文件**

- Modify: `docs/research/agent-collaboration-foundation.md`
- Modify: historical remediation design with a supersession notice
- Modify: `README.md`
- Modify: `todo.md`, `done.md`

**做什么**

1. 保留已有来源、RQ、H/A/C/R、证据等级与多 Agent ledger 协议。
2. 把 Mother/Capsule/Domain/lab、R0/R1 manifest 和 R0-R6 Gate 写成唯一当前事实源。
3. 加入 decision history，说明哪些旧结论保留、哪些顺序被取代。
4. 只有文档、链接与 ledger evidence 完整后，才把 `TASK-DOC-002` 移入 done/accepted。

**验收**

- Canonical 文档既能说明当前路线，也能回答如何 pivot/stop。
- README、design、migration map 与 ledger 指向同一事实源。
- `bash tests/docs-links.sh` 通过。

### Task 4：落实 CI relevance，而不是普遍等待

**文件**

- Create: `tests/ci-scope-consistent.sh`
- Modify: `.github/pull_request_template.md`
- Modify: `.github/workflows/ci.yml`
- Modify: `AGENTS.md`
- Modify: `todo.md`, `done.md`

**做什么**

1. 统一 `required/advisory/n/a` 词汇与 PR receipt。
2. Domain CI 只调用与 skill 产品行为相关的现有仓库验证；ledger checker 是否进入
   外置 Mother 由跨 Domain 证据决定。
3. pending CI 不改变 task state；只在 merge/gate/tag 等终态动作等待相关 required checks。
4. 不把已 cancelled 的 `TASK-OPS-001` 或一次性 checker 伪装成 accepted。

**验收**

- 分类测试有防空断言，并能抓住错误分类或缺失 receipt。
- Ubuntu/macOS 继续覆盖 shell 兼容面。
- 不增加 universal wait、path-analysis service 或新的 CI 框架。

### Task 5：创建 R0 GitHub 投影并回填 receipt

**前置**

- Migration map、decision、ledger 与 canonical 文档已经 commit 并 push。

**做什么**

1. 创建/复用新 R0 Milestone 与六个精确 Task Issue。
2. 回填 Issue/Milestone URL 与 mutation receipt，再 push。
3. 给旧 Issue/PR 添加 proposed-successor link，但不在 migration PR 合入前关闭它们；旧
   Milestone 的退出由 Task 5A 独立处理。
4. 本步骤不创建 R1-R6 对象；direction-only Milestone 由 Task 5A 单独拥有。

**验收**

- 新 Issue 的 Task ID、依赖、AC、CI scope 与 ledger 一致。
- 旧 Issue/PR 的标题和正文、旧 Milestone 的标题与原始描述未被改写为新语义。
- 外部查询失败不会被当作“不存在”继续写入。

### Task 5A：清退旧路线投影并建立方向 Milestone

**状态：completed。** GitHub URL、时间与 undo 见
[`github-roadmap-migration.md`](../../research/github-roadmap-migration.md)。

**做什么**

1. 把仍服务当前 R0 的 Issue `#3/#7/#8/#9/#10` 从旧 Milestone #1 重投影到 #8。
2. 旧 Milestone #1-#7 保留原标题与原始描述后关闭，不原地复用；migration map 承载 successor 关系。
3. 让 #8 成为唯一当前执行 Milestone；新建 R1-R6 direction-only Milestone，仅写阶段问题、
   入口条件和 continue/pivot/stop 边界。
4. 给 Issue #2 追加 proposed-successor comment，但不在 PR #14 合入前关闭它。
5. 不给未来 Milestone 挂 Issue、设置 due date 或声明实现已经启动；R1 bootstrap 后由 Mother
   创建可执行 successor 并关闭当前方向占位。
6. 更新 Issue #20 与 PR #14 正文，使关闭范围、direction-only 语义和未交付边界与 ledger 一致。

**验收**

- GitHub open Milestone 只呈现当前 R0 和 R1-R6 方向，不再混入 abstract-first 路线。
- 旧 Milestone 可通过原 URL 审计，原始描述仍保留；每次 mutation 有 URL、时间和 undo。
- `todo.md`、canonical roadmap、migration map、Issue #20 与 PR #14 的口径一致。

### Task 6：验证、评审与 PR readiness

运行仓库要求的完整验证：

```bash
for t in tests/*.sh; do bash "$t" || exit 1; done
for f in skills/*/scripts/*.sh scripts/*.sh install.sh; do [ -e "$f" ] || continue; bash -n "$f" || exit 1; done
git diff --check
```

使用 `requesting-code-review`，重点审查：

- 是否改写了历史 acceptance/Issue/PR 语义。
- 是否把计划中的对象或实验冒充为已实现。
- Gate accepted/outcome 与 bootstrap 解锁是否分离。
- 一次性 ledger 迁移校验是否用故障注入排除了空输入假绿，并留下 review receipt。
- CI 是否只等待当前变更真正相关的 required checks。

本迁移会修改 shell 测试与 workflow，因此 migration PR 准备合并时 Ubuntu/macOS 是 required；
等待只发生在这个终态检查点。通过评审与相关检查后把 PR 标 ready，不自动 merge、不打 tag。

## 10. 多 Agent 协作约定

- `agent:root` 是 ledger steward，负责 claim、rev 和 todo/done 终态迁移。
- 子 Agent 只领取边界明确、写范围不重叠的工作包；不并发编辑 todo/done。
- 开工前在 `todo.md` claim；交付后先提交 artifact/evidence，再由 steward 移入 `done.md`。
- `done.md` 只收 accepted/cancelled/rolled-back，不收“代码大概写完了”。
- 每个 GitHub Issue 对应一个 Task 身份；一个 PR 可以交付多个明确列出的 Task。
- 当前 Gate 之外只保留条件化 bridge，不把远期假设拆成大量伪精确 Issue。

## 11. 完成定义

这次迁移完成只意味着：

1. 新 decision、canonical roadmap、migration map 与 ledger 契约进入默认分支。
2. 旧语义可审计但退出当前入口；新 R0 Task/Issue/Milestone 与 R1-R6 方向占位可追踪。
3. ledger 迁移有一次性故障注入验证与 review receipt；CI relevance 有持久最小机器检查。
4. 未来 Mother/Capsule/lab 创建被 `TASK-GATE-R0-002@continue` 明确锁住。

它不意味着已经证明 Mother 有效、OpenHarness 是最终底座、通用 Core 存在，或产品已经进入 R1。
