# Codex 接入第三方 API：config.toml 配置教程

> 返回 [Claude Code / Codex 国内使用教程](../README.md) · 最后核对：2026-10-23

Codex CLI 是 OpenAI 出的终端 AI 编程工具。它通过 `config.toml` 里的 `model_providers` 支持自定义服务商，所以可以接入中转站、聚合平台或其他兼容服务，而不必用 ChatGPT 账号登录。

## 先确认服务商支持 Responses API

Codex 依赖 **OpenAI Responses API** 的流式输出、续聊和工具调用。服务商**只提供 Chat Completions 接口**的话，不能直接套用本文。拿不准时，先用本仓库的脚本测一下：

```bash
bash scripts/check-api.sh responses https://服务商地址/v1 模型ID
```

## 安装

```bash
npm install -g @openai/codex
codex --version
```

## 推荐做法：独立 profile 文件

Codex 0.134.0 及以上支持「独立 profile 文件」：放在 `~/.codex/<名字>.config.toml`，用 `codex --profile <名字>` 启动。**不会改动你默认的配置和登录状态**，想切回去就直接运行不带 `--profile` 的 `codex`。

以 Orbis 为例，新建 `~/.codex/orbis.config.toml`（Windows：`%USERPROFILE%\.codex\orbis.config.toml`）：

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

每一项的意思：

| 配置 | 含义 | 容易错的地方 |
|---|---|---|
| `model` | 模型 ID | 必须和服务商列表一致 |
| `model_provider` | 用哪个 provider，对应下面 `[model_providers.xxx]` 的名字 | 两处名字要一样 |
| `web_search` | 是否启用网页搜索 | 第三方服务不一定支持，先关掉，接通后再试 |
| `base_url` | 服务商地址 | **要带 `/v1`，但不要带 `/responses`** |
| `wire_api` | 协议 | 填 `responses` |
| `env_key` | **存放 Key 的环境变量名**，不是 Key 本身 | 别把 Key 直接填在这里 |

顶部三项要放在所有 `[表头]` 之前。

## 设置 Key 并启动

macOS / Linux：

```bash
printf '粘贴 API Key：'
read -rs ORBIS_API_KEY
printf '\n'
export ORBIS_API_KEY
codex --profile orbis
```

Windows PowerShell：

```powershell
$env:ORBIS_API_KEY = [System.Net.NetworkCredential]::new('', (Read-Host '粘贴 API Key' -AsSecureString)).Password
codex --profile orbis
```

Key 只在当前终端有效。恢复上次会话：`codex --profile orbis resume`。

> 从桌面图标启动的 Codex 应用拿不到终端里的环境变量，本文的配置只针对 CLI。

## 换成其他服务商

把文件名、provider 名、`base_url`、`model`、`env_key` 换掉即可，比如：

```toml
model = "服务商的模型ID"
model_provider = "myprovider"

[model_providers.myprovider]
name = "My Provider"
base_url = "https://服务商地址/v1"
wire_api = "responses"
env_key = "MY_PROVIDER_API_KEY"
```

保存为 `~/.codex/myprovider.config.toml`，用 `codex --profile myprovider` 启动。模板文件：[`configs/codex/`](../configs/codex/)。

## 验证

1. 启动后输入 `/status`，核对 provider、模型和工作目录。
2. 发一句「只回复 OK」，再到服务商的调用日志核对模型和扣费。
3. 让它读一个文件，再追问一句，分别检查**工具调用**和**续聊**。

## 常见问题

| 现象 | 检查什么 |
|---|---|
| 提示缺少 `ORBIS_API_KEY` / `401` | 变量是不是在**启动 Codex 的同一个终端**里设置的；Key 是否有效 |
| 配置没有生效 | Codex 版本是否 ≥ 0.134.0；启动时有没有带 `--profile` |
| `404` / 模型不可用 | `base_url` 是否带 `/v1`；模型 ID 是否完全一致；Key 是否属于支持这个模型的线路 |
| 能回答，但读文件或续聊失败 | 服务商的 Responses 兼容性不完整，保留报错信息找服务商 |

Orbis 的完整说明见 [Orbis 文档：Codex 接入](https://orbiorbi.com/docs/codex/?utm_source=github&utm_medium=docs&utm_campaign=claude-code-china-guide&utm_content=codex)。想在多个供应商之间快速切换，见 [CC Switch 使用教程](cc-switch.md)。
