# 可演化母体研究平台设计

> 状态：方向已批准；实施 decision 已记录；roadmap 迁移中
>
> 实施 decision：[ADR 0001](../../decisions/0001-evolvable-mother-research-platform.md)。本文正文保留批准时的设计与理由。
>
> 当前产品边界与 R0-R6 路线的唯一事实源：
> [`agent-collaboration-foundation.md`](../../research/agent-collaboration-foundation.md)。
>
> 文档类型：Explanation / Design Spec
>
> 面向：本仓库维护者、后续 Mother/Capsule 维护者、研究实施者和垂直产品负责人
>
> 适用范围：通用人机协作底座的研究组织、仓库边界和 R0-R6 roadmap

## 一、决策摘要

本项目采用“可演化母体 + 可替换 Substrate Capsule + 独立垂直产品 + 实验组合层”的
研究生产方式。

核心判断是：

> 单次实验必须固定执行底座，整个研究计划和母体产品不能绑定某个执行底座。

OpenHarness 是首个 Substrate Capsule 的来源候选。我们可以从其代码开始并进行大量修改，
但修改后的实现属于独立的 `OpenHarness-derived` Capsule，不定义母体身份，也不成为所有
垂直产品的强制运行时。

母体拥有可持续积累的研究资产：实验协议、规范化 trace、评测器、证据、经过验证的机制包
及其晋升记录。Capsule 提供具体的 Agent loop、工具、上下文、权限和执行环境。软件工程是
第一垂直和持续 dogfood 场。轻量 lab workspace 负责把三者的确定版本组合成可复现实验。

本设计已通过书面复核，并取代此前研究说明中的以下研发顺序：先冻结 harness-neutral Core 和
Adapter contract，再实现执行后端，最后才接入软件工程 Domain Pack。原决定中“不从零重写
完整 harness、优先复用成熟实现、用证据检验通用性”的部分继续保留。

历史上的 `TASK-DEC-001` 不原地修改。`TASK-DEC-002` 已用 superseding decision 记录顺序变化：
harness-neutral 从初始架构前提降为需要第二 Capsule 验证的研究假设。

## 二、为什么需要调整

被取代的 roadmap 把待证的通用对象、schema、保障层和 Adapter contract 放在可运行实验之前。
这有三个问题：

1. 没有共同执行装置，机制收益无法与 Harness 差异分离。
2. 软件工程要等 Core、Assurance、Evaluation 和两个 Adapter 完成后才接入，失去最早的
   真实反馈来源。
3. 通用性被提前写入类型和接口，第二 Harness 或第二垂直只能验证一个已经投入过深的方案。

反过来，把 OpenHarness 整仓直接定义为母体也不成立。它会让上游的事件模型、生命周期、
语言和缺陷逐渐成为本项目的事实标准，并把“实验版本固定”误写成“研究计划永久绑定”。

因此采用中间路线：母体保持独立，Capsule 可以深度 fork，实验组合负责固定版本。

## 三、备选方案与取舍

### 方案 A：OpenHarness 整仓 fork 直接成为母体

优点是启动快、源码可见、深层拦截和故障注入容易。缺点是研究问题、协作语义、垂直产品和
上游私有类型会持续纠缠；替换底座等同于重写母体。

结论：拒绝作为长期结构。整仓 fork 只允许成为一个 Capsule 的起点。

### 方案 B：外置母体 + 可替换 Capsule + lab workspace

母体、Capsule、垂直产品分别演化；lab workspace 固定某次实验的 commit 组合。机制代码先在
孵化区接受消融和对照验证，通过后才晋升为母体组件。

优点是兼顾快速研究、深度修改、可重复实验和替换底座。代价是跨仓改动需要明确版本和两步
合入，不能假装一次 PR 原子覆盖所有仓库。

结论：采用。

### 方案 C：松散项目组合，只共享论文、数据和评测

每个项目完全独立，不共享可执行母体。灵活性最高，但 fixtures、trace、回归集和机制实现
容易重复，难以形成“真实产品问题回流研究、研究成果回流产品”的循环。

结论：保留为停止平台化后的降级路径，不作为主路线。

