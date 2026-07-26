---
name: repo-init
description: 起一个新仓库或给已有仓库补工程基线：标准动词接口（make setup/dev/check/ship，语言差异只在 stack.mk 八个变量里）、目录约定、CI、pre-commit、.gitignore 与 .gitattributes、.env.example 与密钥边界、健康检查、issue/PR 模板、分支与提交规范。也覆盖存量项目怎么不推倒重来地接入。Use when starting a repo, scaffolding a project, setting up CI/lint/format/tests/hooks, fixing engineering baseline gaps, or onboarding an existing codebase — including "帮我起个新项目"、"CI 怎么配"、"这个仓库缺什么"、"pre-commit 怎么加"、"gitignore 怎么写"、"分支怎么命名"、"已有项目怎么接入规范".
---

**新项目**直接用脚手架（骨架语言无关，adapter 只填 `stack.mk` 里八个命令变量）：

```bash
~/.claude/skills/engineering-project/scripts/new-project.sh <目录> --adapter <语言>   # --list 看有哪些
```

**已有项目**先体检，再按五步接入，**不要为了接入做大重构**：

```bash
~/.claude/skills/engineering-project/scripts/doctor.sh
```

然后读：

0. `~/.claude/skills/engineering-project/references/always.md` —— 三条横切规则
1. `~/.claude/skills/engineering-project/references/skeleton.md` —— 标准动词、工程基线清单、walking skeleton（骨架必须**真部署**）
2. `~/.claude/skills/engineering-project/references/conventions.md` —— 目录、命名、Git 分支与提交、什么该进仓库/LFS/对象存储
3. `~/.claude/skills/engineering-project/references/brownfield.md` —— 存量项目才读：五步接入顺序和常见翻车

一条容易被跳过的：**P3 骨架必须真的部署上线过**再写业务功能。
部署是最容易被无限推迟、也最容易在最后一刻炸的一环。

要走完整流程（需求澄清 → 领域建模 → 架构决策 → 骨架 → 契约 → 切片 → 交付）时，
用 `engineering-project` skill。
