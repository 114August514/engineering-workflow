# 审核修复与最小治理设计

> 状态：方向已批准，等待书面规格复核
>
> 适用范围：PR #12，`agent/research-foundation`
>
> 决策原则：只硬挡确定性错误；低概率、可恢复、局部影响的问题采用鸵鸟原则。

## 一、目标

修复 PR #12 中会导致错误放行、历史不可审计或研究结论失真的问题，同时避免把研究仓库
提前建设成分布式工作流系统。

本次完成后，仓库应满足：

1. 默认分支上的 ledger 能真实决定任务与 roadmap gate 是否解锁。
2. `todo.md` / `done.md` 的确定性不变量由 BSD-compatible 测试保护。
3. R0 不再用错误 treatment 停止 Runtime 研究，第二垂直不再参与核心塑形后又充当盲测。
4. GitHub 强制经过 PR 与现有双平台 CI，但不强制人工 approval。
5. R0 Tag 只有在 gate 证据和 Tag 保护都成立后才能创建。

## 二、采用与拒绝的方案

采用“最小不变量修复”：将 Git commit 作为唯一事务边界，机器检查可离线确定的 ledger
关系，研究设计只补足会改变结论的识别问题，GitHub 只启用当前需要的保护。

不采用纯文档修辞修补。它无法满足本仓库“重复事实必须机器检查”的约束。

不采用完整防御控制面。本阶段不实现租约、心跳、steward 选举、两阶段提交、远端状态同步、
自动 Tag/Release、通用统计平台或第三垂直。这些机制只有在实际故障频率和损失证明其值得时
再进入 roadmap。

## 三、权威状态与初始快照

只有默认分支上的 `todo.md` / `done.md` 是权威状态。PR 分支中的 ledger 是拟议的合入后
状态，GitHub Issue/label 表示当前默认分支的协作视图，两者短暂不同不构成状态冲突。

PR #12 必须 squash merge。该 squash commit 是 `ledger:v1` 的初始快照；初始记录统一从
`rev: 1` 开始。快照进入默认分支后：

- `done.md` 的终态任务块不可原地修改；纠错通过新的 amendment/decision task 追加。
- 非终态任务的任何字段变化都递增 `rev` 并刷新 `updated`。
- GitHub 关闭状态不能覆盖 ledger；合入 ledger 状态迁移的 PR 才能改变权威状态。
- 最终交付 PR 可以预先包含 `Closes #N`，GitHub 只会在合入默认分支时执行关闭。

这是一项一次性 bootstrap 规则，不要求重写当前未合入分支的历史。

## 四、R0 Gate 进入任务图

新增 `TASK-GATE-R0`，映射 GitHub Issue #13，产物为
`docs/research/gates/r0.md`。它保持 `blocked`，直到以下依赖均为 `accepted`：

- `TASK-RES-001` 至 `TASK-RES-005`
- `TASK-FORK-001`
- `TASK-EVAL-000`
- `TASK-OPS-001`
- `TASK-OPS-002`

`TASK-ADR-001` 和 `TASK-CORE-001` 直接依赖 `TASK-GATE-R0`；后续 R1 任务通过它们间接依赖
R0。这样 GitHub milestone 只是投影，真正的解锁决定存在于版本化依赖图。

`TASK-GATE-R0` 的 acceptance 包含：R0 gate report、证据登记、停止条件裁决、默认分支 commit
以及 Tag 保护 receipt。关闭 Milestone 本身不是 acceptance evidence。

## 五、研究设计修复

### 5.1 静态 skill 不再替 Runtime 作停止决定

RQ-00 只回答现有软件工程 Domain Pack 是否比裸 harness 有行为价值。静态 skill 没有收益时，
结论是“当前 Domain Pack 尚未验证”，不是“Runtime 不值得研究”。

Runtime 的 R0 继续条件改为：观察到至少一个高频或高损失协作失败，现有协议/产品未完整覆盖，
且窄幅 instrumented proof-of-mechanism 表明持久状态、确定性拦截或结构化 Human Task 至少一种
机制能改变该失败。没有这样的缺口或 proof 失败，才停止平台化。

### 5.2 第二垂直封存

R0 的 `TASK-RES-005` 只收集候选领域的 owner、任务类型、风险、验证方式、隐私边界和可取得
样本量，不向核心设计者暴露真实任务内容或历史事件 trace。

R4 核心 schema 冻结并记录 hash 后，R5 才由领域 owner 揭示第二垂直：

- adaptation set 用于编写 Domain Pack，不允许静默修改核心。
- sealed holdout 用于确认性评测。
- 若必须 breaking-change 核心，首次跨域检验判失败；修订后必须使用新的未见 holdout。

通过第二垂直只支持“已在两个高对比垂直复现”，不支持“适用于所有领域”的声明。本阶段不因
理论上的第三垂直再增加成本。

### 5.3 可识别的评测

`TASK-RES-004` 必须在实施前定义：

- R 与 C 运行在同一 host；C 使用记录相同 trace 但不执行 Runtime policy 的 instrumented sham。
- 固定并 hash base prompt、tool schema、authority envelope 和任务输入。
- Runtime 新增的消息、token、延迟、Human Task 与审批次数单独计量，不伪装成相同成本。
- 明确 task、participant、repository/team 的独立采样单位及层级模型。
- `hybrid > H` 与 `hybrid > A` 分别估计，并用联合区间判断 synergy，不使用样本内 winner。
- 零事故报告为 `0/N`、故障矩阵覆盖和单侧置信上界。
- safety-critical event 需要 100% lossless 表达；普通事件不使用可吞噬语义的 catch-all extension。