## 四、逻辑架构

```text
                    ┌──────────────────────────────┐
                    │       Domain Products        │
                    │ software engineering / next │
                    └──────────────┬───────────────┘
                                   │ use mechanisms
                    ┌──────────────▼───────────────┐
                    │      Evolvable Mother        │
                    │ Workbench + promoted parts   │
                    └──────────────┬───────────────┘
                                   │ Capsule Port
                    ┌──────────────▼───────────────┐
                    │     Substrate Capsules       │
                    │ OpenHarness-derived / other  │
                    └──────────────────────────────┘

 lab workspace = exact Mother commit + Capsule commit + Domain commit
                 + model/config/evaluator hashes
```

### 4.1 Evolvable Mother

母体负责：

- 研究问题、预注册、experiment-pack schema 和证据模型。
- 规范化 trace、artifact、评分器、replay 与 fault-injection 入口。
- 机制孵化、消融、晋升、降级和退役记录。
- 已晋升组件的版本、迁移规则和最小 Capsule Port。
- 组合版本的验证结果，不替 Capsule 声称其原生能力。

母体不负责：

- 强制所有产品运行同一个 Agent loop。
- 持有 OpenHarness 私有 session、tool 或 permission 类型。
- 提前定义尚未被实验需要的通用对象。
- 把研究随机化、隐藏评分器或 sealed holdout 打进产品运行时。

母体的迭代单位是 versioned mechanism package 和 experiment pack。R0-R2 允许 breaking
change；只有晋升后的接口才承担迁移责任。

### 4.2 Substrate Capsule

Capsule 封装一个具体执行系统及其版本。首个候选是我们维护的 OpenHarness-derived engine。
它可以大量修改，不要求向上游贡献，也不以 patch 行数作为失败标准。

每个 Capsule 至少公开：

- 身份、版本和来源 commit。
- 可观察、可建议、可强制的能力清单。
- 启动、停止、恢复、人工输入、事件、artifact 和用量入口。
- 不支持或只能降级的能力，禁止静默伪装成功。
- 自己的单元、集成和安全回归结果。

Capsule 内可以使用私有类型；跨出 Capsule 的事件必须转换成母体当前版本能理解的最小结构。
第一轮 Port 只覆盖首个机制实验需要的能力，不预先复制成熟 Harness 的所有接口。

### 4.3 Domain Product

`engineering-workflow` 保持软件工程产品身份，拥有 Git、PR、测试、部署、风险分流、闸门、
journal 和审计等领域语义。它同时承担三种角色：

- 提供真实失败和任务语料。
- 作为母体机制的第一 adaptation 场。
- 提供预先封存的确认性 holdout。

软件工程字段不得为了复用方便进入母体。只在该领域有效的机制留在本仓库，不因实现成功而
自动晋升为通用组件。

### 4.4 Lab Workspace

lab workspace 是组合和复现仓，不是产品母体。它可以用 Git submodule 固定独立仓库：

```text
lab-workspace/
├── repos/
│   ├── mother/                 # submodule: exact commit
│   ├── capsule-openharness/    # submodule: exact commit
│   └── engineering-workflow/   # submodule: exact commit
├── compositions/
├── registrations/              # concrete preregistration + experiment-pack ref
└── results/                    # receipts/metadata; large artifacts live outside Git
```

submodule 的语义是“本次组合使用哪个 commit”，不是“母体依赖 OpenHarness”。母体、Capsule
和垂直产品的正式仓库都不通过 submodule 把另外两者写成自己的源码子目录。

母体定义 experiment pack 和 manifest schema；lab workspace 保存具体的预注册、组合与运行
receipt。每个 concrete experiment manifest 至少记录：

- experiment ID 和预注册版本。
- Mother、Capsule、Domain 的 commit。
- 模型、基础 prompt、tool schema 和配置 hash。
- treatment、sham、预算和任务集合版本。
- evaluator、artifact 和结果位置。

不为每次试跑创建 tag。可复现组合由版本化 manifest 表达；roadmap gate 的 accepted tag
只指向经过 gate report 批准的控制面 commit。

## 五、OpenHarness-derived Capsule 策略

