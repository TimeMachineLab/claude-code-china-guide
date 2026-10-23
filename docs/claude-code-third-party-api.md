# Claude Code 接入第三方 API / 中转站：settings.json 配置教程

> 返回 [Claude Code / Codex 国内使用教程](../README.md) · 最后核对：2026-10-23

Claude Code 默认连接 Anthropic 官方，但它会读取几个环境变量来决定**请求发到哪、用什么 Key、调哪个模型**。把这几个变量改成第三方服务的值，就能接入 DeepSeek、Kimi、GLM 官方接口或任何 Anthropic 兼容的中转站、聚合平台。

前提：服务商必须支持 **Anthropic Messages 协议**（`/v1/messages`）。只支持 OpenAI 格式的接口不能直接给 Claude Code 用。

## 需要设置的变量

| 变量 | 作用 | 必填 |
|---|---|:---:|
| `ANTHROPIC_BASE_URL` | 服务商的 Anthropic 兼容地址，**末尾不加 `/v1`** | ✅ |
| `ANTHROPIC_AUTH_TOKEN` | 你的 API Key（以 `Authorization: Bearer` 发送） | ✅ |
| `ANTHROPIC_MODEL` | 主对话用的模型 ID | 推荐 |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` / `..._SONNET_MODEL` / `..._HAIKU_MODEL` | 把 Claude Code 内置的 Opus / Sonnet / Haiku 三档映射到服务商的模型 | 推荐 |
| `CLAUDE_CODE_SUBAGENT_MODEL` | 子代理用的模型 | 可选 |
| `API_TIMEOUT_MS` | 请求超时（毫秒），慢模型可以调大 | 可选 |

> `ANTHROPIC_API_KEY` 也能传 Key（以 `x-api-key` 发送）。**它和 `ANTHROPIC_AUTH_TOKEN` 只设一个**，两个都有会认证冲突。

## 写进 settings.json（最常用）

文件位置：

- macOS / Linux：`~/.claude/settings.json`
- Windows：`%USERPROFILE%\.claude\settings.json`

**已有这个文件就先备份**，只把下面的 `env` 合并进去：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://你的服务商地址",
    "ANTHROPIC_AUTH_TOKEN": "YOUR_API_KEY",
    "ANTHROPIC_MODEL": "主模型ID",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "主模型ID",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "主模型ID",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "便宜快速的模型ID"
  }
}
```

各服务商的现成配置：[`configs/claude-code/`](../configs/claude-code/)。

`settings.json` 里的值会覆盖终端里 `export` 的同名变量。改完要**完全退出再重新打开** Claude Code。

## 更安全的做法：Key 不落盘

`settings.json` 里的 Key 是明文，备份、同步、截图时都可能泄露。可以只在文件里写地址和模型，Key 每次在终端里临时输入（输入时不显示）：

macOS / Linux（Zsh、Bash）：

```bash
printf '粘贴 API Key：'
read -rs ANTHROPIC_AUTH_TOKEN
printf '\n'
export ANTHROPIC_AUTH_TOKEN
claude
```

Windows PowerShell：

```powershell
$env:ANTHROPIC_AUTH_TOKEN = [System.Net.NetworkCredential]::new('', (Read-Host '粘贴 API Key' -AsSecureString)).Password
claude
```

这个变量只在当前终端有效，新开终端要重新输入。

## 验证是否生效

1. 启动 `claude`，输入 `/status`，核对 Base URL、凭据来源和模型。
2. 发一句「只回复 OK」。
3. 到服务商控制台的**调用日志**里，核对实际调用的模型和扣费。
4. 让它读一个小文件，确认工具调用也正常。普通对话成功，不代表工具调用一定兼容。

也可以在配置之前，先用本仓库的脚本单独测一下地址、Key、模型是否可用：

```bash
bash scripts/check-api.sh anthropic https://你的服务商地址 模型ID
```

## 示例：接入 Orbis

[Orbis](https://orbiorbi.com/?utm_source=github&utm_medium=docs&utm_campaign=claude-code-china-guide&utm_content=third-party-orbis)（本仓库维护方）是多模型聚合平台。它的 Key **绑定线路**，所以要先在模型广场选一个 Claude 模型、选择支持 Anthropic Messages 的线路，再为这条线路创建 Key。以 Claude Haiku 5.5 为例：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.orbiorbi.com",
    "ANTHROPIC_MODEL": "claude-haiku-5-5",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "claude-haiku-5-5"
  }
}
```

Key 用上面「不落盘」的方式输入。注意两点：只改模型 ID 不会切换线路；主模型和后台小模型都要在这个 Key 的可用范围内。完整步骤见 [Orbis 文档：Claude Code 接入](https://orbiorbi.com/docs/claude-code/?utm_source=github&utm_medium=docs&utm_campaign=claude-code-china-guide&utm_content=third-party-orbis)。

## 常见问题

**改了配置没生效？** 先确认改的是用户目录下的 `settings.json`，不是项目里的 `.claude/settings.json`（项目级设置会覆盖用户级）。再确认已经完全重启 Claude Code。

**主对话正常，压缩上下文、生成标题之类的后台任务报错？** 后台任务用的是 Haiku 档，没设置 `ANTHROPIC_DEFAULT_HAIKU_MODEL` 时它会去请求一个服务商没有的模型。

**怎么切回官方账号？** 删掉 `env` 里这几个变量（或者把 `settings.json` 换回备份），重启后用 `/login` 登录。频繁切换的话，用 [CC Switch](cc-switch.md) 更方便。

更多报错见 [常见报错排查](troubleshooting.md)。
