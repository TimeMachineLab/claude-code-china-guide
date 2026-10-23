# DeepSeek 接入 Claude Code 配置教程（DeepSeek V4，2026）

> 返回 [Claude Code / Codex 国内使用教程](../README.md) · 最后核对：2026-10-23 · 依据 [DeepSeek 官方：Claude Code 接入](https://api-docs.deepseek.com/quick_start/agent_integrations/claude_code)、[Anthropic API 兼容说明](https://api-docs.deepseek.com/guides/anthropic_api)

DeepSeek 官方提供 **Anthropic 兼容接口**，Claude Code 可以直接接入，国内直连，人民币付费，不需要 Claude 账号。

## 需要准备

- 已安装 Claude Code（[安装教程](install-claude-code.md)）
- 在 [DeepSeek 开放平台](https://platform.deepseek.com/) 创建的 API Key

## 配置

写进 `~/.claude/settings.json`（Windows：`%USERPROFILE%\.claude\settings.json`）的 `env`：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "YOUR_DEEPSEEK_API_KEY",
    "ANTHROPIC_MODEL": "deepseek-flash[1m]",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-flash[1m]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-flash[1m]",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-flash",
    "CLAUDE_CODE_SUBAGENT_MODEL": "deepseek-flash",
    "CLAUDE_CODE_EFFORT_LEVEL": "max",
    "CLAUDE_CODE_AUTO_COMPACT_WINDOW": "786432"
  }
}
```

可复制的文件：[`configs/claude-code/deepseek.settings.json`](../configs/claude-code/deepseek.settings.json)。

想用更强的 `deepseek-v4-pro`，把前三个模型变量改成 `deepseek-v4-pro`（价格按 V4 Pro 计）。

## DeepSeek 的模型名映射

DeepSeek 会自动把 Claude 的模型名映射成自家模型，所以**就算不设模型变量也能跑**：

| Claude Code 请求的模型名 | DeepSeek 实际使用 |
|---|---|
| `claude-opus-*` | `deepseek-v4-pro`（按 V4 Pro 计费） |
| `claude-sonnet-*`、`claude-haiku-*`、其他 `claude*` | `deepseek-flash` |
| 不是 `claude` 开头、也不在支持列表里 | 返回 `400` |

这也意味着：如果你在 Claude Code 里切到 Opus，费用会按 V4 Pro 算。想控制成本，就像上面那样显式写死模型。

## 兼容性要点

- `thinking` 的 `budget_tokens` 会被忽略；`output_config` 只支持 `effort`
- `cache_control`、`top_k`、`mcp_servers` 等参数会被忽略
- 不支持 document 类型内容块和 `redacted_thinking`

日常写代码基本不受影响；依赖这些特性的高级用法要注意。

## 验证

```bash
bash scripts/check-api.sh anthropic https://api.deepseek.com/anthropic deepseek-flash
```

返回 OK 后，启动 `claude`，输入 `/status` 核对 Base URL 和模型，再到 DeepSeek 控制台看用量。

## 只用 DeepSeek，还是一个 Key 用多家？

只写代码、追求便宜，DeepSeek 官方接口就够了。如果还想在同一个 Claude Code 里随时换 Claude、GPT、Kimi、GLM，可以用聚合平台，比如 [Orbis](https://orbiorbi.com/pricing/deepseek-v4.1-flash?utm_source=github&utm_medium=docs&utm_campaign=claude-code-china-guide&utm_content=deepseek)（本仓库维护方，模型 ID 与官方不同，以它的模型页为准）。不知道哪个模型写代码更强，可以看 [AI 编程模型排行榜](https://orbiorbi.com/leaderboards/code/?utm_source=github&utm_medium=docs&utm_campaign=claude-code-china-guide&utm_content=deepseek)。

报错排查见 [常见报错排查](troubleshooting.md)。
