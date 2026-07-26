# 调研笔记：这套流程从哪来、为什么这么取舍

记录设计依据，避免三个月后有人（或某个 AI）"顺手优化"掉一个有理由的选择。

---

## 一、各方法论解决的问题，以及我们取了什么

| 方法 | 真正解决的问题 | 我们取了什么 | 我们没取什么 |
|---|---|---|---|
| **TDD**（Beck） | 微观内环、防回归 | 测试先行、先看红、最小实现（`slices.md`） | 没有把"红-绿-重构"做成强制仪式；不追求覆盖率数字 |
| **BDD / Specification by Example**（North、Adzic） | 需求说不清 | 每条验收标准配具体例子 | 没引入 Gherkin/Cucumber 那一层工具 |
| **EARS**（Mavin，Rolls-Royce） | 需求不可判定 | 五种句式（`intake.md`） | 没做形式化验证 |
| **DDD**（Evans、Vernon） | 概念混乱、边界糊 | **战略部分**：通用语言、限界上下文、不变量 | **战术部分全部不用**：实体/值对象/聚合根/仓储/领域事件——在小项目上成本大于收益 |
| **SDD**（Spec Kit、Kiro，2025—2026） | AI 代码漂移出意图 | spec 是一等公民、宪法文件（`AGENTS.md`）、契约先行 | 没做"spec 编译成代码"那套；不追求 spec 覆盖全部实现细节 |
| **Walking Skeleton / Tracer Bullet**（Freeman & Pryce；Hunt & Thomas） | 接缝和部署被推迟到最后才炸 | **P3 整个阶段**——最薄链路 + 必须真部署 | — |
| **ADR**（Nygard） | 决策理由丢失 | `docs/decisions/`，G2 闸 | 没上 ADR 工具链，就是 markdown 文件 |
| **C4**（Brown） | 架构图画不明白 | 只画容器图 | 不画类图、组件图——会过期，且 AI 能从代码重建 |
| **Hexagonal / Ports & Adapters**（Cockburn） | 业务规则被 IO 缠住 | 一条规则：依赖方向朝内，领域层不碰 IO | 不引入 port/adapter 那套命名和目录仪式 |
| **12-Factor** | 配置与部署 | 配置外置、启动时校验、环境等价 | 不强求全部十二条 |
| **Trunk-based / CD** | 大 diff、集成地狱 | 短命分支、小 PR、**PR 尺寸上限** | 不要求一天多次发布 |

---

## 二、决定性的一组数据

2026 年多份统计给出同一个结论：**瓶颈从"写"移到了"审"**。

- 高 AI 采用团队：完成任务 **+21%**、合并 PR **+98%**
- 但同期：PR 评审时间 **+91%**、PR 平均体积 **+154%**、缺陷数 **+9%**
- 约 **30%** 的开发者明确表示不信任 AI 生成的代码
- DORA 的说法：AI 放大团队既有的强项和弱项；交付不稳定性上升，
  因为"更多代码以更快速度涌向既有的评审闸门和发布管道"

**这直接决定了三个设计选择：**

1. **闸门放在小产物上**（意图、ADR、契约、迁移），不放在实现代码上。
   一份 200 行的 OpenAPI 决定了几千行实现——审它的性价比高一个数量级。
2. **PR 有硬性尺寸上限**。超过某个体积，评审会从"逐行看"退化成
   "扫一眼点同意"，此时闸门形同虚设，还不如没有。
3. **免审项必须交给机器**。格式、lint、类型、覆盖率、漏洞扫描出现在人的评审
   视野里，本身就是流程出了问题。

---

## 三、SDD 现状与它的已知短板

2025 年 7 月 GitHub 发布 Spec Kit 之后，SDD 工具在半年内爆发。到 2026 年，
Spec Kit、AWS Kiro、Claude Code、Cursor、OpenSpec、BMAD、Tessl、
Google Antigravity 都出了各自的版本。

两条主线：

