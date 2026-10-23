# Claude Code / Codex 常见报错排查：401、404、400、429、超时

> 返回 [Claude Code / Codex 国内使用教程](../README.md) · 最后核对：2026-10-23

接第三方 API 时，九成的问题出在三样东西上：**地址、Key、模型 ID**。排查顺序建议是：

1. **先绕开工具单独测接口**：`bash scripts/check-api.sh <协议> <地址> <模型>`（Windows 用 `scripts/check-api.ps1`）。脚本通了而工具不通，问题就在工具配置；脚本也不通，问题在地址、Key 或服务商。
2. **再看工具实际用了什么**：Claude Code 和 Codex 都输入 `/status`，核对 Base URL、凭据来源和模型。
3. **最后看服务商的调用日志**：请求到没到、用的哪个模型、有没有扣费。

## 401 Unauthorized / Invalid token / 要求重新登录

| 原因 | 处理 |
|---|---|
| Key 复制不完整，或复制了页面上带遮罩的 Key | 用控制台的「复制」按钮重新复制 |
| Key 已停用、过期或额度用完 | 到控制台检查 Key 状态 |
| Claude Code 里 `ANTHROPIC_API_KEY` 和 `ANTHROPIC_AUTH_TOKEN` 同时存在 | 只保留一个，第三方服务一般用 `ANTHROPIC_AUTH_TOKEN` |
| 旧的登录状态或 `apiKeyHelper` 覆盖了配置 | `/status` 看凭据来源，删掉多余的那套 |
| Codex 的 Key 变量没在启动它的终端里设置 | 在同一个终端里设置变量后再运行 `codex` |
| Key 发错了服务商（比如把 A 平台的 Key 发给了 B 的地址） | 确认地址和 Key 属于同一家 |

## 404 Not Found / model not found / 模型不存在

| 原因 | 处理 |
|---|---|
| **Claude Code 地址多加了 `/v1`** | Anthropic 协议填根地址，例如 `https://api.deepseek.com/anthropic` |
| **Codex 地址少了 `/v1`** | 例如 `https://api.orbiorbi.com/v1` |
| WorkBuddy 开了自定义协议，但只填到 `/v1` | 填完整的 `/v1/chat/completions` |
| 模型 ID 不一致（大小写、版本号、`-` 和 `.`） | 从服务商的模型列表直接复制 |
| 这个 Key 所在的线路 / 套餐不包含这个模型 | 换模型，或为支持它的线路新建 Key |

## 400 Bad Request

| 报错内容 | 原因 | 处理 |
|---|---|---|
| `invalid thinking: only type=enabled is allowed` | 用了必须开思考的模型（如 `kimi-k2.7-code`） | Claude Code 里按 Alt+T（macOS：Option+T）打开 Thinking |
| 提到 `[1m]` 模型不存在 | Claude Code 版本太旧 | `claude update` 升级 |
| 切换思考强度后报 400 | 服务商的思考参数格式和工具不一致 | 换回默认强度，或查服务商文档 |
| 模型名不被接受 | 服务商只接受特定前缀（如 DeepSeek 要求 `claude` 开头或自家模型名） | 改成服务商列表里的名字 |

## 429 Too Many Requests / 余额不足

- 账户余额不足，或 Key 单独设置的额度用完了
- 触发了服务商的速率限制：降低并发，少开几个子代理
- 「无限额度」的 Key 也要账户里有钱

## 一直转圈、超时、连接被重置

- 用 `check-api` 脚本测一下，看是网络问题还是工具问题
- 地址拼写错误也会表现为超时（域名解析失败）
- 慢模型或长任务：Claude Code 可以在 `env` 里设 `"API_TIMEOUT_MS": "3000000"`
- 公司网络或代理拦截了请求：换网络试一次

## 能对话，但工具调用 / 读写文件 / 续聊失败

这说明「连通」没问题，是**协议兼容性**不完整：

- Claude Code：服务商的 Anthropic 兼容是否支持 tools、流式输出
- Codex：服务商的 Responses API 是否完整支持流式、续聊、工具调用
- 保留脱敏后的报错信息（删掉 Key），提交给服务商

## 主对话正常，后台小任务报错

Claude Code 会用 Haiku 档模型做压缩上下文、生成标题等后台任务。没设 `ANTHROPIC_DEFAULT_HAIKU_MODEL` 时，它会去请求一个服务商没有的模型。把这个变量设成服务商支持的便宜模型即可。

## 还是不行？

- 到本仓库的 [Issues](../../../issues) 提问，附上：工具和版本、服务商、地址（不要贴 Key）、`/status` 的输出、完整报错
- Orbis 用户可以对照 [Orbis 文档的排查表](https://orbiorbi.com/docs/claude-code/?utm_source=github&utm_medium=docs&utm_campaign=claude-code-china-guide&utm_content=troubleshooting)，或到控制台的使用日志查看每次请求的模型、线路和扣费