删除“90% 核心不变”这一不可复现百分比。跨域 gate 改为：核心对象与事件无 breaking change、
旧 golden traces 继续通过、新内容只通过明确版本的 extension 或 Domain Pack 出现。

### 5.4 证据与成熟度

A-D 只表示来源强度，不直接授予因果结论。每个 claim 还必须记录设计、偏差风险、直接性、
人群/任务适配、精度、复现和时效。自报调查只支持关联与假设，不表述为干预因果。

R0 的措辞从“值得产品化”收缩为“值得继续 R&D”，并要求真实工作流失败、发生频率/损失、
当前 workaround、注意力成本和领域 owner 承诺。

R6 可以在 R5 后开始实验性产品化，但声明分级：E2 为 research preview，E3 为 experimental
SDK，E4 才能称稳定组织部署，E5 才能提出长期兼容或标准化成熟声明。这样不阻塞早期交付，
也不透支证据。

## 六、最小 Ledger Contract

每个任务块保留现有字段，并新增显式 `undo`。`done.md` 额外要求唯一 `move` token。

`effect` 只记录会改变外部对象生命周期、可见性、权限或发布状态的 material effect。一次批准
下创建的一组 GitHub bootstrap 对象可合并成一个 effect；常规只读、评论和无状态查询不单独
登记。

非空 effect 与 undo 使用相同 `FX-*` ID。无法恢复的动作写 reconciliation，而不是伪造回滚：

```text
effect FX-GH-BOOTSTRAP: create milestone/issues/pr/labels; receipts=...
undo FX-GH-BOOTSTRAP: reconcile-only; close created resources; retain audit history
```

三份 bootstrap 终态记录使用按 task/revision 唯一的 move token。Git commit 同时完成“向 done
增加完整块、从 todo 删除原块”，不再承诺无事务环境下的 done-first 两阶段恢复。

worker 或 steward 异常时采用人工恢复：确认 Git 状态、当前 Agent 状态和 material effects，
然后由 steward 递增 revision、换 claim token 并重新分配。不实现自动 lease、heartbeat 或选举。

## 七、机器检查边界

新增 `tests/task-ledger.sh`，并接入 CI 与 `AGENTS.md`。它只检查本地、确定性不变量：

1. 输入非空，todo/done 至少各有预期类型的任务。
2. Task ID 全局唯一，state 属于各账本允许集合。
3. 必填字段存在；accepted 的每个 AC 有同 ID evidence。
4. 依赖存在、无环；ready 的直接依赖均已 accepted。
5. `TASK-GATE-R0` 存在，R1 入口依赖它。
6. ready/claimed 的 write/artifact 是安全、具体、仓库相对路径。
7. GitHub Issue/PR 映射唯一；Milestone 明确允许多对一。
8. effect/undo ID 成对；done move token 唯一。

测试先使用当前 ledger 运行并因缺少 gate/undo 等预期原因变红，再修改生产文档使其变绿。
负例至少覆盖：空输入、重复 ID、缺字段、悬空依赖、依赖环、ready 依赖未 accepted、重复 Issue、
effect/undo 不配对和重复 move token。每个负例断言准确错误原因，不能只断言退出码。

不在 CI 中调用 GitHub API，不验证 Issue 是否实时 open/closed，不实现 Markdown 通用解析器。

## 八、GitHub 最小强制

默认分支 ruleset 启用以下规则：

- 禁止删除和 non-fast-forward。
- 必须通过 pull request 合入。
- 必须通过现有 `check (ubuntu-latest)` 与 `check (macos-latest)`。
- 所需人工 approval 数为 0，避免单维护者仓库自我阻塞。

Tag protection 不阻塞当前 PR。新增 `TASK-OPS-002` 和对应 Issue，在 R0 gate 前建立匹配
`r*-accepted` 的 Tag ruleset，禁止更新和删除，并记录 bypass authority。Tag 创建顺序为：
gate report 合入并 accepted → 创建并验证 annotated tag 指向该 commit → 关闭 gate Issue 与
Milestone。若中途失败，Milestone 保持 open。

本阶段不自动创建 Tag/Release，也不要求签名基础设施；一旦项目已有稳定签名身份，再单独升级。

## 九、迁移和验收顺序

1. 先增加会在当前 ledger 上失败的机器检查。
2. 调整 ledger schema、bootstrap records、R0 gate 和依赖，直到检查通过。
3. 修正研究问题、停止条件、第二垂直封存和评测 acceptance。
4. 接入 CI/AGENTS，运行现有六组测试和 shell 语法检查。
5. 启用最小 main ruleset；Tag ruleset 留给 `TASK-OPS-002`，但 R0 gate 显式依赖它。
6. 更新 GitHub Issue #2、#3、#8、#11、#13 的依赖与 acceptance，使其与 ledger 一致。
7. 独立 re-review；Critical/Important 清零后，PR #12 才可从 draft 转为 ready。

## 十、明确非目标

- 不实现通用 workflow engine、数据库或事件总线。
- 不为低概率 steward crash 构建选举和分布式锁。
- 不把 GitHub 临时网络故障升级为本地任务阻塞。
- 不在 R0 前建设自动发布或完整统计平台。
- 不因为一次审查引入第三垂直、更多 harness 或更多形式审批。
