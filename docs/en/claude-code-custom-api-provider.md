# How to Use Claude Code with a Custom API Provider (DeepSeek, Kimi, GLM, Gateways)

> Back to the [main guide](../../README.en.md) · Last checked: 2026-10-23

Claude Code connects to Anthropic by default, but it reads a few environment variables that decide **where requests go, which key is sent and which model is called**. Point them at any **Anthropic Messages-compatible** endpoint and Claude Code works without a Claude account.

## The variables

| Variable | Purpose |
|---|---|
| `ANTHROPIC_BASE_URL` | Provider's Anthropic-compatible base URL, **without `/v1`** |
| `ANTHROPIC_AUTH_TOKEN` | Your API key (sent as `Authorization: Bearer`) |
| `ANTHROPIC_MODEL` | Model for the main conversation |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` / `_SONNET_MODEL` / `_HAIKU_MODEL` | Map Claude Code's built-in tiers to the provider's models |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |
| `API_TIMEOUT_MS` | Request timeout in ms |

Set **either** `ANTHROPIC_AUTH_TOKEN` **or** `ANTHROPIC_API_KEY`, not both.

Put them in the `env` block of `~/.claude/settings.json` (Windows: `%USERPROFILE%\.claude\settings.json`). Back up the file first and merge, don't overwrite.

## Provider settings

| Provider | `ANTHROPIC_BASE_URL` | Suggested models | Source |
|---|---|---|---|
| DeepSeek | `https://api.deepseek.com/anthropic` | `deepseek-flash[1m]`, `deepseek-v4-pro` | [DeepSeek docs](https://api-docs.deepseek.com/quick_start/agent_integrations/claude_code) |
| Kimi (Moonshot) | `https://api.moonshot.cn/anthropic` | `kimi-k3[1m]`, haiku tier `kimi-k2.7-code` | [Kimi docs](https://platform.kimi.com/docs/guide/claude-code-kimi) |
| Zhipu GLM | `https://open.bigmodel.cn/api/anthropic` | `glm-5.2[1m]`, haiku tier `glm-4.7` | [Zhipu docs](https://docs.bigmodel.cn/cn/guide/develop/claude) |
| Orbis (multi-model gateway) | `https://api.orbiorbi.com` | per route, e.g. `claude-haiku-5-5` | [Orbis docs](https://orbiorbi.com/en/docs/claude-code/?utm_source=github&utm_medium=docs&utm_campaign=claude-code-china-guide&utm_content=en-guide) |

Ready-to-copy files: [`configs/claude-code/`](../../configs/claude-code/). `[1m]` enables the 1M-token context window in Claude Code; drop it if your provider doesn't support it.

Example (Kimi):

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.moonshot.cn/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "YOUR_API_KEY",
    "ANTHROPIC_MODEL": "kimi-k3[1m]",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "kimi-k3[1m]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "kimi-k3[1m]",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "kimi-k2.7-code"
  }
}
```

## Keep the key out of the file

```bash
read -rs ANTHROPIC_AUTH_TOKEN && export ANTHROPIC_AUTH_TOKEN && claude
```

```powershell
$env:ANTHROPIC_AUTH_TOKEN = [System.Net.NetworkCredential]::new('', (Read-Host 'API key' -AsSecureString)).Password; claude
```

## Verify

1. Test the endpoint on its own: `bash scripts/check-api.sh anthropic <base-url> <model>`
2. Restart Claude Code and run `/status` to confirm the base URL, credential source and model.
3. Send "Reply with only OK", then check the provider's usage log.

## Common errors

| Symptom | Likely cause |
|---|---|
| `401` | Wrong or disabled key; both `ANTHROPIC_API_KEY` and `ANTHROPIC_AUTH_TOKEN` set |
| `404` / model not found | `/v1` appended to the base URL; model ID not an exact match |
| `400 invalid thinking` | Model requires thinking (e.g. `kimi-k2.7-code`): press Alt+T / Option+T |
| Main chat works, background tasks fail | `ANTHROPIC_DEFAULT_HAIKU_MODEL` not set |

For Codex (`config.toml`, Responses API), see the [Codex guide (Chinese)](../codex-third-party-api.md) or the [English README](../../README.en.md#codex-configtoml).