- **Spec Kit**：CLI（`specify`）+ slash 命令，流程是
  Constitution → Specify → Plan → Tasks → Implement。
  `constitution.md` 放不可变的高层原则，作用于每一次改动。
  支持 30+ 种 agent。给自由度，不给引导。
- **Kiro**（AWS）：VS Code 派生的 IDE，一个提示生成三份产物——
  `requirements.md`（EARS 句式）、`design.md`、`tasks.md`（按依赖排序）。
  给引导，不给自由度。

**公认短板**（我们的应对）：

| 短板 | 我们怎么处理 |
|---|---|
| spec 与代码悄悄漂移 | REQ-ID ↔ 测试名双向追溯，`audit.sh` 机械检查孤儿需求/孤儿测试 |
| 不知道 spec 本身对不对 | EARS 句式 + 强制具体例子 + G1 闸；非目标必须写满 |
| 验证开销大到人想跳过 | 分流（T0/T1/T2），只有结构性改动走全流程 |
| brownfield 难 retrofit | `doctor.sh` 做增量体检；标准动词可以逐个补上，不需要一次到位 |
| 文档产物过多 | 合并成四份：`spec.md` / `glossary.md` / `decisions/` / `runbook.md` |

---

## 四、为什么不直接用 superpowers

superpowers（brainstorming → writing-plans → executing-plans / subagent-driven-development
→ TDD → code-review → finishing-a-branch）覆盖的是**单个 feature 的内环**，
而且假定项目已经存在——没有涉及仓库怎么起、技术栈怎么定、CI 怎么搭、
后端怎么分层、怎么部署。

我们补的正是它前面的 0→1 和它外面的工程骨架。同时刻意做轻：

| superpowers 的做法 | 这里的做法 | 为什么 |
|---|---|---|
| 每次改动都走完整流程 | **按风险分流三档** | 仪式感压过收益时，人会开始跳步，流程就崩了 |
| spec / plan / tasks 三份文档 | spec + glossary + ADR，随项目演进 | 写代码前先写三份会过期的文档，成本大于收益 |
| plan 里要写出完整代码 | plan 只写文件清单 + 验收标准 + 验证命令 | 代码写两遍，第一遍必然作废 |
| 强调必须用 subagent | 不做要求 | 不该假定运行环境 |
| 每个 skill 配 graphviz 流程图 + 恐吓式措辞 | 表格 + 硬规则清单 | 篇幅换不来行为差异 |

---

## 五、来源

- [Spec-Driven Development (SDD): The Definitive 2026 Guide — BCMS](https://thebcms.com/blog/spec-driven-development)
- [Meet GitHub Spec-Kit — MarkTechPost](https://www.marktechpost.com/2026/05/08/meet-github-spec-kit-an-open-source-toolkit-for-spec-driven-development-with-ai-coding-agents/)
- [Understanding Spec-Driven Development: Kiro, spec-kit, and Tessl — Martin Fowler](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)
- [Kiro Specs 最佳实践 — kiro.dev](https://kiro.dev/docs/specs/best-practices/)
- [Spec Kit vs BMAD vs OpenSpec — DEV](https://dev.to/willtorber/spec-kit-vs-bmad-vs-openspec-choosing-an-sdd-framework-in-2026-d3j)
- [Beyond Autocomplete: Best Agentic Coding Workflow in 2026 — Kilo](https://kilo.ai/articles/beyond-autocomplete)
- [AI Code Review Bottleneck — Larridin](https://larridin.com/blog/ai-code-review-bottleneck)
- [New DORA Report: Strong Engineering Foundations Drive AI ROI — InfoQ](https://www.infoq.com/news/2026/05/dora-roi-ai-assisted-dev-report/)
- [DORA 2025: AI Amplifies Your Strengths (and Your Weaknesses) — LCMH](https://lcmh.fr/en/articles/2026/dora-2025-ai-amplifier-software-development/)
- [The Productivity-Reliability Paradox: Specification-Driven Governance for AI-Augmented Software Development — arXiv](https://arxiv.org/pdf/2605.01160)
