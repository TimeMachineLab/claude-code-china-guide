# Kimi K3 接入 Claude Code 配置教程（2026）

> 返回 [Claude Code / Codex 国内使用教程](../README.md) · 最后核对：2026-10-23 · 依据 [Kimi 开放平台：Claude Code 接入](https://platform.kimi.com/docs/guide/claude-code-kimi)

Kimi（月之暗面）官方提供 Anthropic 兼容接口，Claude Code 可以直接用 Kimi K3。K3 支持 100 万 token 上下文，Kimi 官方把它定位为编程 Agent 的默认模型。

## 需要准备

- 已安装 Claude Code（[安装教程](install-claude-code.md)）
- 在 [Kimi 开放平台](https://platform.kimi.com/) 创建的 API Key

## 配置

写进 `~/.claude/settings.json`（Windows：`%USERPROFILE%\.claude\settings.json`）的 `env`：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.moonshot.cn/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "YOUR_MOONSHOT_API_KEY",
    "ANTHROPIC_MODEL": "kimi-k3[1m]",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "kimi-k3[1m]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "kimi-k3[1m]",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "kimi-k2.7-code",
    "CLAUDE_CODE_SUBAGENT_MODEL": "kimi-k3[1m]",
    "CLAUDE_CODE_AUTO_COMPACT_WINDOW": "1000000",
    "CLAUDE_CODE_EFFORT_LEVEL": "max"
  }
}
```

可复制的文件：[`configs/claude-code/kimi.settings.json`](../configs/claude-code/kimi.settings.json)。

- `[1m]` 表示启用 1M 上下文，配合 `CLAUDE_CODE_AUTO_COMPACT_WINDOW` 使用。
- 以前设置过 `ANTHROPIC_API_KEY` 的，要删掉，避免和 `ANTHROPIC_AUTH_TOKEN` 冲突。

## Kimi 可选的模型

| 模型 | 特点 |
|---|---|
| `kimi-k3` | 默认推荐，1M 上下文，适合编程 Agent |
| `kimi-k2.7-code` | 编程专用，**必须开启 Thinking** |
| `kimi-k2.6` | 通用模型 |

## 必看：`400 invalid thinking` 报错

`kimi-k2.7-code` 只接受开启思考的请求。没开 Thinking 时会报：

```text
400 invalid thinking: only type=enabled is allowed for this model
```

在 Claude Code 里按 **Alt+T**（macOS 是 **Option+T**）打开 Thinking 即可。上面的配置把它放在 Haiku 档，后台小任务报这个错时也是同一个原因；嫌麻烦可以把 Haiku 档也改成 `kimi-k3`。

## 验证

```bash
bash scripts/check-api.sh anthropic https://api.moonshot.cn/anthropic kimi-k3
```

然后重启 Claude Code，输入 `/status`：Base URL 应该是 Moonshot 的地址，模型是 `kimi-k3[1m]`。

## 想在 Kimi 和其他模型之间切换？

- 多个配置之间一键切换：[CC Switch 使用教程](cc-switch.md)
- 一个 Key 同时调用 Kimi K3、DeepSeek、GLM、Claude、GPT：[Orbis 上的 Kimi K3](https://orbiorbi.com/pricing/kimi-k3?utm_source=github&utm_medium=docs&utm_campaign=claude-code-china-guide&utm_content=kimi)（本仓库维护方，模型 ID 以它的模型页为准）

报错排查见 [常见报错排查](troubleshooting.md)。
