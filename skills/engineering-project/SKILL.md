---
name: engineering-project
description: 从 0 搭建并持续交付一个工程化软件项目的完整工作流——需求澄清、领域建模、架构决策、可部署骨架、契约先行、垂直切片实现、代码评审、缺陷修复、里程碑复盘、上线与回滚，以及人该在哪些点上审计 AI 的产出。语言与技术栈无关：约定的是标准动词接口和目录规范，具体命令由 adapter 填。Use this whenever the user is starting a new project, scaffolding a repo, setting up engineering baselines (CI/lint/tests/hooks/deploy), designing an API or database schema, deciding a tech stack, planning how to build a feature, reviewing code or a PR, fixing a bug, doing a milestone retrospective, coordinating multiple agents or teammates on one repo, or picking up work left half-done by a previous session — including bare requests like "帮我起个新项目"、"这个需求怎么拆"、"技术栈选什么"、"怎么部署"、"CI 怎么配"、"这个 PR 我该看什么"、"帮我 review 一下"、"这个 bug 怎么修"、"复盘一下这个阶段"、"上次做到哪了"、"多个 agent 怎么并行"、"帮我写个后端"、"前后端怎么对接". Also use it when the user describes an idea in vague terms and expects working software at the end, or when receiving/responding to code review feedback.
---

# 工程项目工作流

这套流程解决的不是"让 AI 写更多代码"，而是**让人审得动 AI 写的代码**。

2026 年的数据：高 AI 采用团队合并 PR 数 +98%、PR 体积 +154%，但评审时间 +91%、
缺陷 +9%。瓶颈已经从"写"移到"审"。所以下面每一个阶段的设计目标都是——
**把审计前移到又小又致命的产物上**（意图、决策、契约、迁移），
而不是后置到一大堆实现代码上。

---

## 第一步：分流

**不要所有事情都走完整流程。** 先判断这次改动属于哪一档：

| 档 | 什么情况 | 走什么 | 闸门 |
|---|---|---|---|
| **T0 微改** | 文案、常量、注释、格式 | 直接改 → `make check` → 提交 | 无 |
| **TF 缺陷修复** | 修 bug，**哪怕只改一个字符** | `references/bugfix.md`：复现 → 回归测试 → 根因 → 修 → 找同类 → 回填 | 缺陷评审 |
| **T1 功能** | 在既有骨架内加一条用户可见路径，不动契约 | 任务卡 → 测试先行 → 实现 → `make check` → 人审 | 切片闸 |
| **T2 结构** | 新项目、新限界上下文、动 schema/API 契约、换选型、动权限模型 | 走完整七阶段 | 全部 |

判断不了就问一句。**误判成 T0 的代价远大于多走一档**——凡是碰
`contracts/`、`migrations/`、认证授权、依赖清单的，一律 T2。

**最常见的误判是把 bug 修复当成 T0。** 一行的修改看起来像微改，
但 `make check` 通过只说明现有测试没被破坏——既然它是 bug，
就说明现有测试根本没覆盖它。没有新增回归测试的修复必然复发。

新项目一定是 T2，从 P0 开始。

---

## 七个阶段

每个阶段只做三件事：产出一份东西、过一个闸门、然后才允许进下一阶段。

| 阶段 | 产物 | 详细步骤 |
|---|---|---|
| **P0 意图** | `docs/spec.md`：问题 / 非目标 / 验收标准（带 REQ-ID） | `references/intake.md` |
| **P1 领域** | `docs/glossary.md`：术语 / 边界 / 不变量 / 状态机 | `references/domain.md` |
| **P2 决策** | `docs/decisions/NNNN-*.md`：ADR + 容器图 + 风险排序 | `references/architecture.md` |
| **P3 骨架** | 一条端到端跑通**且已部署**的最薄链路 + 工程基线 | `references/skeleton.md` |
| **P4 契约** | `contracts/`：API schema / 迁移 / 错误码 / 共享类型 | `references/contract.md` |
| **P5 切片** | 一次一条垂直切片，测试先行 | `references/slices.md` |
| **P6 交付** | 发布、回滚、监控、备份、依赖 | `references/delivery.md` |

**贯穿全程的七份**：

- `references/audit.md` —— **审什么**。分级清单 + AI 失败模式。每个闸门都读它。
- `references/review.md` —— **怎么审**。评审协议：请求格式、反馈三级、
  收到反馈怎么处理、闭环，以及**里程碑复盘**。
- `references/proportion.md` —— **做多少**。不过度设计，也不为不会发生的故障
  建防御。**写代码前和评审时都读它。**
- `references/reuse.md` —— **别重复造轮子**。动手前的四层检索、哪些不许手搓、
  怎么借鉴结构，以及**抄进来之后必须做的适配**。**同样是写代码前读。**
- `references/journal.md` —— **在途、回退、并发**。借 OS 的预写日志/undo log/锁：
  会话死在半路怎么接、`git revert` 撤不掉的仓外副作用怎么记、多 agent 怎么不打架。
- `references/bugfix.md` —— 缺陷修复流程（TF 档专用）。
- `references/handoff.md` —— 人机对接：`AGENTS.md` 怎么写、任务卡格式、上下文怎么管。

