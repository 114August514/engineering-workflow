---
name: backend-code
description: 写或改后端代码时的规范：越权防护（过滤必须落到 repository 层）、ID 设计（不暴露自增主键）、幂等、分层与依赖方向、DTO/Domain/DB Model 三分、事务边界与并发竞态、数据库 schema 与软删除、错误处理、可观测性与审计日志、后台任务。Use when writing, reviewing, or refactoring server-side code — including "帮我写个接口"、"这个查询怎么写"、"事务边界"、"并发怎么处理"、"权限怎么校验"、"数据库表怎么设计"、"日志怎么打"、"后台任务". Not for API shape/contract design (use api-contract) or UI code (use frontend-code).
---

读这两份，读完就干活：

1. `~/.claude/skills/engineering-project/references/always.md` —— 三条横切规则（先搜再写 / 先测且看它红 / 别过度设计）
2. `~/.claude/skills/engineering-project/references/backend.md` —— 后端规范本体，按"后期最难补"排序

前三节是不可逆的，优先读：**越权**（OWASP API 风险第一位，而且最自然的写法就是错的，
功能测试完全查不出来）、**ID 设计**、**幂等**。

碰 `contracts/` 或 `migrations/` 时先看 `~/.claude/skills/engineering-project/references/contract.md`——那是必审区；
要走完整流程时用 `engineering-project` skill。
