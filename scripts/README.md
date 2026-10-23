# check-api：一行命令检测 API 是否接通

发一条最小请求（最多 32 个输出 token），检测「地址 + Key + 模型」是否可用，并把 HTTP 状态翻译成具体原因。Key 用隐藏输入读取，或从环境变量 `API_KEY` 读取，不会出现在命令历史和进程列表里。

| 协议 | 给哪个工具用 | 地址怎么写 |
|---|---|---|
| `anthropic` | Claude Code | 根地址，不带 `/v1` |
| `responses` | Codex | 带 `/v1` |
| `chat` | WorkBuddy、大多数 OpenAI 兼容客户端 | 带 `/v1`（填完整 `/chat/completions` 也行） |

macOS / Linux / Git Bash：

```bash
bash scripts/check-api.sh anthropic https://api.deepseek.com/anthropic deepseek-flash
```

Windows PowerShell（如果系统禁止运行脚本，可以只对这一次放行）：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\check-api.ps1 anthropic https://api.moonshot.cn/anthropic kimi-k3
```

能识别的情况：接通（200）、Key 无效（401/403）、路径或模型不对（404）、请求被拒（400/422）、余额或限速（402/429）、服务商故障（5xx）、网络不通，以及「地址打到了网站上，返回网页而不是 API 响应」。