OpenHarness 作为代码来源，不作为标准。采用以下关系：

1. 保留初始许可证、来源仓库和 fork-point commit。
2. Capsule 在独立仓库维护自己的 roadmap、测试和发布。
3. 允许重构、替换模块和大规模改动，不设置“必须保持薄补丁”的形式预算。
4. 上游更新不自动合并；安全修复和重要机制经本 Capsule 的测试后选择性吸收。
5. 不以是否容易回到上游作为 Continue/Pivot/Stop 证据。
6. 若维护 Capsule 持续挤占机制实验和产品验证能力，或无法构造可信 sham，再考虑替换底座。

大量修改不等于母体绑定。绑定只在以下情况发生：母体直接引用 Capsule 私有类型、研究问题
无法在其他 Capsule 表达、或垂直产品必须跟随 Capsule 的每次内部升级。上述情况都视为边界
侵蚀，需要在 gate report 中显式记录。

## 六、研究与产品循环

```text
真实任务出现失败
  -> 登记问题、频率、损失和现有 workaround
  -> 建立单一可证伪机制实验
  -> 在固定组合上运行 treatment / sham / ablation
  -> supported / falsified / inconclusive
  -> supported 才创建独立 promotion task
  -> 第二 Capsule 做 portability canary
  -> 发布新的母体组件或收缩到 Capsule/Domain
  -> 垂直产品选择性升级
  -> 现场 trace 和失败回流下一轮研究
```

实验任务的 `accepted` 只表示方法和证据完整，不表示假设得到支持。负结果和不确定结果可以
accepted，但不能解锁组件晋升。Promotion 必须是独立 Issue 和 PR。

晋升规则：

- 只对一次实验有用：留在 lab。
- 只对一个 Capsule 有用：进入该 Capsule。
- 只对一个领域有用：进入该 Domain Product。
- 在重复实验中形成稳定机制和接口：进入母体 components。
- 被多个已晋升组件共同需要且无法下沉：才进入最小 core。

论文发表、star、demo、内部使用量和已经投入的代码量都不自动触发晋升。

## 七、版本与兼容策略

### 7.1 实验级固定，计划级可演化

确认性实验期间，Mother、Capsule、Domain、模型和评测器均固定。升级任一项都产生新的组合，
不得静默覆盖历史结果。

母体主干可以持续演化。重跑历史实验时检出旧 composition manifest 对应的 commit，不要求
当前主干兼容所有实验分支。

### 7.2 Capability-first Port

Capsule Port 先声明能力，再暴露最小操作。缺失能力返回明确的 `unsupported` 或降级级别，
不会将观察能力写成强制能力。

第一 Capsule 不能单独决定稳定 contract。首个机制取得单底座信号后冻结一个窄版本，再由
结构不同的第二 Capsule 尝试实现。需要 breaking change 时记录 portability failure，而不是
事后修改首次成功口径。

### 7.3 上游与下游升级

- Capsule 升级：由新的 Capsule commit 和组合 manifest 表达。
- Mother 升级：已晋升组件提供 migration note；孵化组件可直接 breaking change。
- Domain 升级：由垂直产品自己决定何时采用新 Mother/Capsule 组合。
- 组合发布：只声明已验证的具名组合，不声称任意版本可互换。

## 八、失败处理

- 组合 commit 缺失或不匹配：拒绝运行，报告具体仓库和期望 commit。
- Capsule 缺少实验要求的强制能力：实验标记 unsupported，不用提示词模拟硬保障。
- Capsule 崩溃：保留 trace、artifact 和失败分类；能否恢复由该实验的 acceptance 决定。
- evaluator 或 holdout 泄漏：该确认性实验无效，修复后使用新 holdout，不重写旧结果。
- 第二 Capsule 效应消失或反向：把结论收缩为 Capsule-specific，不阻止领域产品继续使用。
- 母体机制没有材料性收益：保留实验资产，停止晋升；不为维护 roadmap 而继续实现。

只硬挡会污染证据、错误放行或造成不可恢复副作用的情况。可恢复的本地失败保持可见并允许
重试，不为低概率协调故障建设分布式控制面。

