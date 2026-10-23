# WorkBuddy 接入第三方 API 教程（自定义模型）

> 返回 [Claude Code / Codex 国内使用教程](../README.md) · 最后核对：2026-10-23 · 参考 [WorkBuddy 官方模型配置说明](https://www.workbuddy.cn/docs/workbuddy/From-Beginner-to-Expert-Guide/Function-Description/Model)

WorkBuddy 支持添加「自定义 / Custom」模型，填入任何 **OpenAI Chat Completions 兼容**的接口。这样就能在 WorkBuddy 里用 DeepSeek、Kimi、GLM 或聚合平台上的模型。

## 和 Claude Code、Codex 最大的不同：要填完整地址

| 工具 | 地址怎么填 | 例子 |
|---|---|---|
| Claude Code | 根地址，不带 `/v1` | `https://api.orbiorbi.com` |
| Codex | 带 `/v1` | `https://api.orbiorbi.com/v1` |
| **WorkBuddy（开启自定义协议）** | **完整接口路径** | `https://api.orbiorbi.com/v1/chat/completions` |

开启「自定义协议」后，WorkBuddy 会**原样请求你填的 URL，不再自动补路径**。只填到 `/v1` 就会 404。

## 配置步骤

1. 打开 **设置 → 模型 → 添加模型**，选择 **自定义 / Custom**。
2. 填写：

   | 字段 | 填写 |
   |---|---|
   | 接口地址 | 服务商的完整 Chat Completions 地址，以 `/v1/chat/completions` 结尾 |
   | API KEY | 服务商的 API Key（它不能代替 WorkBuddy 自己的账号登录） |
   | 模型名称 | 服务商的精确模型 ID |

3. 高级配置里打开 **工具调用** 和 **自定义协议**。
4. 保存后**新建一个任务**，在「自定义模型」分组里选中它。

以 Orbis 的 DeepSeek V4.1 Flash 为例：接口地址 `https://api.orbiorbi.com/v1/chat/completions`，模型名称 `deepseek-v4.1-flash`，Key 要为支持 Chat Completions 和工具调用的线路创建。详见 [Orbis 文档：WorkBuddy 接入](https://orbiorbi.com/docs/workbuddy/?utm_source=github&utm_medium=docs&utm_campaign=claude-code-china-guide&utm_content=workbuddy)。

## 先测一下接口

```bash
bash scripts/check-api.sh chat https://api.orbiorbi.com/v1 deepseek-v4.1-flash
```

（脚本的 `chat` 模式会自动拼上 `/chat/completions`，所以这里只写到 `/v1`。）

## 验证文件工具是否可用

能聊天不代表能干活。接通后：

1. 发一句「只回复 OK」，到服务商调用日志核对模型和扣费。
2. 选一个只放练习材料的工作空间，在 **Agent 模式**下让它读一个小文件。
3. 再让它新建并保存一个文件，打开确认内容。

## 常见问题

| 现象 | 检查什么 |
|---|---|
| `401` / 模型不可用 | Key、Key 绑定的线路、模型 ID、余额 |
| `404` / 接口不存在 | 地址是否以 `/v1/chat/completions` 结尾；自定义协议是否开启 |
| 能聊天，不能读写文件 | 是否在 Agent 模式；工具调用是否开启；服务商是否支持工具调用 |
| 找不到刚加的模型 | 是否保存；是否在**新任务**里从「自定义模型」分组选择 |
