# Root AGENTS Rewrite Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rewrite the root `AGENTS.md` as a stable repository constitution and R0 research-control router.

**Architecture:** Replace the current mixed manual with one short routing document. Stable rules remain inline; changing state and detailed procedures are referenced through their existing single sources of truth.

**Tech Stack:** Markdown, Bash validation scripts, GitHub Actions workflow

---

### Task 1: Replace the repository constitution

**Files:**
- Modify: `AGENTS.md:1-175`
- Verify: `docs/research/agent-collaboration-foundation.md`
- Verify: `todo.md`
- Verify: `done.md`
- Verify: `.github/workflows/ci.yml`

- [ ] **Step 1: Replace `AGENTS.md` with the approved constitution**

Use this complete content:

```markdown
# engineering-workflow

一套让人审得动 AI 产出的软件工程 Domain skill，也在研究路线需要时承担临时研究控制面。

> **这是本仓库的宪法。** 这里只放每次开工都必须知道的约束和权威指针；
> 解释、例子与步骤属于对应的 reference。不要把当前任务状态或可从仓库读取的数量复制进来。

## 权威事实源

- 产品边界、研究问题、阶段门槛与证据方法：
  [`docs/research/agent-collaboration-foundation.md`](docs/research/agent-collaboration-foundation.md)
- 当前可执行、已认领和阻塞的 roadmap Task：[`todo.md`](todo.md)
- 终态任务与完成证据：[`done.md`](done.md)
- 已批准且仍生效的架构决定：[`docs/decisions/`](docs/decisions/)
- skill 分流与详细工程流程：
  [`skills/engineering-project/SKILL.md`](skills/engineering-project/SKILL.md) 及其 `references/`
- 仓库验证入口：[`.github/workflows/ci.yml`](.github/workflows/ci.yml)

源码、README、Issue、PR、Milestone 或对话与上述事实源冲突时，不自行调和；指出冲突，
按事实源和较新的 superseding decision 推进。GitHub 是公开协作视图，不覆盖账本状态。

## 开工

先判断工作属于哪一类：

- **用户直接提出的窄维护任务**：按 `SKILL.md` 的风险分流直接推进，不要为了微改制造 roadmap Task。
- **roadmap Task**：只能从 `todo.md` 中选择 `ready` 项，并先由本轮唯一的 ledger steward 完成 claim。
- **产品边界、研究路线、依赖、架构或公共契约变化**：不得伪装成普通维护；先形成供人审阅的决定。

接手在途工作时，先核对 working tree、近期提交、`todo.md` 与 `done.md`。状态对不上时先恢复事实，
不要在未知 write scope 上继续写。

## Roadmap 控制协议

- 每个协调周期只有一个 ledger steward。只有 steward 能修改 `todo.md` 和 `done.md`；worker 不直接编辑账本。
- claim 使用 task ID、expected revision 和 claim token。handoff 或释放后旧 token 失效。
- worker 只能写 claim 中列出的仓库相对路径或目录前缀。write scope 是排他锁，不是参考范围；
  不允许绝对路径、glob 或 `..`。
- 只有在 `done.md` 中处于 `accepted` 的依赖才能解锁任务；`cancelled`、`rolled-back` 和 GitHub close
  都不能满足依赖。
- 不自行扩张 Task、RQ 或产品边界，不把实现存在、README 自述或单次运行提升为效果证据。
- 每条 acceptance criterion 必须有同 ID evidence。Claim、Evidence、Verification 分开记录。
- 完成迁移必须先确保 `done.md` 有完整终态记录，再从 `todo.md` 删除；禁止先删后写。
- handoff 先记录绿色 checkpoint、下一步和未决风险，再释放 owner/claim。
- 仓外写操作执行前记录 effect 和对应 undo；不可逆动作必须有人工批准引用。

具体字段和恢复语义以研究说明的“多 Agent 研究协作协议”和
[`docs/research/task-ledger-contract.md`](docs/research/task-ledger-contract.md) 为准。

## 内容边界

- 主 `SKILL.md` 只放分流、路由表和硬规则；解释、案例、理由放 `references/`。
- `frontend-code`、`backend-code`、`api-contract`、`repo-init` 是精准触发的薄壳，
  只转发到主 skill 的 reference 与 `always.md`，不得复制规范内容。
- `templates/project-skeleton/AGENTS.md` 只放生成项目的约束和指针；展开做法放模板内
  `docs/conventions.md`。
- 文档重复必须有机器检查兜底。没有一致性检查时，新增唯一事实源并让其他位置引用它。
- 不在宪法里维护 references、脚本、skill、检查项或当前阶段的数量；这些必须从仓库读取。

## Shell 与模板

脚本必须同时兼容 Ubuntu 和 macOS runner，包括 macOS 自带的 Bash 3.2 与 BSD 工具链。

- 正则用 `[[:space:]]`，不用 `\s`。
- `stat`、`date` 等平台命令必须显式处理 GNU/BSD 差异；兜底失败时要报错或明说跳过。
- 不用 `sed -i`、`readlink -f`、`xargs -r` 等 GNU-only 接口。
- 变量后紧跟非 ASCII 字符时写 `${VAR}`，避免 Bash 3.2 错认变量名。
- 临时文件必须可清理；不得把真实密钥、邮箱、个人路径或机器专用配置写入仓库和模板。

## 测试与验证

先确定改动的 acceptance，再选择能推翻它的最小验证。验证项以 CI workflow 为准，
不要在这里复制一份会漂移的命令清单。

- 新增测试必须先证明测试输入非空，并通过故意破坏实现确认它会以预期原因失败。
- 测试断言可观察行为和失败原因，不能只断言退出码，也不能让空输入与空输入比较后报绿。
- 测试脚本启用 `pipefail` 时，预期非零的被测命令先捕获输出和状态，不用裸管道掩盖行为。
- 外部工具缺失与被测内容非法必须给出不同错误，避免把环境问题误报成产品缺陷。
- 查看测试结果必须保留完整失败上下文，不截取可能误导的最后一行。

每个 PR 和 Gate receipt 使用：

```text
ci-scope: required=<checks|none>; advisory=<checks|none>; n/a=<checks|none>; reason=<why>
```

- `required`：失败能推翻当前 acceptance；只在 merge、gate、tag 等终态动作前等待相关 checks。
- `advisory`：有信息价值，不阻塞独立工作。
- `n/a`：与当前变更无因果关系。

pending CI 不改变 task state。修改 shell、workflow 或跨平台行为时，Ubuntu 与 macOS 对应检查均为
required；纯研究或文档改动不得因无关 runner pending 停止。

验证只能支持它实际覆盖的 claim。Domain CI 证明本仓产品行为，不证明研究效果、跨 harness 可移植性
或 Mother 机制价值。

## 完成与提交

完成时报告：做了什么、没做什么、验证命令与结果、仍不确定什么、故意未处理什么、涉及文件，
以及本次 `ci-scope`。没有直接观察到的结论必须标为推断；不要用“应该没问题”代替证据。

提交格式：`<类型>: <做了什么>`，类型使用 `feat` / `fix` / `docs` / `test` / `chore`。
roadmap Task 的提交描述带 Task ID。提交前检查公开仓库中没有个人路径、邮箱、密钥或私有来源。
```

- [ ] **Step 2: Run the relevant documentation validations**

Run:

```bash
bash tests/docs-links.sh
bash tests/ci-scope-consistent.sh
```

Expected: both commands exit `0` and print their success summaries. Do not pipe output through `tail`.

- [ ] **Step 3: Check the rewritten document against the design acceptance**

Confirm all six conditions:

1. The research specification, `todo.md`, and `done.md` are named as separate sources of truth.
2. Direct maintenance and roadmap Task startup paths are distinct.
3. Steward, claim, write scope, dependency, handoff, and evidence rules match the research protocol.
4. BSD/macOS, thin satellite, documentation duplication, and template-secret constraints remain.
5. File counts, incident narratives, and the English `Working Style` are absent.
6. The two relevant validation commands passed.

- [ ] **Step 4: Inspect the final diff**

Run:

```bash
git diff -- AGENTS.md
```

Expected: one complete replacement of the old mixed manual with the approved constitution; no change to research sources, ledgers, CI, tests, templates, or skill behavior.

- [ ] **Step 5: Commit only when explicitly requested**

The design record was committed separately. Leave the `AGENTS.md` rewrite uncommitted unless the user asks for a commit, so the user retains control of the original working-tree change.
