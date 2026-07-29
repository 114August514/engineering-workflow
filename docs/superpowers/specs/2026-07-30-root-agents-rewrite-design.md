# 根 `AGENTS.md` 重写设计

- 日期：2026-07-30
- 文档类型：Explanation
- 目标读者：维护 `engineering-workflow` 的人类与 coding agent
- 状态：已批准

## 问题

当前根 `AGENTS.md` 混合了仓库宪法、历史事故说明、易漂移的文件数量和通用 agent 工作偏好。未提交 diff 又追加了一套英文 `Working Style`，但没有接入本仓已经建立的研究路线、任务账本与证据协议。

这会产生三个问题：

1. agent 无法从根指令判断普通维护任务与 roadmap Task 的不同控制方式；
2. 文件数量、测试清单和阶段状态会随仓库演进而失真；
3. 解释、案例和长期约束混在一起，稀释真正需要每次开工都看到的规则。

## 决定

把根 `AGENTS.md` 重写成“宪法式路由”，只保留会稳定改变 agent 行为的规则与权威指针。目标长度约 90–120 行；长度只是职责漂移的报警器，不是硬预算。

文档按以下结构组织：

1. **仓库身份与事实源**：本仓是软件工程 Domain；研究路线、当前任务和终态证据分别以研究说明、`todo.md`、`done.md` 为唯一事实源。
2. **开工与认领**：区分普通仓库维护和 roadmap Task。普通窄改按风险直接推进；roadmap Task 必须遵守 steward、claim、write scope 和依赖规则。
3. **执行边界**：规定 worker 不编辑账本、不扩张产品边界，Claim、Evidence、Verification 分离，并保留本仓特有的内容分层、薄壳 skill、文档重复与跨平台 shell 约束。
4. **验证**：以 `.github/workflows/ci.yml` 为验证入口，按 `ci-scope` 选择相关检查；修改 shell、workflow 或跨平台行为时，Ubuntu 与 macOS 检查均为 required。
5. **完成与汇报**：每条 acceptance criterion 必须有同 ID evidence；汇报范围、验证结果、不确定项、涉及文件和 `ci-scope`。

## 删除内容

以下内容不再放在根 `AGENTS.md`：

- references、脚本或 skill 的具体数量；
- 某次事故的完整经过和重复测试技巧；
- 可由源码、CI 或目录结构直接读取的事实；
- 与本仓控制协议无关的通用英文工作偏好；
- 当前 R0 任务状态或未来阶段承诺。

历史理由继续由 Git 历史和相关 reference 承载；研究状态只进入既有事实源，不在宪法中复制。

## 验收

1. `AGENTS.md` 能让新 agent 找到产品边界、当前任务和完成证据的唯一事实源。
2. 普通维护与 roadmap Task 的开工路径不同且明确。
3. ledger steward、worker write scope、依赖和 evidence 约束与研究说明一致。
4. 保留 BSD/macOS、薄壳 skill、文档重复、模板密钥等仓库特有约束。
5. 不再包含易漂移数量、事故叙事或新增的通用英文 `Working Style`。
6. 相关文档链接和 CI scope 一致性检查通过。

## 非目标

- 不修改研究路线、ADR、任务账本协议或 CI 行为。
- 不替 `skills/engineering-project/references/` 重写详细流程。
- 不把根 `AGENTS.md` 变成当前 roadmap 的任务列表。
- 不为这次纯文档重写新增产品测试。
