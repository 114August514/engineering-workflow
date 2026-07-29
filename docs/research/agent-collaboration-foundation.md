# 可演化 Mother 研究平台：研究说明与研发 Roadmap

> 文档类型：Explanation。面向本仓库维护者、Agent 应用开发者和参与泛化升级的
> 人类/Agent 协作者。本文是本次升级的研究与产品边界唯一事实源；执行状态只记录在
> [`todo.md`](../../todo.md) 和 [`done.md`](../../done.md)。

状态：`TASK-DEC-002` 已批准；R0 研究与迁移实施中

基线日期：2026-07-29

第一垂直：软件工程（当前 `engineering-workflow`）

---

## 一、决策摘要

本项目继续把 `engineering-workflow` 作为软件工程垂直产品，不从这个 Domain 仓库直接
冻结通用 Runtime。当前研究路线是：

```text
Domain Product -> Evolvable Mother -> Capsule Port -> Substrate Capsule
                         |
                         +-> lab workspace 固定一次实验组合
```

1. **Evolvable Mother** 拥有 Workbench、实验协议、规范化 trace/artifact、evaluator，以及
   incubating/promoted mechanisms。机制先在具名组合中被证伪或支持，再决定是否晋升。
2. **Substrate Capsule** 封装具体执行底座。OpenHarness-derived 是首个可替换候选，不是
   永久标准；证据不支持时可以深改、替换或停止。
3. **Domain Product** 拥有领域术语、资产、策略与验证器。当前仓库既是软件工程 Domain，
   也只在 R0 临时承担研究控制面。
4. **lab workspace** 只固定一次实验使用的 Mother、Capsule、Domain、预注册和运行 receipt，
   不成为三者的业务源码仓。

通用 Core、稳定 Capsule contract 和 harness-neutral 声明都不是起点。它们只能由重复实验、
第二 Capsule portability canary 和第二垂直 sealed holdout 的证据晋升出来。Gate 审计结果使用
`accepted`，路线结果另记 `continue | pivot | stop`；只有 `accepted + continue` 解锁下一阶段。

## 二、问题不是“Agent 不够自治”

当前 Agent 的主要缺陷可以分成四层。

| 层 | 已观察到的缺陷 | 不能只靠更强模型解决的原因 |
|---|---|---|
| 任务 | 目标含糊、完成条件漂移、长任务遗忘、错误分解 | 目标、约束和状态没有独立于上下文存在 |
| 协作 | 人只在开头下令或末尾验收；审批疲劳；交接丢信息 | 缺少角色、决策权、Human Task 和注意力路由 |
| 执行 | 工具误用、越权、外部副作用不可回滚、并发冲突 | 需要确定性策略、隔离、幂等和补偿机制 |
| 认知 | 过度信任、证据与结论混在一起、压缩导致约束丢失 | 需要 Claim/Evidence/Verification 分离和可追溯状态 |

