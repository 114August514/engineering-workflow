# P3 骨架与工程基线

**目标**：一条端到端跑通**并且已经部署到真实环境**的最薄链路，加上完整工程基线。
**产物**：能跑的仓库 + 绿色 CI + 一个能访问的部署地址
**闸门**：G3——人亲手跑一次 `make dev`，点开线上 URL

**这是整套流程里最重要的一步，也是最容易被跳过的一步。**

---

## 一、Walking Skeleton

Walking Skeleton（Freeman & Pryce）/ Tracer Bullet（Pragmatic Programmer）：
先打通一条最薄但**完整**的链路，再往上长肉。

薄到什么程度：

> HTTP 请求 → 参数校验 → 调一个领域函数 → 读写一次数据库 → 返回响应
> 并且这条链路**有测试、在 CI 里跑、已经部署到线上能用浏览器访问**。

业务上可以极其无聊——比如"创建一条记录并列出来"。重点不在功能，在于
**所有接缝都通了一遍**。

### 挑哪条链路

不是最容易的那条，是 `architecture.md` 风险表里排第一的那条。
如果最大风险是"第三方回调能不能收到"，那骨架就必须包含一次真实的回调。
**风险要在项目第一周暴露，不是最后一周。**

### 为什么必须先部署

部署是最容易被无限推迟的一环，也是最容易在最后一刻炸的一环：
域名、证书、环境变量、数据库连接、构建产物路径、端口、防火墙、时区……
每一个都能卡半天。

在只有 200 行代码的时候解决这些，和在有 2 万行代码、还要赶上线的时候解决这些，
是完全不同的难度。**先让一个"Hello"上线，再让它变成产品。**

---

## 二、标准动词接口

**这是这套工程规范的核心，也是它与语言无关的原因。**

每个项目都提供同一组 `make` 目标。人和 AI 跨项目、跨语言只需要记这一套；
`AGENTS.md` 里写的验证命令永远是 `make check`，换技术栈也不会失效；
CI 跑的和本地跑的是同一条命令，不会出现"本地过了 CI 挂了"。

| 动词 | 含义 | 必须满足 |
|---|---|---|
| `make setup` | 全新机器一条命令到可开发 | 幂等，重复跑不出错 |
| `make dev` | 本地起起来 | 带热重载，前台运行 |
| `make fmt` | 格式化（**会改文件**） | — |
| `make fmt-check` | 检查格式（**只读**） | 不合格要非零退出 |
| `make lint` | 静态检查（**只读**） | 不通过要非零退出 |
| `make typecheck` | 类型检查 | 无类型系统的语言留空实现 |
| `make test` | 跑测试 | 不通过要非零退出 |
| `make check` | fmt-check + lint + typecheck + test | **提交前唯一要记的命令** |
| `make build` | 产出可部署产物 | — |
| `make ship` | 部署 | 幂等；失败不能留下半个状态 |
| `make audit` | 生成待人审清单（增量） | 每个 PR 跑，见 `audit.md` |
| `make review` | 里程碑复盘（全量） | 阶段结束时跑，见 `review.md` |
| `make doctor` | 工程基线体检 | 缺项要给出修复建议 |

规则：

1. **`make check` 是唯一的真理。** CI 跑它，pre-commit 跑它的快速子集，
   AI 声称"做完了"之前必须跑它并贴出输出。
2. **动词名不许改。** 语言差异体现在实现里，不体现在接口上。
3. 项目特有的操作可以加（`make seed`、`make migrate`），但上面这十个必须都在，
   哪怕是空实现。

### 语言差异只在 adapter 里

骨架的 `Makefile` 只定义动词并转发；具体命令来自 `stack.mk`：

```makefile
# stack.mk （由 new-project.sh 从 templates/adapters/ 拷入）
DEV       := bun run dev
FMT       := bunx biome format --write .
FMT_CHECK := bunx biome format .
LINT      := bunx biome check .
TYPECHECK := bunx tsc --noEmit
TEST      := bun test
BUILD     := bun run build
```

