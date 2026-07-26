# 工程规范

**这套规范与技术栈无关。** 语言的差异只体现在 `stack.mk` 一个文件里，
其余全部通用——这是整套模板的设计前提。

---

## 一、标准动词

每个项目都提供同一组 `make` 目标。完整定义：

| 动词 | 含义 | 契约 |
|---|---|---|
| `make setup` | 全新机器到可开发 | **幂等**，重复跑不出错；不需要预先手动装东西（除了语言运行时） |
| `make dev` | 本地起起来 | 前台运行，带热重载，Ctrl-C 能干净退出 |
| `make fmt` | 格式化 | **会改文件** |
| `make fmt-check` | 检查格式 | **只读**，不合格非零退出 |
| `make lint` | 静态检查 | 只读，不通过非零退出 |
| `make typecheck` | 类型检查 | 无类型系统的语言留空实现，但目标必须存在 |
| `make test` | 全部测试 | 不通过非零退出 |
| `make check` | fmt-check + lint + typecheck + test | **提交前唯一要记的命令** |
| `make build` | 产出可部署产物 | — |
| `make ship` | 部署 | 幂等；失败不留半个状态 |
| `make audit` | 生成待人审清单（**增量**：这次改动） | 每个 PR 跑，见 `audit.md` |
| `make review` | 里程碑复盘（**全量**：整个仓库） | 阶段结束时跑，见 `review.md` |
| `make journal` | 在途工作、孤儿锁、悬空副作用 | 开工前和接手时跑，见 `journal.md` |
| `make doctor` | 工程基线体检 | 缺项要给出修复建议 |

可以加项目特有的（`make seed`、`make migrate`、`make migrate-down`），
但上面这些**必须全部存在**，哪怕是空实现。

### 为什么值得约束成这样

1. **人跨项目零成本**——不用每个仓库读一遍 README 才知道怎么跑测试
2. **AI 跨项目零成本**——`AGENTS.md` 里永远写 `make check`，换栈不用改文档
3. **CI 和本地跑同一条命令**——不会出现"本地过了 CI 挂了"这种由命令不一致
   导致的问题
4. **换技术栈只改一个文件**——`stack.mk`

---

## 二、目录约定

```
├── AGENTS.md              # 项目宪法（≤150 行）
├── README.md              # 这是什么 + setup + dev + check
├── Makefile               # 标准动词（不改）
├── stack.mk               # 唯一与语言耦合的文件
├── .env.example           # 全部键名，无真实值
├── contracts/             # 🔴 必审区：API schema、错误码、共享类型
├── migrations/            # 🔴 必审区：数据库迁移
├── docs/
│   ├── spec.md            # 意图、非目标、验收标准（REQ-ID）
│   ├── glossary.md        # 术语、限界上下文、不变量、状态机
│   ├── decisions/         # ADR，NNNN-短标题.md
│   ├── runbook.md         # 部署、回滚、排障、备份
│   └── journal/           # 作业日志：一条工作一个文件（= 任务卡 + 状态 + 回退）
├── src/
│   └── <上下文名>/
│       ├── domain/        # 纯业务规则，不 import IO
│       ├── app/           # 用例编排、事务边界
│       └── infra/         # 数据库、外部调用
└── tests/
```

**按限界上下文分，不按技术层分**：`src/order/domain/`，
不是 `src/domain/order/`。一起变化的东西放在一起，一个任务只读一个目录。

---

## 三、命名

- **概念名以 `docs/glossary.md` 为唯一事实源。** 代码标识符、数据库列、
  接口字段、日志字段、文档，全用同一个词。翻译只发生在给终端用户看的界面文案。
- 需要新概念时，**先往术语表加一行再写代码**。
- 各语言的大小写风格随语言习惯（`snake_case` / `camelCase`），
  但**词本身**不能变。

### ID 规范

| 类型 | 格式 | 用在哪 |
|---|---|---|
| 需求 | `REQ-<模块>-<三位>` | `spec.md`；**测试名里必须出现** |
| 不变量 | `INV-<三位>` | `glossary.md`；数据库约束注释里引用 |
| 决策 | `<四位>-<短标题>.md` | `docs/decisions/` |
| 错误码 | `SCREAMING_SNAKE` | `contracts/errors.md` |

---

## 四、Git

### 分支

主干开发：从 `main` 切短命分支，做完一条切片就合回去，**分支不要活过两天**。
长命分支 = 大 diff = 人审不动 = 闸门失效。

### 提交信息

```
<类型>: <做了什么>

<为什么这么做，如果不明显的话>

REQ-ORD-003
```

类型：`feat` / `fix` / `refactor` / `test` / `docs` / `chore` / `contract` / `migrate`。

后两个是我们加的，因为 `audit.sh` 和人都需要一眼看出必审提交。

规则：

- **契约变更和迁移单独提交**，用 `contract:` / `migrate:` 前缀
- 一个提交一件事。"顺手改了格式"要单独提交
- 不写"更新代码"、"修复 bug"这类无信息量的信息

### 提交前

`make check` 通过。pre-commit 钩子跑 `make fmt` + `make lint`
（**不跑全量测试**——太慢的钩子一定会被 `--no-verify` 绕过）。

---

## 五、文档规则

- **每份文档有唯一职责**，不重复——**重复的两份一定会有一份过期**。
  唯一的例外：**重复能被机器检查住**。真的需要在两处写同一份表格时，
  配一个 CI 检查去比对它们；没有这个检查就不许重复。
  （本 skill 自己的动词表就是这种情况：`Makefile`、`conventions.md`、
  `skeleton.md` 三处各有一份，靠一个一致性测试兜住。）
- 会过期的实现细节不进文档，让代码说
- 决策进 `docs/decisions/`，不留在对话或提交信息里
- README 保持四段：这是什么、`make setup`、`make dev`、`make check`

---

## 六、这套规范怎么落到具体语言

`new-project.sh` 从 `templates/adapters/` 选一个 `.mk` 拷成 `stack.mk`。
adapter 只定义命令变量，不定义流程：

```makefile
# templates/adapters/python-uv.mk
SETUP     := uv sync
DEV       := uv run python -m app
FMT       := uv run ruff format .
FMT_CHECK := uv run ruff format --check .
LINT      := uv run ruff check .
TYPECHECK := uv run mypy src
TEST      := uv run pytest
BUILD     := uv build
```

写一个新语言的 adapter = 填这八个变量。`Makefile`、CI、`AGENTS.md`、
所有文档一个字都不用改。

**加新 adapter 的检查**：`make setup && make check` 在一台干净机器上能跑通。
