# Claude Code / Codex 国内使用教程（2026）

**中文** | [English](README.en.md)

**一份面向国内开发者的 Claude Code 和 Codex 上手指南：安装、选择 API 来源、接入中转站或 DeepSeek / Kimi / GLM、排查报错。每一步都有可以直接复制的配置文件。**

在国内用 Claude Code 和 Codex，最常卡在这几步：官方账号注册不了、没有海外信用卡、接口连不上、`settings.json` 写错、模型 ID 对不上。本仓库按「安装 → 选来源 → 配置 → 验证 → 排错」的顺序讲清楚，并附一个**一行命令检测 API 是否接通**的脚本。

> 由 [Orbis（orbiorbi.com）](https://orbiorbi.com/?utm_source=github&utm_medium=readme&utm_campaign=claude-code-china-guide&utm_content=intro) 团队维护。文中同时给出 DeepSeek、Kimi、GLM 官方接口的配置，方法适用于任何兼容服务。
> 最后核对：**2026-10-23**。配置过时了？欢迎提 [Issue](../../issues) 或 PR。

## 目录

- [30 秒看懂：国内用 Claude Code 的三条路](#30-秒看懂国内用-claude-code-的三条路)
- [第 1 步：安装 Claude Code 和 Codex](#第-1-步安装-claude-code-和-codex)
- [第 2 步：选择 API 来源](#第-2-步选择-api-来源)
  - [接口在线状态（每日自动检测）](#接口在线状态每日自动检测)
- [第 3 步：配置 Claude Code（settings.json）](#第-3-步配置-claude-codesettingsjson)
- [第 4 步：配置 Codex（config.toml）](#第-4-步配置-codexconfigtoml)
- [第 5 步：一行命令检测是否接通](#第-5-步一行命令检测是否接通)
- [常见报错速查](#常见报错速查)
- [FAQ](#faq)
- [全部教程](#全部教程)

## 30 秒看懂：国内用 Claude Code 的三条路

Claude Code 是 Anthropic 出的命令行 AI 编程工具，Codex 是 OpenAI 出的同类工具。两者都允许**自定义 API 地址**，所以除了官方账号，还可以接其他兼容服务：

| 方式 | 能用的模型 | 付款 | 国内直连 | 适合谁 |
|---|---|---|:---:|---|
| ① Anthropic / OpenAI 官方 | Claude / GPT | 海外信用卡 | ❌ | 身在官方支持地区、有海外支付方式的人 |
| ② 国产模型官方的 Anthropic 兼容接口 | DeepSeek、Kimi、GLM 各自的模型 | 人民币 | ✅ | 只用一家国产模型 |
| ③ 多模型聚合平台（中转站） | Claude、GPT、Gemini、国产模型都有 | 人民币 | 视平台而定 | 想用一个 Key 切换多家模型 |

> ⚠️ Anthropic 官方的[服务地区](https://www.anthropic.com/supported-countries)不含中国大陆。通过第三方平台调用 Claude 模型前，请自行评估服务条款与合规风险；只用国产模型的话，② 是最省心的选择。

## 第 1 步：安装 Claude Code 和 Codex

**Claude Code**（官方推荐原生安装，会自动更新）：

```bash
# macOS / Linux / WSL
curl -fsSL https://claude.ai/install.sh | bash
```

```powershell
# Windows PowerShell
irm https://claude.ai/install.ps1 | iex
```

也可以用 npm 安装（需要 Node.js 22+）：`npm install -g @anthropic-ai/claude-code`。装完开一个新终端，运行 `claude --version` 能打印版本号就成功了。

如果 `claude.ai` 的安装脚本下载不了，用 npm 加国内镜像：`npm install -g @anthropic-ai/claude-code --registry=https://registry.npmmirror.com`。

**Codex**：

```bash
npm install -g @openai/codex
codex --version
```

详细步骤和 Windows 上的坑见 [Claude Code 安装教程](docs/install-claude-code.md)。

## 第 2 步：选择 API 来源

不管选哪家，你都要准备三样东西：

| 配置项 | 是什么 | 例子 |
|---|---|---|
| **Base URL** | 请求发到哪里 | `https://api.deepseek.com/anthropic` |
| **API Key** | 你的身份凭据，费用记在这个 Key 的账户上 | `sk-xxxx` |
| **模型 ID** | 调用哪个模型，必须和服务商的列表**一字不差** | `kimi-k3[1m]` |

各家的 Anthropic 兼容地址（Claude Code 用这个）：

| 服务商 | ANTHROPIC_BASE_URL | 推荐模型 ID | 教程 |
|---|---|---|---|
| DeepSeek 官方 | `https://api.deepseek.com/anthropic` | `deepseek-flash[1m]`、`deepseek-v4-pro` | [DeepSeek 接入 Claude Code](docs/deepseek-claude-code.md) |
| Kimi 官方 | `https://api.moonshot.cn/anthropic` | `kimi-k3[1m]` | [Kimi K3 接入 Claude Code](docs/kimi-k3-claude-code.md) |
| 智谱 GLM 官方 | `https://open.bigmodel.cn/api/anthropic` | `glm-5.2[1m]` | [GLM 接入 Claude Code](docs/glm-claude-code.md) |
| Orbis（聚合平台） | `https://api.orbiorbi.com` | 以控制台的接入页为准，例如 `claude-haiku-5-5` | [接入第三方 API 通用教程](docs/claude-code-third-party-api.md) |

> 模型名后面的 `[1m]` 是 Claude Code 的写法，表示启用 100 万 token 上下文。服务商不支持时去掉即可。

### 接口在线状态（每日自动检测）

<!-- BEGIN:status -->
| 服务商 | Claude Code 接入地址 | 状态 | 状态变化时间（北京时间） |
|---|---|:---:|---|
| DeepSeek 官方 | `https://api.deepseek.com/anthropic` | ✅ 在线 | 2026-10-23 23:16 |
| Kimi 官方 | `https://api.moonshot.cn/anthropic` | ✅ 在线 | 2026-10-23 23:16 |
| 智谱 GLM 官方 | `https://open.bigmodel.cn/api/anthropic` | ✅ 在线 | 2026-10-23 23:16 |
| Orbis | `https://api.orbiorbi.com` | ✅ 在线 | 2026-10-28 14:14 |

> 每天由 GitHub Actions 自动检测一次（不带 Key 发一个最小请求，收到「未授权」即说明服务在线）。检测服务器在海外，**只代表服务本身在线，不代表国内网络能直连**。运行记录见 [Actions](../../actions/workflows/status.yml)。
<!-- END:status -->

想先知道**哪个模型写代码最强**再选？可以看每天更新的 [AI 编程模型排行榜](https://orbiorbi.com/leaderboards/code/?utm_source=github&utm_medium=readme&utm_campaign=claude-code-china-guide&utm_content=choose-model)（数据来自 Arena 等公开评测，标注了来源）。

## 第 3 步：配置 Claude Code（settings.json）

Claude Code 启动时读取 `~/.claude/settings.json`（Windows 是 `%USERPROFILE%\.claude\settings.json`）里的 `env`。**已有这个文件就先备份，再把 `env` 合并进去**，别整个覆盖。

以 Kimi 官方接口为例：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.moonshot.cn/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "YOUR_API_KEY",
    "ANTHROPIC_MODEL": "kimi-k3[1m]",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "kimi-k3[1m]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "kimi-k3[1m]",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "kimi-k2.7-code",
    "CLAUDE_CODE_SUBAGENT_MODEL": "kimi-k3[1m]"
  }
}
```

其他服务商的完整配置在 [`configs/claude-code/`](configs/claude-code/)，复制后改掉 `YOUR_API_KEY` 就能用。

**四个最容易错的地方：**

1. **Anthropic 协议的地址末尾不要加 `/v1`**。Claude Code 会自己拼 `/v1/messages`。
2. **`ANTHROPIC_AUTH_TOKEN` 和 `ANTHROPIC_API_KEY` 只留一个**，同时存在会认证冲突。第三方服务一般用 `ANTHROPIC_AUTH_TOKEN`。
3. **Haiku 档（后台小模型）也要改**，否则 Claude Code 后台任务会去调一个你的服务商没有的模型，表现为「主对话正常，小任务报错」。
4. **改完要重启 Claude Code**，再输入 `/status` 核对 Base URL 和模型。

> 🔐 `settings.json` 里的 Key 是明文。不要把这个文件提交到 Git 仓库；也可以不写 `ANTHROPIC_AUTH_TOKEN`，改成每次在终端里临时设置（见[通用教程](docs/claude-code-third-party-api.md#更安全的做法key-不落盘)）。

## 第 4 步：配置 Codex（config.toml）

Codex 需要服务商支持 **OpenAI Responses API**（只支持 Chat Completions 的接口没法直接用）。推荐建一个**独立的 profile 文件**，不影响你原来的登录（需要 Codex 0.134.0+）。

`~/.codex/orbis.config.toml`（Windows：`%USERPROFILE%\.codex\orbis.config.toml`）：

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
export ORBIS_API_KEY="你的 Key"     # Windows PowerShell: $env:ORBIS_API_KEY="你的 Key"
codex --profile orbis
```

换成别的服务商，就改 `base_url`、`model` 和 provider 名字。注意 **Codex 的地址要带 `/v1`**，和 Claude Code 正好相反。完整说明见 [Codex 接入第三方 API](docs/codex-third-party-api.md)。

## 第 5 步：一行命令检测是否接通

配置之前先确认「地址 + Key + 模型」这三样本身是通的，能省掉一半排错时间。本仓库的 [`scripts/check-api.sh`](scripts/check-api.sh)（Windows 用 [`check-api.ps1`](scripts/check-api.ps1)）会发一条最小请求，然后把 HTTP 状态翻译成人话：

```bash
# Claude Code 用的 Anthropic 协议
bash scripts/check-api.sh anthropic https://api.moonshot.cn/anthropic kimi-k3

# Codex 用的 Responses 协议
bash scripts/check-api.sh responses https://api.orbiorbi.com/v1 gpt-6.1-sol
```

```text
→ POST https://api.moonshot.cn/anthropic/v1/messages  (model: kimi-k3)
✗ HTTP 401：Key 无效或已停用。重新复制完整 Key，确认它属于这个服务商 / 这条线路。
```

Key 会以隐藏输入的方式读取，不会出现在命令历史里。

## 常见报错速查

| 现象 | 最常见的原因 | 怎么处理 |
|---|---|---|
| `401` / 要求重新登录 | Key 错了；`AUTH_TOKEN` 和 `API_KEY` 同时设置；旧的登录状态覆盖了配置 | 重新复制完整 Key，删掉多余的认证变量，`/status` 核对凭据来源 |
| `404` / `model not found` | Claude Code 地址多加了 `/v1`；Codex 地址少了 `/v1`；模型 ID 不完全一致 | 对照上面两步检查地址；模型 ID 从服务商列表直接复制 |
| `400 invalid thinking` | 用了必须开思考的模型（如 `kimi-k2.7-code`） | Claude Code 里按 Alt+T（macOS 是 Option+T）打开 Thinking |
| 主对话正常，后台任务报错 | Haiku 档小模型没改 | 设置 `ANTHROPIC_DEFAULT_HAIKU_MODEL` |
| `429` | 余额不足或触发限速 | 检查余额和 Key 限额，降低并发 |
| 一直转圈 / 超时 | 网络问题；地址写错 | 先用 `check-api` 脚本单独测一次 |

更多报错和排查思路：[Claude Code / Codex 常见报错排查](docs/troubleshooting.md)。

## FAQ

### Claude Code 国内能用吗？

能。Claude Code 支持通过 `ANTHROPIC_BASE_URL` 换成任何 Anthropic 兼容接口。DeepSeek、Kimi、智谱 GLM 都有官方兼容接口，国内直连、人民币付费；想用 Claude、GPT 等海外模型，可以通过聚合平台接入，但要自行评估合规风险（见[上文提示](#30-秒看懂国内用-claude-code-的三条路)）。

### 没有海外信用卡，怎么用 Claude Code？

不需要 Claude 官方账号。直接用 DeepSeek / Kimi / GLM 官方 API Key，或者支持支付宝、微信的聚合平台的 Key，按[第 3 步](#第-3-步配置-claude-codesettingsjson)配置即可。

### Claude Code 可以用 DeepSeek 吗？

可以。DeepSeek 官方提供 `https://api.deepseek.com/anthropic`，而且会把 Claude 的模型名自动映射到 DeepSeek 模型。配置见 [DeepSeek 接入 Claude Code](docs/deepseek-claude-code.md)。

### Claude Code 中转站怎么选，靠不靠谱？

看四点：模型是不是真的（用调用日志和刁钻问题核对）、价格是否公开、能否小额按量付费、出问题有没有地方找人。低于官方价格太多的，要警惕拼车或逆向接口。完整清单见 [API 中转站怎么选](docs/choose-api-provider.md)，也可以参考社区维护的列表 [awesome-ai-gateway](https://github.com/cuihuan/awesome-ai-gateway)、[awesome-ai-api-proxy](https://github.com/howardpen9/awesome-ai-api-proxy)。

### 同时用好几家服务商，怎么切换方便？

用 [CC Switch](https://github.com/farion1231/cc-switch)，在图形界面里一键切换 Claude Code 和 Codex 的供应商，不用手改配置文件。教程：[CC Switch 使用教程](docs/cc-switch.md)。

### Claude Code 和 Codex 有什么区别，选哪个？

都是终端里的 AI 编程 Agent。Claude Code 用 Anthropic 协议，生态里的插件、MCP、子代理更多；Codex 用 OpenAI Responses 协议，和 GPT 系列模型配合最好。很多人两个都装，按任务切换。哪个模型更擅长写代码，可以参考 [AI 编程模型排行榜](https://orbiorbi.com/leaderboards/code/?utm_source=github&utm_medium=readme&utm_campaign=claude-code-china-guide&utm_content=faq-compare)。

### Orbis 是什么？

[Orbis](https://orbiorbi.com/?utm_source=github&utm_medium=readme&utm_campaign=claude-code-china-guide&utm_content=faq-orbis) 是一个多模型 AI API 平台，也是本仓库的维护方：

- 一个账户可以调用 Claude、GPT、Gemini、DeepSeek、Kimi、GLM 等模型
- 同时提供 Anthropic 协议（给 Claude Code）和 OpenAI Responses / Chat Completions 协议（给 Codex、WorkBuddy 等）
- 人民币按量计费，每条线路的价格公开在[模型广场](https://orbiorbi.com/pricing?utm_source=github&utm_medium=readme&utm_campaign=claude-code-china-guide&utm_content=faq-orbis)
- 有中文接入文档：[Claude Code](https://orbiorbi.com/docs/claude-code/?utm_source=github&utm_medium=readme&utm_campaign=claude-code-china-guide&utm_content=faq-orbis)、[Codex](https://orbiorbi.com/docs/codex/?utm_source=github&utm_medium=readme&utm_campaign=claude-code-china-guide&utm_content=faq-orbis)、[CC Switch](https://orbiorbi.com/docs/cc-switch/?utm_source=github&utm_medium=readme&utm_campaign=claude-code-china-guide&utm_content=faq-orbis)

本指南里的方法对任何兼容服务都适用，用不用 Orbis 都可以。

## 全部教程

| 教程 | 解决什么问题 |
|---|---|
| [Claude Code 安装教程（Windows / macOS / Linux）](docs/install-claude-code.md) | 安装失败、找不到 `claude` 命令、Windows 上的 Git Bash |
| [Claude Code 接入第三方 API / 中转站](docs/claude-code-third-party-api.md) | `settings.json` 每个变量的含义，Key 不落盘的写法 |
| [Codex 接入第三方 API（config.toml）](docs/codex-third-party-api.md) | profile、`wire_api`、`env_key` |
| [DeepSeek 接入 Claude Code](docs/deepseek-claude-code.md) | DeepSeek V4 的模型映射和上下文设置 |
| [Kimi K3 接入 Claude Code](docs/kimi-k3-claude-code.md) | `kimi-k3[1m]`、必须开 Thinking 的模型 |
| [GLM 接入 Claude Code](docs/glm-claude-code.md) | Coding Plan Key、超时设置 |
| [CC Switch 使用教程](docs/cc-switch.md) | 多个供应商一键切换、聚合模式 |
| [WorkBuddy 接入第三方 API](docs/workbuddy-custom-api.md) | 自定义模型、完整接口地址 |
| [常见报错排查](docs/troubleshooting.md) | 401 / 404 / 400 / 429 / 超时 |
| [API 中转站怎么选](docs/choose-api-provider.md) | 靠谱性检查清单 |
| [Using Claude Code with a custom API provider (EN)](docs/en/claude-code-custom-api-provider.md) | English version of the setup guide |

## 贡献

发现配置过时、想补充新的模型或工具？欢迎提 PR。请附上官方文档链接，方便核对。详见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## License

[MIT](LICENSE)。各服务商的名称和商标归其所有者；本仓库与 Anthropic、OpenAI 无关联。

> 披露：本仓库由 Orbis 团队维护，文中涉及 Orbis 的链接带有来源统计参数（UTM），不含邀请返利。
