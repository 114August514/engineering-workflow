# 错误码表

所有错误码集中登记在这里。**代码里不许出现没登记的错误码，
更不许用临时字符串当错误信息给前端做判断依据。**

## 统一信封

```json
{
  "error": {
    "code": "OUT_OF_STOCK",
    "message": "库存仅剩 2 件",
    "details": { "sku": "A-001", "available": 2 },
    "traceId": "01J8X..."
  }
}
```

- `code` —— **稳定的机器可读串**，前端按它分支。定下就不改。
- `message` —— 给人看，可以改、可以翻译。**前端不许按它做逻辑判断。**
- `details` —— 结构由 `code` 决定，在下表里写清楚。
- `traceId` —— 必须能在日志里搜到。
- HTTP 状态码只表达大类（4xx 你错了 / 5xx 我错了），细节靠 `code`。

## 错误码

| code | HTTP | 含义 | details 字段 | 前端建议行为 |
|---|---|---|---|---|
| `VALIDATION_FAILED` | 400 | 请求参数不合法 | `fields[]` | 在对应字段旁显示错误 |
| `UNAUTHORIZED` | 401 | 未登录或凭证失效 | — | 跳登录页 |
| `FORBIDDEN` | 403 | 已登录但无权限 | — | 显示无权限，不要跳登录 |
| `NOT_FOUND` | 404 | 资源不存在 | `resource` | 显示空态 |
| `CONFLICT` | 409 | 状态冲突 | 视情况 | 刷新后重试 |
| `RATE_LIMITED` | 429 | 触发限流 | `retryAfter` | 按 `retryAfter` 退避 |
| `INTERNAL` | 500 | 服务端故障 | — | 显示"稍后重试" + traceId |

> 5xx 的 `message` **不许包含内部信息**（堆栈、SQL、文件路径、内网地址）。
