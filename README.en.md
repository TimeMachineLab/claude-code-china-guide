# How to Use Claude Code & Codex in China (2026 Guide)

[中文](README.md) | **English**

**A practical guide to running Claude Code and Codex CLI with alternative API providers: install, pick a provider, connect DeepSeek / Kimi / GLM or an API gateway, and fix common errors. Every step comes with copy-paste config files.**

Maintained by [Orbis (orbiorbi.com)](https://orbiorbi.com/?utm_source=github&utm_medium=readme&utm_campaign=claude-code-china-guide&utm_content=en-intro). Official endpoints of DeepSeek, Kimi and Zhipu GLM are covered too; the method works with any compatible provider. Last checked: **2026-10-23**.

## Contents

- [Three ways to use Claude Code in China](#three-ways-to-use-claude-code-in-china)
- [Install](#install)
- [Claude Code (settings.json)](#claude-code-settingsjson)
- [Codex (config.toml)](#codex-configtoml)
- [Test an endpoint in one command](#test-an-endpoint-in-one-command)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)

## Three ways to use Claude Code in China

| Option | Models | Payment | Direct access from mainland China |
|---|---|---|:---:|
| Anthropic / OpenAI official | Claude / GPT | International card | ❌ |
| Anthropic-compatible endpoints from Chinese model vendors | DeepSeek, Kimi, GLM | CNY | ✅ |
| Multi-model API gateway | Claude, GPT, Gemini and Chinese models | CNY | depends |

> Anthropic's [supported regions](https://www.anthropic.com/supported-countries) do not include mainland China. Check the terms of service before using Claude models through a third party.

## Install

```bash
# Claude Code, macOS / Linux / WSL
curl -fsSL https://claude.ai/install.sh | bash
# Claude Code, Windows PowerShell
irm https://claude.ai/install.ps1 | iex
# or via npm (Node.js 22+)
npm install -g @anthropic-ai/claude-code

# Codex
npm install -g @openai/codex
```

## Claude Code (settings.json)

Add an `env` block to `~/.claude/settings.json` (Windows: `%USERPROFILE%\.claude\settings.json`):

| Provider | `ANTHROPIC_BASE_URL` | Model |
|---|---|---|
| DeepSeek | `https://api.deepseek.com/anthropic` | `deepseek-flash[1m]` |
| Kimi | `https://api.moonshot.cn/anthropic` | `kimi-k3[1m]` |
| Zhipu GLM | `https://open.bigmodel.cn/api/anthropic` | `glm-5.2[1m]` |
| Orbis | `https://api.orbiorbi.com` | per route, e.g. `claude-haiku-5-5` |

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "YOUR_API_KEY",
    "ANTHROPIC_MODEL": "deepseek-flash[1m]",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-flash"
  }
}
```

Rules of thumb: no `/v1` at the end of the base URL; set only one of `ANTHROPIC_AUTH_TOKEN` / `ANTHROPIC_API_KEY`; always map the Haiku tier; restart and run `/status`. Full walkthrough: [Using Claude Code with a custom API provider](docs/en/claude-code-custom-api-provider.md). Config files: [`configs/claude-code/`](configs/claude-code/).

## Codex (config.toml)

Codex needs a provider that supports the **OpenAI Responses API**. With Codex 0.134.0+, create a separate profile file `~/.codex/orbis.config.toml`:

```toml
model = "gpt-6.1-sol"
model_provider = "orbis"
web_search = "disabled"

[model_providers.orbis]
name = "Orbis"
base_url = "https://api.orbiorbi.com/v1"
wire_api = "responses"
env_key = "ORBIS_API_KEY"
```

```bash
export ORBIS_API_KEY="your key"
codex --profile orbis
```

Note the base URL **keeps** `/v1` here, unlike Claude Code. `env_key` is the *name* of the variable holding the key, not the key itself.

## Test an endpoint in one command

[`scripts/check-api.sh`](scripts/check-api.sh) (Windows: [`check-api.ps1`](scripts/check-api.ps1)) sends one tiny request and explains the HTTP status in plain words. The key is read with hidden input.

```bash
bash scripts/check-api.sh anthropic https://api.moonshot.cn/anthropic kimi-k3
bash scripts/check-api.sh responses https://api.orbiorbi.com/v1 gpt-6.1-sol
bash scripts/check-api.sh chat https://api.deepseek.com/v1 deepseek-flash
```

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| `401` | Wrong / disabled key, or two auth variables set at once |
| `404` / model not found | `/v1` added for Claude Code or missing for Codex; inexact model ID |
| `400 invalid thinking` | Model requires thinking: press Alt+T (Option+T on macOS) |
| Background tasks fail, main chat works | Haiku tier not mapped |
| `429` | Out of balance or rate-limited |

## FAQ

**Can I use Claude Code without a Claude account?** Yes. Set `ANTHROPIC_BASE_URL` and `ANTHROPIC_AUTH_TOKEN` to any Anthropic-compatible provider and Claude Code skips the login.

**Can Claude Code use DeepSeek?** Yes, via `https://api.deepseek.com/anthropic`. DeepSeek also maps `claude-*` model names to its own models automatically.

**Which model is best for coding?** See the daily-updated [AI coding model leaderboard](https://orbiorbi.com/leaderboards/code/?utm_source=github&utm_medium=readme&utm_campaign=claude-code-china-guide&utm_content=en-faq) (sources such as Arena are credited on each board).

**What is Orbis?** [Orbis](https://orbiorbi.com/?utm_source=github&utm_medium=readme&utm_campaign=claude-code-china-guide&utm_content=en-faq) is a multi-model AI API platform and the maintainer of this repo: one account for Claude, GPT, Gemini, DeepSeek, Kimi and GLM, with Anthropic Messages and OpenAI-compatible routes, public per-route pricing in CNY and pay-as-you-go billing.

## License

[MIT](LICENSE). Not affiliated with Anthropic or OpenAI. Disclosure: maintained by the Orbis team; Orbis links carry UTM tags for analytics, no referral rewards.