## 九、验证策略

R1 起，每个可运行组合至少有：

1. composition manifest 完整性检查。
2. Capsule 启动和最小 end-to-end smoke test。
3. 规范化 trace 和 artifact validator。
4. no-op treatment 与原生基线的 sham 等价检查。
5. 机制级 unit、fault injection 和 ablation test。
6. 在干净 checkout 中由非实现者重跑一个 experiment pack。

第二 Capsule 出现后增加：

- 相同最小 Port 的 conformance fixtures。
- safety-critical event 的 lossless 映射。
- 最高效应机制和一个 negative control 的 portability canary。
- `treatment x capsule` 的预注册异质性分析。

Conformance 只证明结构可实现，不能代替用户价值或跨领域效果证据。

## 十、Roadmap

### R0：Evidence & Mother Choice

目标：证明值得继续 R&D，并选定首个可实验 Capsule，不决定永久 Runtime。

产物：

- claim/evidence 登记、Harness 能力矩阵、协议边界和评测设计。
- 软件工程 discovery corpus 与 sealed holdout 的切分规则。
- OpenHarness-derived spike，以及至少一个结构不同候选的纸面/窄幅对照。
- superseding ADR：母体、Capsule、Domain 和 lab workspace 的边界。
- Continue/Pivot/Stop gate report。

通过条件：观察到材料性协作失败，现有方案没有完整覆盖；至少一个窄机制可在固定 Capsule 上
构造可信 treatment 与 sham；独立维护母体和 Capsule 在许可与工程上可行。

### R1：Runnable Mother v0

目标：得到第一套可运行、可记录、可重放的母体组合。

产物：

- 独立 Mother、OpenHarness-derived Capsule 和 lab workspace。
- 当前 `engineering-workflow` 作为第一垂直接入，不做大搬家。
- 一个端到端真实任务、composition manifest、规范化 trace、artifact 和 sham baseline。
- 干净环境独立重跑记录。

本阶段接口允许不稳定，不发布 harness-neutral 或 domain-neutral 声明。

### R2：Mechanism Labs

目标：在同一组合上逐个检验协作机制。

优先从真实失败中只选择一个首发机制，例如持久状态、结构化 Human Task、确定性 action gate
或 Claim/Evidence 分离。每项机制拥有独立预注册、预算、MME、消融和反证。

结果可以 supported、falsified 或 inconclusive。实验完成与组件晋升分离。

### R3：Promotion & Portability

目标：把有效机制从实验代码提取成可复用组件，并尽早发现底座绑定。

产物：

- 通过阈值的 versioned mechanism package。
- 从首个成功机制反推的最小 trace/core contract。
- 第二 Capsule 的 portability canary，不要求一次打通完整功能矩阵。
- 机制归属裁决：Mother、Capsule、Domain 或 lab-only。

只有第二 Capsule 不需要改写机制本体且关键事件不丢失时，才可声明“已在两个具名 Capsule
上复现结构”。仍不得称完全 harness-neutral。

### R4：Software Engineering Confirmation

目标：用冻结组合验证软件工程中的人机协作价值。

运行 H、A、C 和 R 四基线，报告 joint outcome、最佳单方比较、人类注意力、严重风险、恢复、
时间和成本。软件工程 discovery 数据不得进入确认性 holdout。

通过只支持“在已命名的软件工程任务、模型和 Capsule 组合上有效”。

### R5：Second Vertical

目标：检验已晋升机制能否迁移到高对比领域。

先揭示 adaptation set，再用 sealed holdout 确认。若需要 breaking core change，首次跨域检验
判失败；结果收缩到 Domain 或 Capsule，而不是修改原验收口径。

### R6：Productization

目标：只稳定已经跨实验、跨 Capsule 或跨垂直留下来的部分。

可以形成 research preview、experimental SDK、领域产品或上游 Capsule 能力。长期兼容、组织
部署和标准化声明必须由现场数据、升级演练和多个具名组合支持。

## 十一、GitHub 与 Ledger 投影

书面规格已经批准；当前 task graph 使用以下稳定前缀：

