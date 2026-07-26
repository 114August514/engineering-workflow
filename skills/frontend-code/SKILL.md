---
name: frontend-code
description: 写或改前端代码时的规范：design tokens 与视觉一致性、组件系统与八个交互状态、加载/空/错误三态、状态该放哪（组件内/URL/数据获取库缓存）、表单、契约消费与类型生成、可访问性最低线，以及 AI 看不见界面时该怎么验收。Use when writing, reviewing, or restyling any frontend component, page, layout, form, or CSS — including "帮我写个组件"、"这个页面怎么布局"、"样式怎么统一"、"UI 规范"、"前端状态放哪"、"这个表单怎么做"、"暗色模式"、"前端怎么调接口". Not for API design itself (use api-contract) or server code (use backend-code).
---

读这两份，读完就干活：

1. `~/.claude/skills/engineering-project/references/always.md` —— 三条横切规则（先搜再写 / 先测且看它红 / 别过度设计）
2. `~/.claude/skills/engineering-project/references/frontend.md` —— 前端规范本体

主线：**AI 看不见自己写的界面，所以要把"看起来对不对"尽量转化成"能不能被机器检查"。**
design tokens 就是这个转化——散值机器可查，视觉不协调不可查。

改动涉及接口字段或错误码时，先看 `~/.claude/skills/engineering-project/references/contract.md`；
要走完整流程（新项目、动契约/权限/数据模型）时，用 `engineering-project` skill。