工程规范本身（标准动词、目录约定、命名、提交）在 `references/conventions.md`。

**技术专题**（写到具体代码时读，与框架无关，讲的是结构和决策）：

- `references/backend.md` —— 分层与依赖方向、事务与并发、数据库、错误处理、可观测性
- `references/frontend.md` —— 契约消费、三态、状态放哪、组件边界、**AI 看不见界面怎么验收**

---

## 六个闸门

闸门是**人必须点头**的地方。到了闸门就停下来，把产物摆出来，等人回话。
不要自己替人过闸。

```
P0 ──G1 意图闸────► P1 ──┐
                          ├──► P2 ──G2 决策闸──► P3 ──G3 骨架闸──► P4
                          │
                    (G1 一并审 P1 的术语表)
                                      P4 ──G4 契约闸──► P5 ──G5 切片闸──► P6 ──G6 上线闸
```

| 闸门 | 人审什么 | 为什么是这里 |
|---|---|---|
| **G1 意图** | 非目标、验收标准、术语表 | 最便宜、杠杆最高。这里错了，后面全白做 |
| **G2 决策** | ADR | 决策不可逆，代码可逆。审计资源该花在不可逆的东西上 |
| **G3 骨架** | 亲手跑一次 `make dev`，点开部署出来的 URL | 骨架是后面所有代码的地基，且此时它还很小 |
| **G4 契约** | schema diff、迁移、错误码 | 又小又致命。审完前后端才能并行 |
| **G5 切片** | 按 `audit.md` 的分级清单审 PR | 唯一高频闸门，所以 PR 必须小 |
| **G6 上线** | "炸了怎么回滚" | 回滚没演练过就等于没有 |

外加两个不在这条线上的评审（见 `references/review.md`）：

- **缺陷评审**——每次修 bug 之后。10 分钟，第一条就是"有没有先红后绿的回归测试"，
  没有就不用往下看了。
- **里程碑复盘**——周期性，不是线性闸门。一组切片完成 / 阶段结束 / 两周一次，
  取早的那个。先跑 `make review`（机器能查的它都查了），人再看八条：
  spec 还成立吗、术语漂移了吗、架构侵蚀了吗、测试还可信吗、技术债登记了吗、
  依赖膨胀了吗、文档过期了吗、下阶段最大的风险是什么。

  **每个 PR 都过了，不代表整体还立得住。** 侵蚀在每个 PR 里都合规，
  只有拉远了看才看得见。

---

## 硬规则

这几条不要绕过，绕过就失去了整套流程的意义：

1. **P3 之前不写业务功能。** 骨架没通、没部署、CI 没绿之前写的功能，
   都是在往一个还不存在的地基上垒砖。
2. **契约变更单独提交。** 不要和实现混在一个 diff 里，那样人就审不动了。
3. **测试先看它红。** 没见过失败的测试不算测试——它可能什么都没断言。
4. **PR 有尺寸上限**（默认 400 行 diff）。超了就拆，理由见开头那组数据。
5. **验收标准要能被机器判定。** "用户友好""高性能"不是验收标准。
6. **决策写进 `docs/decisions/`，不要只留在对话里。** 会话会结束，仓库不会。
7. **按可逆性决定投入。** 不可逆的（数据、钱、契约、权限）——防；
   可逆的、能重试的——让它失败，但保证失败可见。
   为纯推理出来的风险写代码之前，先把它写进风险表。见 `references/proportion.md`。
8. **动手前先搜。** 写任何一段有名字的功能之前，先 grep 这个仓库——
   AI 最常见的重复造轮子不是引错了库，是在已经有一个实现的情况下又写一个。
   然后才是标准库、已装的依赖、新依赖。**安全、时间与时区、协议解析、
   金额精度、重试退避一律用成熟实现，不许手搓。** 见 `references/reuse.md`。
9. **抄进来的东西必须适配。** 换成术语表里的命名、删掉用不到的部分、
   接上本项目的错误模型和日志格式。不适配的复用比自己写更糟。
10. **动手前先写意图，收工前更新状态。** 会话会死（压缩、打断、超时），
    写完意图那一刻是可恢复的，反过来什么都不剩。**产生仓外副作用之前，
    先写下怎么撤销它**——写不出撤销方式就是需要人点头的信号。见 `references/journal.md`。
11. **这套流程本身也受第 7 条管。** 清单是 checklist 不是待办；
   没有信号就不要逐条去找问题。某个环节持续没发现过真问题就删掉它。

---

## 起手式

新项目：

```bash
~/.claude/skills/engineering-project/scripts/new-project.sh <目标目录> --adapter <语言>
```

`--list` 看有哪些 adapter。骨架语言无关，adapter 只填 `stack.mk` 里那八个命令变量。
生成的项目**自带 `scripts/`**，`make audit|review|journal|doctor` 不依赖这台机器
装没装这个 skill。

已有项目：

```bash
make doctor    # 工程基线缺什么（没有 Makefile 就直接跑 skill 里的 doctor.sh）
make journal   # 有没有在途工作、孤儿锁、悬空的仓外副作用
make audit     # 这次改动的待人审清单
make review    # 阶段结束时的全仓库复盘
```