- `TASK-MOTHER-*`：母体 Workbench、trace、replay 和组合能力。
- `TASK-CAPSULE-*`：具体执行底座的 fork、能力和测试。
- `TASK-EXP-*`：单一可证伪机制实验。
- `TASK-PROMOTE-*`：从 lab 晋升或裁决归属。
- `TASK-PORT-*`：第二 Capsule 的结构和效果复现。
- `TASK-PACK-*`：软件工程或第二垂直。
- `TASK-GATE-*`：阶段 Continue/Pivot/Stop 决策。

Milestone 调整为：

1. `R0 - Evidence & Mother Choice`
2. `R1 — Runnable Mother v0`
3. `R2 — Mechanism Labs`
4. `R3 — Promotion & Portability`
5. `R4 — Software Engineering Confirmation`
6. `R5 — Second Vertical`
7. `R6 — Productization`

R0 是当前唯一可以挂执行 Issue 的 Milestone。R1-R6 在当前仓库只建立 direction-only
Milestone，用于确认阶段问题、入口条件和 continue/pivot/stop 边界；不设 due date，不提前拆
具体 Issue，也不表示阶段已经启动。

实验 Issue 即使得到负结果，只要方法完整也可由实验 PR 关闭。Promotion 使用新的 Issue/PR。
GitHub 仍是 ledger 的协作投影，不单独决定任务 acceptance 或 gate outcome。

R0 的 ledger、gate report 和历史 Tag 继续留在当前仓库。若 R0 以 `outcome: continue` 解锁
R1，Mother 仓库创建可执行 program ledger 和 successor Milestone；当前仓库的方向占位随即
链接 successor 后关闭。Capsule 与 Domain 仓库只维护各自产物 Issue，并链接 Mother 中的
program task。GitHub Milestone 不跨仓转移，历史记录也不跨仓复制。

### 11.1 保留旧 Issue、Milestone 与 Ledger 语义

迁移只改变后续执行路线，不把旧对象改写成从未表达过的新含义：

- 任务语义和 acceptance 没有变化时，保留原 Task ID、Issue 和历史 Milestone 关系。
- 任务语义发生变化时，不复用旧 ID。旧任务以 `cancelled` 或适用的原终态进入 append-only
  ledger，并记录 `superseded-by`；新语义创建新的 Task ID 和 Issue。
- 旧 Issue 的标题和正文不改造成新任务。通过带 decision commit 的迁移评论、`superseded`
  label 和双向链接说明去向；关闭理由写“由新任务取代”，不写“已完成”。
- 旧 Milestone 不重命名成新阶段。保留原标题和原始描述后关闭，successor 关系记录在 migration
  map；仍服务当前 R0 的 Issue 通过 mutation receipt 重投影到新 R0 Milestone。新 roadmap
  创建具有独立名称和编号的 Milestone。
- 已 accepted 的 `TASK-DEC-001`、历史 PR、commit 和 Tag 保持不变；新方向通过新的 decision
  task 追加。不得为了让进度图好看而重写历史 acceptance。

迁移 PR 必须包含一张 old -> keep/supersede -> new 映射表。没有映射的旧 Issue 或 Task 不能被
批量关闭。

### 11.2 CI 相关性，而非普遍阻塞

CI 是验证证据，不是所有工作的全局同步屏障。本节已经取代旧补救设计中“所有 PR 均等待
完整双平台检查”的普遍阻塞语义，但保留“相关验证必须在终态动作前成立”。
每个任务或 PR 按当前 acceptance 和改动范围将远端检查分成三类：

- `required`：该检查能够推翻当前验收结论，或覆盖被修改的执行、契约、安全、权限、模板或
  平台相关路径。
- `advisory`：结果有诊断价值，但不能改变当前产物是否成立。
- `n/a`：检查与当前改动和 acceptance 没有可说明的因果路径。

具体规则：

1. CI pending 本身不使任务进入 `blocked`，Agent 可以继续不依赖该结果的工作。
2. 只有 `required` 检查会阻塞相应 PR 的合并、gate acceptance 或 Tag；等待发生在终态动作前，
   不要求每次提交后停工。
