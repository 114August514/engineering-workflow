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
├── .gitattributes         # LF 换行、二进制标记、生成文件折叠、LFS 规则
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

命名：`<类型>/<issue 号>-<短描述>`

```
feat/123-create-workspace     fix/207-run-status-sync
refactor/231-slurm-adapter    docs/256-git-workflow
```

带上 issue 号，`git log` 和分支列表里就能直接回溯到需求。

**禁止**：`zxb_branch`、`backend-new`、`final`、`临时分支`，
以及**每个人一个长期个人分支**——那个必然和 `main` 严重分叉。

### 合并策略

**Squash merge**，并在平台上开启"合并后自动删除远程分支"。

这样开发分支里可以自由出现"补测试""修 lint""处理 review"这类中间提交，
而 `main` 上每条切片只留一个提交——`git log --oneline` 就是一份可读的变更史，
`git bisect` 也好用。

合并后本地要自己清：`git checkout main && git pull --ff-only && git branch -D <分支> && git fetch --prune`

### 提交信息

```
<类型>(<范围>): <做了什么>

<为什么这么做，如果不明显的话>

REQ-ORD-003
```

类型：`feat` / `fix` / `refactor` / `test` / `docs` / `chore` / `contract` / `migrate`。

范围可选，用**限界上下文名**（`order` / `payment` / `auth` / `ci`）——
和目录结构对齐，别另发明一套词。

```
feat(order): 库存不足时拒绝下单
fix(payment): 取消作业后状态未更新
contract(order): 新增 409 OUT_OF_STOCK
```

后两个是我们加的，因为 `audit.sh` 和人都需要一眼看出必审提交。

规则：

- **契约变更和迁移单独提交**，用 `contract:` / `migrate:` 前缀
- 一个提交一件事。"顺手改了格式"要单独提交
- 不写"更新代码"、"修复 bug"这类无信息量的信息

### 撤销与密钥泄露

| 情况 | 做法 |
|---|---|
| 最近一次提交还没推 | `git commit --amend` |
| 已经推到共享分支 | **`git revert`**，不要 `reset --hard` + `push --force` |
| 确实要覆盖远程历史 | `git push --force-with-lease`（会检测别人是否推过新提交） |
| **不小心提交了密钥** | **第一步永远是轮换密钥**，不是研究怎么改历史 |

密钥泄露的正确顺序：**轮换 → 通知维护者 → 清理历史 → 检查 CI 日志/缓存/
Release 里是否还有残留**。删掉文件重新提交不够——密钥还在历史里，
而且此刻可能已经被爬走了。

### 提交前

`make check` 通过。pre-commit 钩子跑 `make fmt` + `make lint`
（**不跑全量测试**——太慢的钩子一定会被 `--no-verify` 绕过）。

---

## 四点五、什么该进仓库

| 类型 | 放哪 |
|---|---|
| 源码、配置模板、文档、小型测试数据 | 普通 Git |
| **锁文件**（`uv.lock` / `pnpm-lock.yaml` / `Cargo.lock`）、迁移文件、`.env.example`、Dockerfile、CI 配置、`.gitattributes` | **必须提交** |
| 必须随版本走的大型二进制（演示视频、设计源文件） | Git LFS，**且限定目录** |
| 数据集、模型权重、checkpoint、运行输出、日志 | 对象存储 / 算力平台存储，**不进 Git 也不进 LFS** |
| 构建产物、缓存、依赖目录、虚拟环境 | 不保存，写进 `.gitignore` |
| 密钥、token、密码 | 环境变量或密钥管理，**永不进仓库** |

两条容易踩的：

1. **同一种包管理器只保留一个锁文件。** 同时存在
   `package-lock.json` + `yarn.lock` + `pnpm-lock.yaml` 会让 CI 装出不同的依赖树
2. **不要按扩展名全局启用 LFS**（`git lfs track "*.pt"`）——
   那会把所有训练产物拖进版本控制。**限定目录**：`git lfs track "docs/demo/*.mp4"`。
   LFS 仍属于版本控制，一样有存储和流量限制，不是通用大文件网盘

`.gitattributes` 也要提交，它管**已被 Git 跟踪的文件怎么处理**
（`.gitignore` 管的是哪些文件不进来）。至少统一换行符为 LF——
否则 Windows/WSL 下拉出来的 shell 脚本在 Linux 上会因为 CRLF 直接执行失败。

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
