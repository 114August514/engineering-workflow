---
name: api-contract
description: 定义或修改前后端接口契约：路径与命名约定、请求响应形状、统一错误信封与错误码表、两种分页模型、时间与金额表示、类型同步（生成而不是手写）、破坏性变更三步走、数据库迁移与可回滚的 down。契约是前后端的接缝，定好之后两边可以并行开发。Use when designing or changing an API, OpenAPI schema, shared types, error codes, or database migrations — including "接口怎么定"、"这个字段该叫什么"、"错误码怎么设计"、"分页怎么做"、"前后端类型怎么同步"、"改接口会不会炸"、"迁移怎么写". Not for implementing the endpoint (use backend-code) or consuming it in UI (use frontend-code).
---

读这两份：

1. `~/.claude/skills/engineering-project/references/always.md` —— 三条横切规则
2. `~/.claude/skills/engineering-project/references/contract.md` —— 契约规范本体

**契约是整个项目里最小、最致命、最可读的东西**：一个 200 行的 schema 决定几千行实现。
所以 `contracts/` 和 `migrations/` 是必审区，**契约变更必须单独提交**——
混在几百行实现里，人就审不动了。

先把「一点五、先把这些约定定死」那张表过一遍：路径风格、字段命名、时间、金额、
ID、列表信封、错误信封、分页模型。**最贵的不是定得对不对，是不统一。**

实现细节见 `~/.claude/skills/engineering-project/references/backend.md`；要走完整流程时用 `engineering-project` skill。