3. `advisory` 和 `n/a` 不阻塞 handoff、后续独立任务或结论无关的合并。若仓库 ruleset 仍要求
   一个总检查，后续实现应让总检查按改动范围返回适用结果，而不是强迫运行无关矩阵。
4. 远端失败只有在与当前改动或 acceptance 相关时才形成 blocker。已证明属于基础设施故障或
   无关路径的失败，记录检查 URL、判定理由和复现结果后可以 non-blocking；不能只凭直觉忽略。
5. 纯研究说明或计划文档默认要求本地 diff、文档链接和结构检查；未修改脚本、模板或平台行为
   时，完整 OS matrix 默认为 advisory。
6. 修改可执行脚本、CI、本地与远端契约、安全边界、权限或发布行为时，覆盖这些路径的检查
   默认 required，除非有更直接且已记录的替代验证。

PR 或 task receipt 只需记录 `ci-scope: required=...; advisory=...; n/a=...; reason=...`。本阶段
不建设通用变更影响分析器，也不因低风险文档改动增加人工审批。

每个 gate report 增加：

```text
outcome: continue | pivot | stop
```

- Continue：继续当前研究线或创建 Promotion task。
- Pivot：替换 Capsule、收缩到 Domain/Capsule，或选择另一机制，只重跑受影响实验。
- Stop：没有材料性缺口、无法构造可信 control，或维护成本持续超过研究与产品收益。

`accepted` 和 `outcome` 分离。一个方法正确的负结果可以 accepted，同时 gate outcome 为 pivot
或 stop；只有 `outcome: continue` 才能解锁依赖 `@continue` 的下一阶段任务。

## 十二、仓库迁移顺序

当前 `engineering-workflow` 仓库在 R0 继续承担研究控制面和第一垂直，不立刻拆仓。这样保留
现有 PR、Issue、Milestone、ledger 和历史引用。

`TASK-GATE-R0` accepted 且 `outcome: continue` 后、R1 代码落地前：

1. 创建独立 Mother 仓库。
2. 创建 OpenHarness-derived Capsule 仓库并记录 fork point 与许可证。
3. 创建轻量 lab workspace，用 submodule 固定三仓组合。
4. 当前仓库只保留软件工程产品、Domain 资产和必要的跨仓指针。
5. R0 历史证据留在当前仓库，不复制或改写；新仓库通过稳定链接引用。

不在已有证据前创建独立研究控制仓。至少出现两个垂直和真实跨仓实验后，再判断 lab workspace
是否需要演化成长期控制仓或只保持轻量组合仓。

## 十三、明确非目标

- 不把 OpenHarness 或任何第二 Capsule 定义成普适标准。
- 不要求大量 fork 修改持续回流上游。
- 不用 patch 行数、star 或上游同步速度替代产品与研究证据。
- 不在 R0 创建三个空仓库或迁移 GitHub 历史。
- 不在首个机制实验前设计完整通用 Runtime、插件市场、调度器或多租户平台。
- 不要求每个垂直产品共享同一执行 Capsule。
- 不因理论上的可替换性同时维护多个完整 fork。
- 不把所有远端 CI 检查默认升级为任务级 blocker。

## 十四、书面规格验收

本设计在以下条件下视为获批：

1. 母体身份由 Workbench、研究资产和已晋升机制定义，而非某个 Harness。
2. OpenHarness-derived engine 可大量修改，但只作为独立 Capsule。
3. submodule 只在 lab workspace 中固定实验组合，不形成母体源码依赖。
4. 软件工程从 R1 起参与 discovery 和 dogfood，并保留 sealed confirmation holdout。
5. 通用 Core 从重复实验和第二 Capsule 中晋升，不在 R1 前冻结。
6. Continue/Pivot/Stop 与实验 accepted 分离，负结果不会错误解锁下一阶段。
7. 书面规格复核后才改写研究说明、ledger、GitHub Milestone 和 Issue。
8. 旧 Task、Issue 和 Milestone 的原语义通过 keep/supersede 映射保留，不被原地改造成新任务。
9. CI 只有在能影响当前 acceptance 时才 required；pending 或无关失败不阻塞独立进展。