一项覆盖 106 个实验、370 个效应量的预注册元分析发现，人机组合一般优于单独的人，
但往往仍差于人或 AI 中表现更好的一方；决策任务尤其容易出现协同损失，创造任务更可能
获得增益。这意味着“把人放进循环”本身不是产品价值，任务分配与交互设计才是。
[Nature Human Behaviour](https://www.nature.com/articles/s41562-024-02024-1)

对知识工作者的研究还显示，对生成式 AI 越有信心，投入的批判性思考越少；工作重心会从
直接产出转向验证、整合与监督。系统必须保护人的判断能力，而不是只减少点击次数。
[CHI 2025 研究](https://www.microsoft.com/en-us/research/publication/the-impact-of-generative-ai-on-critical-thinking-self-reported-reductions-in-cognitive-effort-and-confidence-effects-from-a-survey-of-knowledge-workers/)

因此，北极星不是自治程度，而是：

> 在给定风险、成本和人类注意力预算下，人机联合结果是否稳定优于最佳单方。

## 三、成熟 coding harness 已经收敛的部分

下表区分“应该复用的工程基线”和“仍需研究的协作层”。源码存在只能证明机制存在，
不能直接证明效果领先。

| 能力 | 成熟模式 | 参考实现 | 本项目判断 |
|---|---|---|---|
| Agent loop | 模型提议工具调用，宿主执行并回灌结果，直到完成或触达预算 | [Claude Agent SDK](https://code.claude.com/docs/en/agent-sdk/agent-loop)、[Kimi Code](https://github.com/MoonshotAI/kimi-code) | 复用 |
| 工具 | JSON Schema、类型校验、取消、结构化错误、生命周期 hooks | [OpenHarness](https://github.com/HKUDS/OpenHarness)、[Kimi tools](https://moonshotai.github.io/kimi-code/en/reference/tools.html) | 复用协议和实现 |
| 状态 | append-only 事件、JSONL、resume/fork/replay、请求 trace | [Kimi sessions](https://moonshotai.github.io/kimi-code/en/guides/sessions.html)、[oh-my-pi](https://github.com/can1357/oh-my-pi) | fork/适配候选 |
| 上下文 | 状态与上下文投影分离，自动压缩，大结果外置，Skill 按需加载 | [12-factor-agents](https://github.com/humanlayer/12-factor-agents)、[Claude context](https://code.claude.com/docs/en/agent-sdk/agent-loop) | 复用模式 |
| 人工控制 | plan、approve/deny、修改参数、steer、cancel、resume | [Claude user input](https://code.claude.com/docs/en/agent-sdk/user-input)、[Kimi interaction](https://moonshotai.github.io/kimi-code/en/guides/interaction.html) | 适配为统一事件 |
| 安全 | deny-first 权限、OS sandbox、工作区和网络边界 | [Claude permissions](https://code.claude.com/docs/en/permissions)、[sandbox](https://code.claude.com/docs/en/sandboxing) | 复用原语，自研跨后端策略 |
| 扩展 | Skills、MCP、hooks、plugins、commands | [Claude features](https://code.claude.com/docs/en/features-overview)、[Kimi plugins](https://moonshotai.github.io/kimi-code/en/customization/plugins.html) | 不再造插件协议 |
| 并行 | 独立上下文、后台任务、worktree、共享任务表和 mailbox | [Claude subagents](https://code.claude.com/docs/en/sub-agents)、[agent teams](https://code.claude.com/docs/en/agent-teams) | 复用执行，补协作语义 |
| 宿主 | 同一运行时服务 TUI、IDE、SDK、Web、CI；ACP 连接编辑器 | [ACP](https://agentclientprotocol.com/get-started/introduction)、[Kimi ACP](https://moonshotai.github.io/kimi-code/en/reference/kimi-acp) | 做适配，不造新宿主协议 |

`114August514/claude-code` 当前是未完成的 Python 移植脚手架，没有真实 Agent loop、
会话、权限或工具执行实现，也没有明确许可证。它只用于记录来源边界，不作为 Claude Code
成熟架构的证据。Claude Code 相关判断只采用 Anthropic 官方仓库和文档。
[仓库声明](https://github.com/114August514/claude-code/blob/main/README.md)

## 四、协议边界：不发明第五种传输层

已有协议已经切走大量连接问题：

| 协议 | 已解决 | 没有负责 |
|---|---|---|
| [MCP](https://modelcontextprotocol.io/docs/2026-07-28/learn/architecture) | Agent 与工具、资源、提示和 elicitation 的交换 | Agent 如何管理共同目标、角色、证据和组织流程 |
| [ACP](https://agentclientprotocol.com/get-started/architecture) | 编辑器/宿主与 coding agent 的会话、流式更新和权限请求 | 跨领域流程语义与跨组织治理 |
| [A2A](https://a2a-protocol.org/latest/) | 独立 Agent 之间的任务、消息和产物传输 | Agent 内部执行、工具调用和人类共同决策 |
| [AG-UI](https://docs.ag-ui.com/introduction) | Agent 后端与用户界面的事件、共享状态、中断和 UI 意图 | 什么是可接受证据、谁有决策权、何时应找谁 |

本项目优先把核心对象映射到这些协议的 extension、metadata、shared state 或 custom event。
只有无法表达且经过两个垂直验证的语义，才考虑提出新的标准字段。传输、鉴权、序列化和
流式连接本身不构成产品差异。

## 五、产品边界

```text
软件工程 Domain Product（本仓库）
           |
           v
Evolvable Mother
  Workbench · preregistration · trace/artifact · evaluator
  incubating mechanisms · promotion records
           |
           v  当前实验所需的最小 Capsule Port
Substrate Capsule（首个候选：OpenHarness-derived）
           |
           v
模型 · 工具 · sandbox · execution harness

lab workspace = Mother + Capsule + Domain 的具名 composition receipt
```

### 5.1 所有权边界

| 组件 | 拥有 | 不拥有 |
|---|---|---|
| Mother | Workbench、实验资产、规范化 trace/artifact、evaluator、机制生命周期 | 软件工程对象、某个 harness 的私有类型、未经证据支持的永久 Core |
| Capsule | 具体底座接入、私有执行类型、能力降级、底座维护与替换 | Mother 的实验结论、Domain 业务语义 |
| Domain | 领域术语、任务、策略、验证器、产品行为 | Mother/Capsule 的通用接口定义权 |
| lab | 一次实验的版本组合、预注册、预算与结果引用 | Mother、Capsule、Domain 的业务源码 |

跨边界只暴露当前实验必需的信息。旧路线中的 `Actor`、`Objective`、`WorkItem`、`Decision`、
`HumanTask`、`ActionEnvelope`、`Claim`、`Evidence`、`Verification`、`MemoryRecord` 和 `Handoff`
保留为待实验的机制/对象候选，不再作为 R1 之前必须冻结的通用对象模型。

### 5.2 R0 与 R1 composition manifest

R0 尚无独立三仓。pre-bootstrap manifest 至少记录：experiment/preregistration 版本、当前仓库
commit、彼此不同的 Mother prototype/Capsule spike/Domain path、OpenHarness upstream 与
fork-point、model/prompt/tool/config/evaluator hash、treatment/sham/budget/task-set，以及
trace/artifact/result 引用。同一个 commit 不得复制成 Mother、Capsule、Domain 三条仓库身份。

只有 `TASK-GATE-R0-002` 达到 `accepted + continue`，R1 才创建独立 Mother、Capsule 和 lab，
并用 lab commit 的 submodule gitlink 固定三个 repository URL 与 exact commit。

### 5.3 跨实现研究不变量

1. **状态不等于上下文。** 完整状态可持久、查询和回放；模型只看到任务所需投影。
2. **提议不等于授权，授权不等于执行。** 三者分别记录并可由不同 Actor 完成。
3. **Claim 不等于 Evidence，Evidence 不等于 Verification。** 完成不能靠自我声明。
4. **每个副作用都有主体、策略、结果和恢复信息。** 不可补偿时必须显式升级风险。
5. **人类注意力是一等预算。** 通知必须说明紧迫性、影响、可选项和不响应的后果。
6. **回放绑定版本。** 模型、提示、工具 schema、策略、组合和上下文投影都进入 trace。
7. **领域内容不提前晋升。** Git、PR、测试和部署首先属于软件工程 Domain。
8. **默认复用现有协议。** 新 wire protocol 需要证明已有协议无法承载。
9. **负结果也是有效结果。** `pivot` 和 `stop` 不得被改写成 `continue` 来维持 roadmap。

## 六、Build / Fork / Adapt 决策规则

“成熟部分直接 fork 后适配”是默认偏好之一，但 fork 不是免费的复制。每个候选组件都必须
经过 Component Intake Gate。

Gate 先看硬条件，再比较成本。需要进入 `enforce` 路径的执行面至少必须支持：effectful
action 执行前拦截、稳定 session/action ID、cancel、持久 session、真实 pause/resume、
subagent lineage，以及可注入的失败测试。只能观测其中一部分的后端仍可接入，但 adapter
必须声明为 `observe` 或 `advise`，不能伪装成等价的强保障后端。

| 选择 | 适用条件 | 必须记录 |
|---|---|---|
| Adopt | 公共 API 足够、行为可配置、不需要维护补丁 | 版本、供应链、替换路径、conformance tests |
| Fork | 许可证明确；模块边界清楚；测试可独立运行；修改面稳定；上游同步可承受 | upstream commit、patch queue、同步频率、安全差异、退出方案 |
| Adapt | 后端闭源/商业许可，或已有稳定 CLI/SDK/ACP/API | 能力协商、事件归一化、降级语义、后端特有限制 |
| Build | 属于产品核心语义，或现有实现无法满足强隔离、确定性、事务与合规要求 | 不复用的证据、维护预算、替换接口、验证计划 |
| Reject | 许可证不清、测试不足、强耦合、默认不安全或上游不可维护 | 拒绝理由和重新评估触发条件 |

候选组件的首轮判断：

- **Kimi Code**：MIT，可研究事件日志、工具契约和会话恢复；内部 v2 仍快速变化，先做
  模块与发布边界审计，再决定 fork 粒度。
- **OpenHarness**：适合作为 Python reference runner 候选；coding-first，sandbox 和
  多 Agent 隔离不能原样视为安全基线。
- **oh-my-pi**：事件树、交互控制与扩展机制值得评估；默认高自治模式和同进程扩展需要
  隔离重做。
- **Claude Agent SDK**：能力成熟但不是可 fork 的开源内核；只通过官方 SDK/CLI/ACP
  适配，不依赖私有 transcript 或内部工具名。
- **12-factor-agents**：采用设计原则，不把经验性指南当成效果证据或可 fork runtime。

任何 fork 都应保持“薄补丁”：上游代码与本项目协作语义分层，禁止把 Domain Pack 和
产品策略直接揉进 fork。R5 以前最多维护一个正式 execution-core fork；其他实现优先走
adapter 或选择性复用 package。若 patch queue 持续扩大，应转为 adapter 或替换实现。

## 七、研究问题、假设与证伪

| ID | 研究问题与当前假设 | 可证伪信号 | 首轮方法 |
|---|---|---|---|
| RQ-00 | 当前静态 workflow/skill 是否已经比裸 harness 减少评审负担或严重遗漏 | 同模型、同任务下没有稳定改善 | 裸 harness 与静态 skill 配对盲评 |
| RQ-01 | 协作运行时能否在受限注意力和成本下，使 hybrid 稳定优于最佳单方 | hybrid 不优于 `max(human, agent)`，或增益完全来自更多时间/成本 | 同任务四基线配对实验 |
| RQ-02 | 任务特征能否预测 human-only、agent-only、hybrid 的最佳分配 | 路由策略不优于固定分配，或跨参与者无法复现 | 按任务轴分层，预注册路由规则 |
| RQ-03 | 是否存在跨 harness、跨领域的最小协作语义 | 第二后端或第二垂直要求重写核心对象，而非添加领域扩展 | 两后端 trace 映射和 schema conformance |
| RQ-04 | 结构化 Human Task 能否降低审批疲劳而不增加事故 | 中断数、等待时间或漏审率不降；严重错误增加 | 与逐工具审批、自由聊天比较 |
| RQ-05 | Claim/Evidence/Verification 分离能否减少过度声明和错误验收 | 证据覆盖率提高但错误接受率不降，或验证成本超过收益 | 注入可检测错误，盲评最终产物 |
| RQ-06 | ActionEnvelope 与补偿契约能否覆盖非代码副作用 | 关键动作无法幂等、无法记录或无法恢复；策略只能靠提示词 | 模拟 API、工单、部署和消息动作故障 |
| RQ-07 | 薄 adapter 是否足以控制不同 harness | 无法在动作执行前拦截，或事件缺失使状态不可重建 | Claude + 一个开源后端的能力矩阵和 fixtures |
| RQ-08 | 多 Agent 何时值得使用 | 顺序/工具密集任务中成本和错误放大，调度器仍无有效降级 | 可分解与顺序任务对照，限制 fanout |
| RQ-09 | 软件工程中验证的机制能否迁到第二垂直 | 需要引入 Git、PR、测试等核心字段，或核心发生 breaking change | 高对比第二垂直复现同一协作闭环 |
| RQ-10 | fork/adapt 是否比 wrapper、上游贡献或窄幅重写更快且长期成本更低 | 初次接入无速度优势，或 12 个月维护成本更高 | 平行 spike、升级演练和 patch/TCO 记录 |

## 八、证据标准

每条产品判断必须标注证据等级，项目热度、star 数和自述不能替代效果证据。

| 等级 | 可接受证据 | 可支持的结论 |
|---|---|---|
| A | 同行评审元分析、随机对照实验、预注册人类实验 | 因果或较强的可推广效果判断 |
| B | 公开 benchmark、真实任务数据、严谨 field study、可复现实验 | 受任务与样本边界约束的效果判断 |
| C | 官方源码、测试、规范、文档、issue 和 release | 机制存在、接口行为和已知限制 |
| D | README、自述、案例文章、演示 | 研究线索和项目定位，不能证明效果 |

来源等级与研究成熟度是两条轴。一个实现可以有很强的 C 级源码证据，但仍然只有 E1 的
效果证据：

| 阶段 | 能证明什么 |
|---|---|
| E0 | 访谈、日志和专家判断：只能生成假设与任务集 |
| E1 | 合约测试、离线 replay、故障注入：证明可实现性，不证明用户价值 |
| E2 | 预注册随机对照与机制消融：提供局部因果证据 |
| E3 | 多 harness、模型、仓库和任务层复现：检验可移植性 |
| E4 | 真实团队持续 6–12 周的集群随机或 stepped-wedge：检验现场价值 |
| E5 | 连续上游升级与长期维护：检验经济性和抗漂移能力 |

研究记录必须同时保存：来源、日期/版本、方法、样本、可支持的 claim、不能支持的 claim、
反证和适用边界。冲突来源不做平均，必须解释为什么采用其中一个判断。

关键研究基线包括：

- 人机协同元分析：[When combinations of humans and AI are useful](https://www.nature.com/articles/s41562-024-02024-1)
- HAI 交互准则：[Guidelines for Human-AI Interaction](https://www.microsoft.com/en-us/research/publication/guidelines-for-human-ai-interaction/)
- 解释与互补性的边界：[Does the Whole Exceed its Parts?](https://arxiv.org/abs/2006.14779)
- 认知强制干预：[Cognitive Forcing Functions](https://arxiv.org/abs/2102.09692)
- 真实软件任务中的协作方式：[Sharp Tools](https://www.microsoft.com/en-us/research/publication/sharp-tools-how-developers-wield-agentic-ai-in-real-software-engineering-tasks/)
- experienced OSS 开发者 RCT：[METR early-2025 study](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/)
- Agent 评测方法：[AI Agents That Matter](https://arxiv.org/abs/2407.01502)
- 动态用户、工具和策略可靠性：[tau-bench](https://arxiv.org/abs/2406.12045)
- prompt injection 与工具风险：[AgentDojo](https://arxiv.org/abs/2406.13352)
- 长期记忆：[LongMemEval](https://openreview.net/pdf?id=pZiyCaVuti)
- 长上下文位置偏差：[Lost in the Middle](https://aclanthology.org/2024.tacl-1.9/)

## 九、评测设计

### 9.1 四个强制基线

每个核心实验在同一任务、同一输入和同等外部资源下至少比较：

1. `H / human-only`：正常工具、IDE、测试和文档，但没有生成式 Agent。
2. `A / agent-only`：相同模型、工具、Domain 资产和预算，执行期间没有人工干预。
3. `C / conventional-capsule`：目标 Capsule 的原生人机工作流，加同一份静态 Domain 资产，
   但没有待测 Mother mechanism。
4. `R / mother-treatment`：与 C 使用同一个 Capsule、UI、模型、工具、提示、预算和任务集，
   唯一新增变量是预注册的 Mother mechanism。

主因果对比是同底座 `R-C`；`R-H` 判断人的效率收益，`R-A` 判断协作带来的质量与风险收益。
每个机制实验还必须有可信 sham 和必要消融，不能用“更强底座”冒充 Mother 效果。RQ-00 另设
“裸 harness”辅助臂，证明静态 skill 本身是否创造价值；agent-only benchmark 不能推断
人机协作效果。

### 9.2 任务分层

样本必须覆盖以下轴的组合，避免一个平均分掩盖 jagged frontier：

- 创造任务 / 决策任务
- 可并行分解 / 强顺序依赖
- 可逆 / 不可逆或高恢复成本
- 有客观验证器 / 依赖专家判断
- 低不确定性 / 高不确定性
- 单 Agent 足够 / 可能受益于多 Agent
- 短任务 / 跨会话长任务

任务成熟度从低到高分为：L0 合约、权限、恢复和注入故障；L1 带隐藏验收的单任务；
L2 从澄清、计划到评审返工的完整流程；L3 含中断、交接、需求变化和长期维护的现场任务。
任务集同时保留冻结公开集、私有 holdout 和真实现场样本。

### 9.3 指标

| 类别 | 核心指标 |
|---|---|
| 结果 | 专家盲评质量、任务成功、关键错误、需求覆盖、`pass^k` 稳定性 |
| 协同 | `hybrid - max(human, agent)` 的结果差；正确任务分配率 |
| 注意力 | 人工分钟数、中断次数、每次决策上下文完整度、无效审批比例 |
| 安全 | 策略违规、未授权动作、不可恢复副作用、注入成功率、隔离逃逸 |
| 证据 | Claim 证据覆盖、来源有效率、错误接受率、验证者一致性 |
| 恢复 | 检测时间、停止时间、恢复时间、重放成功率、补偿完成率 |
| 经济性 | wall time、token、模型成本、基础设施成本、返工量 |
| 人因 | 信任校准、主观工作负荷、情境理解，而非只测满意度 |

三个主指标不得压成可操纵的综合分：validated completion、active human attention、
serious defect escape。其他指标以 Pareto 前沿和分项结果报告。

### 9.4 机制消融与统计约束

R2 的每个机制独立预注册 treatment、sham、预算、MME、停止条件和消融。多个机制不得先捆成
一个 Runtime 再用总体结果替每层背书；unsupported、falsified 或 inconclusive 都不能解锁
promotion，只有达到预注册阈值的 supported 结果才另建晋升 Task。

研究开始前冻结主要终点、最小有意义效应（MME）、非劣界、功效分析、缺失数据、失败
episode、超时、多重比较和一次确认性复验。模型重试和 seed 嵌套在 task 内，不能冒充独立
样本；人类任务使用分层随机、顺序平衡和盲法评审。

首轮 pilot 用于估计方差，不能用于宣告成功。供 RES-004 定标的初始 MME 候选是：

- `R-C` 的 validated completion 提高 10 个百分点且人工时间不恶化超过 5%；或人工时间
  降低 20%，质量非劣界为 -5 个百分点。
- 严重缺陷的单侧 95% 置信区间排除超过 2 个百分点的恶化。
- 高危故障召回不低于 90%，误阻断不高于 5% episode，周期增加不超过 10%。

这些数字是设计先验，不是既有证据；必须在看确认性结果前根据 pilot、功效和业务损失
冻结或改写。统计显著但低于 MME 不算产品成功。

主要混淆因素必须锁定或建模：Mother/Capsule/model 版本、提示与上下文、工具权限、token/时间
预算、UI、参与者经验与仓库熟悉度、学习/疲劳/携带效应、任务泄漏、评审者偏差、Agent
随机性、基础设施延迟和研究期间的上游演进。失败 episode 不得事后排除。

## 十、研发 Roadmap

Roadmap 是可反驳问题与证据门槛，不是按季度排列的功能清单。每个 Gate 先审计方法与证据是否
完整（`accepted`），再单独记录 `outcome: continue | pivot | stop`。只有
`accepted + continue` 解锁下一阶段；pivot 创建具名 successor route，stop 停止投入。

```text
R0 Evidence & Mother Choice
              |
              v
R1 Runnable Mother v0
              |
              v
R2 Mechanism Labs
              |
              v
R3 Promotion & Portability
              |
              v
R4 Software Engineering Confirmation
              |
              v
R5 Second Vertical
              |
              v
R6 Productization
```

### R0：Evidence & Mother Choice

回答是否存在值得研发的材料性协作失败，以及首个 Capsule 是否可用。最小产物是 evidence
register、能力矩阵、协议边界、评测设计、OpenHarness-derived spike、结构不同候选对照、一个
范围受限的 Mother prototype、pre-bootstrap manifest、proof-of-mechanism 和 Gate report。
`continue` 要求现有方案未完整覆盖、treatment/sham 可信、Mother/Capsule 可独立维护，并具名
选择 R1 Capsule；否则 pivot 到替代候选或 stop。

R0 只物化当前可执行任务与一个条件化 R1 bootstrap bridge，不创建 Mother/Capsule/lab 仓库，
也不打 `r0-accepted` tag 冒充 Gate 已完成。R1-R6 可以先建立 direction-only Milestone，
但只能写阶段问题、入口条件和 continue/pivot/stop 边界；不得挂执行 Issue、设置 due date 或承诺
具体实现。只有前一 Gate `accepted + continue` 后，相应阶段才建立可执行 task graph。

### R1：Runnable Mother v0

回答 Mother、Capsule、Domain 是否能组成可记录、可重放的真实闭环。产物是独立三仓与 lab、
软件工程 Domain 接入、真实任务、three-repo manifest、trace/artifact 和 sham。只有 clean-checkout
能按具名 exact commit 重跑，才可 continue；记录不稳定、sham 不可信或独立重跑失败则 pivot/stop。

### R2：Mechanism Labs

每次只回答一个机制能否改善 R0 已观察失败。每机制独立预注册 MME、预算、treatment/sham、
消融和失败 episode。supported 且达到预注册阈值时另建 promotion Task；falsified/inconclusive
保留为证据并换机制、收缩或停止，不能靠 Gate accepted 自动晋升。

### R3：Promotion & Portability

裁决有效机制属于 Mother、Capsule、Domain 还是 lab-only。产物是 versioned mechanism、最小
trace/core、第二 Capsule canary 和归属报告。第二 Capsule 不改写机制本体且关键事件无损才支持
Mother promotion；contract breaking、效果消失或反向时收缩为 Capsule-specific 或 Domain-specific。

### R4：Software Engineering Confirmation

在 sealed holdout 上比较 H/A/C/R，报告 joint outcome、最佳单方、人类注意力、风险、恢复、时间
和成本。预注册 MME、非劣界和安全 guardrail 同时成立才 continue；无材料性收益或安全边界失败
则 pivot/stop，不用开发集结果替代确认性证据。

### R5：Second Vertical

把已晋升机制迁到对象、验证器和副作用显著不同的领域。产物是 adaptation set、第二垂直
holdout 和 core-change audit。无 breaking core change 且收益/安全门槛成立才支持更宽声明；
需要 breaking change 时收缩为 Domain/Capsule scope，而不是维护虚假的通用 Core。

### R6：Productization

只稳定已有多次实验、多个具名组合和现场数据共同支持的部分，交付 research preview/SDK/领域
产品、兼容矩阵、迁移说明和升级演练。证据不足的机制保持 experimental、收缩或退役；此前不以
生态规模、marketplace 或“支持所有 Agent”作为成功指标。

所有阶段共享四个发布阻塞项：holdout 泄漏或不可复现的 composition、没有 evidence 的虚假终态、
未审批不可逆副作用，以及恢复后重复执行。其他未知风险先显式记录，在真实失败影响 Gate 时补保护。

## 十一、多 Agent 研究协作协议

本仓库继续使用“预写日志 + undo log + 限界上下文锁”，但把任务账本标准化：

1. `todo.md` 是当前任务状态；`done.md` 是 append-only 完成证据。研究正文不复制任务状态。
2. 每项工作使用固定字段任务块，包含唯一 ID、revision、RQ、依赖、owner、claim token、
   允许写入范围、产物、验收、证据、阻塞、handoff 和副作用。
3. 每个协调周期只有一个 ledger steward。worker 不并发编辑账本，由 steward 在派发前 claim、
   回收后迁移，避免 `todo.md` 成为热点冲突文件。
4. 账本操作提交 `task ID + expected revision + claim token`，由 steward/CAS 检查后递增 revision。
   handoff 后旧 token 失效，旧会话不能继续写入。
5. `Write scope` 是锁，不是参考。两个活跃任务范围重叠时必须拆分或排序；路径只允许仓库
   相对精确路径或目录前缀，不允许 glob、绝对路径和 `..`。
6. 只有依赖以 `accepted` 终态出现在 `done.md` 的任务才能进入 `ready`。`cancelled` 和
   `rolled-back` 也保留在 done，但不能满足依赖。
7. worker 只提交其范围内的产物和证据，不自行扩展产品边界，不把研究推断写成事实。
8. 完成时每个 acceptance criterion 都必须有同 ID 的 evidence。steward 在一次事务或一次
   Git commit 中向 done 追加完整任务块并从 todo 删除。
9. 没有事务能力时必须先写 done、再删 todo。中断最多留下带相同 move token 的短暂重复；
   恢复器核对 revision/claim 后补删。绝不能先删 todo，避免任务永久丢失。
10. blocked 任务必须写清阻塞事实、已经尝试的路径和重新触发条件，不能只写“需要确认”。
11. handoff 必须先记录绿色 checkpoint、下一步和未决风险，再释放 owner/claim；禁止直接
    把 owner 名字替换成新 Agent。
12. 任何外部写操作在执行前登记 effect 与对应 undo；不可逆动作登记人工批准引用。研究
    阶段默认只读外部来源。
13. commit 遵循本仓库格式，并在描述中带任务 ID，例如：
    `docs: TASK-RES-001 建立协作底座证据登记册`。
14. GitHub Issue 是公开协作视图，`todo.md` / `done.md` 是随代码版本化的可审计状态源。
    每个已物化任务用 `tracking` 记录 Issue、PR 和 Milestone；GitHub label 或关闭状态不能
    单独覆盖 ledger state。
15. PR 必须写 Task ID 并引用对应 Issue；只有该 PR 满足全部 acceptance 且合入后才能使用
    `Closes #N`。中间 spike、部分证据或依赖 PR 只使用 `Refs #N`，不能提前关闭任务。
16. Milestone 分为当前执行与方向占位两种：只有当前阶段可挂执行 Issue；未来阶段只写问题、
    入口和结果边界，不设 due date，进度百分比不构成验收。Gate report 必须分别记录
    `state: accepted` 与 `outcome: continue | pivot | stop`；只有 `accepted + continue` 才能
    解锁下一阶段。Tag 保护由独立任务验收，未满足时不得创建 `rN-accepted`。

## 十二、当前非目标

- 不承诺支持所有模型、所有 harness 或所有业务领域。
- 不先造 TUI、IDE、聊天前端、模型 gateway、MCP/A2A/ACP/AG-UI 替代协议。
- 不把多 Agent 数量、自治时长、token 消耗或代码产量当成北极星。
- R0 不创建独立 Mother、Capsule 或 lab；R1 只在 `TASK-GATE-R0-002@continue` 满足后 bootstrap。
- 不把 fork 等同于复制整个仓库；不接收许可证不清或无法持续同步的来源。
- 不用单一 benchmark、demo 或 README 声明证明跨领域泛化。

## 十三、决策与文档维护

- 本文是当前研究问题、组件边界、阶段门槛和证据方法的唯一事实源。
- 批准来源见 [`TASK-DEC-002` ADR](../decisions/0001-evolvable-mother-research-platform.md)，
  历史身份与外部效果见 [GitHub Roadmap 迁移映射](github-roadmap-migration.md)。
- 任务状态只维护在 [`todo.md`](../../todo.md)；完成记录只维护在
  [`done.md`](../../done.md)。
- 架构或复用选择一旦涉及不可逆投入，写入 `docs/decisions/`，不直接改写历史理由。
- 新证据可以更新判断，但必须同时记录原判断为何失效、影响哪些 RQ 和 roadmap gate。
- 如果本文开始包含实现细节，应把实现拆入通过审阅后的独立 implementation plan，本文只保留
  决策和指针。