换语言就换这一个文件，`Makefile`、CI 配置、`AGENTS.md`、
所有文档里的命令一个字都不用改。

---

## 三、工程基线清单

`scripts/doctor.sh` 逐项检查这些。缺一项就不算过 G3。

### 版本控制
- [ ] `git init` 完成，有 `.gitignore`（覆盖依赖目录、构建产物、`.env`、编辑器文件）
- [ ] 第一个提交是骨架，不是一坨堆好的代码

### 代码质量（机器把关，人不该看的东西）
- [ ] 格式化器已配置，`make fmt` 可跑
- [ ] linter 已配置，`make lint` 不通过会非零退出
- [ ] 类型检查已配置（如果语言有）
- [ ] pre-commit 钩子：跑 `make fmt` + `make lint`（**不跑全量测试**，太慢会被绕过）

### 测试
- [ ] 测试框架已配置
- [ ] **至少有一个真在断言行为的测试**，不是 `assert(true)`
- [ ] 测试能单独跑一个文件（AI 迭代时需要）
- [ ] 有一条测试是覆盖骨架链路的端到端测试

### CI
- [ ] 推送和 PR 都触发
- [ ] **CI 里跑的就是 `make check`**，不是另抄一遍命令
- [ ] 失败会挡住合并
- [ ] 依赖有缓存（否则慢到没人愿意等）

### 配置与密钥
- [ ] 配置从环境变量读，不硬编码
- [ ] `.env.example` 有**所有键名和说明，没有任何真实值**
- [ ] `.env` 在 `.gitignore` 里
- [ ] 缺必需环境变量时，**启动即报错并指出缺哪个**，不要跑到一半才失败

### 可运维
- [ ] 健康检查端点（`/healthz`：进程活着 + 数据库连得上）
- [ ] 结构化日志，带请求 ID
- [ ] 日志里**不含**密码、token、身份证、完整手机号
- [ ] 未捕获异常会被记录，不是静默吞掉

### 文档
- [ ] `README.md`：这是什么 / `make setup` / `make dev` / `make check`，四段就够
- [ ] `AGENTS.md`：见 `handoff.md`
- [ ] `docs/runbook.md`：怎么部署、怎么回滚、出事看哪里（P6 完善，P3 先建空壳）
- [ ] LICENSE

---

## 四、目录约定

```
├── AGENTS.md              # 项目宪法：AI 每次开工必读
├── README.md
├── Makefile               # 标准动词
├── stack.mk               # 语言相关命令（唯一与技术栈耦合的文件）
├── .env.example
├── contracts/             # API schema、错误码、共享类型 —— 人机接缝，必审区
├── docs/
│   ├── spec.md            # 意图与验收标准
│   ├── glossary.md        # 术语、边界、不变量
│   ├── decisions/         # ADR
│   └── runbook.md         # 部署与回滚
├── src/
│   └── <上下文名>/         # 按限界上下文分，不按技术层分
│       ├── domain/        # 纯业务规则，不碰 IO
│       ├── app/           # 用例编排
│       └── infra/         # 数据库、外部调用
├── migrations/            # 数据库迁移 —— 必审区
└── tests/
```

**按限界上下文分目录，不按技术层分。** `src/order/domain/` 而不是
`src/domain/order/`。理由：一起变化的东西放在一起，一个 agent 做一个上下文的
任务时只需要读一个目录。

---

## 五、出口检查（G3 闸）

人**亲手**做这三件事，不是看 AI 的报告：

1. 在一个干净目录 `git clone` 后跑 `make setup && make dev`，能起来
2. 跑 `make check`，全绿
3. 打开部署出来的 URL，骨架链路能走通

加上：

- [ ] `doctor.sh` 全过
- [ ] CI 上有一次绿色记录
- [ ] 风险表里排第一的风险，已经在骨架里被真实验证过（不是"理论上可行"）
- [ ] `.env` 没进仓库（`git log --all -- .env` 为空）

过了 G3 才允许开始写业务功能。
