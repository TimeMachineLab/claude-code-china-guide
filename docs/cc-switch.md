# CC Switch 使用教程：一键切换 Claude Code / Codex 供应商（2026）

> 返回 [Claude Code / Codex 国内使用教程](../README.md) · 最后核对：2026-10-23 · 依据 [CC Switch 官方仓库](https://github.com/farion1231/cc-switch)

同时用 DeepSeek、Kimi、GLM 或好几个中转站时，反复手改 `settings.json` 和 `config.toml` 很容易出错。[CC Switch](https://github.com/farion1231/cc-switch) 是一个开源桌面应用（MIT），可以在图形界面里**一键切换 Claude Code、Codex、Gemini CLI 等工具的 API 供应商**。切换时只替换地址、Key 和模型，不会动你的插件、hooks 和其他设置。

## 安装

| 系统 | 方式 |
|---|---|
| Windows 10+ | 从 [Releases](https://github.com/farion1231/cc-switch/releases) 下载 `.msi` 安装包或免安装 `.zip` |
| macOS 12+ | `brew install --cask cc-switch`，或从 Releases 下载 `.dmg` |
| Linux | Releases 里的 `.deb` / `.rpm` / `.AppImage`；Arch 用 `paru -S cc-switch-bin` |

**第一次用之前，先备份** `~/.claude/settings.json` 和 `~/.codex/` 目录。

## 添加供应商

1. 左侧选择要配置的工具（Claude Code 或 Codex）。
2. 点「+」添加供应商：可以选内置的 90 多个预设，也可以选自定义。
3. 自定义时填写三项：**接口地址、API Key、模型**。在「高级选项」里选择上游协议：
   - Claude Code：**Anthropic Messages**
   - Codex：**OpenAI Responses API**
4. 编辑器会预览切换后的配置文件，确认无误后保存。
5. 点「启用」，然后**重新打开**对应的工具。

各家填什么：

| 供应商 | Claude Code 地址 | Codex 地址 |
|---|---|---|
| DeepSeek 官方 | `https://api.deepseek.com/anthropic` | —— |
| Kimi 官方 | `https://api.moonshot.cn/anthropic` | —— |
| 智谱 GLM 官方 | `https://open.bigmodel.cn/api/anthropic` | —— |
| Orbis | `https://api.orbiorbi.com` | `https://api.orbiorbi.com/v1` |

模型 ID 见各自的教程：[DeepSeek](deepseek-claude-code.md) · [Kimi K3](kimi-k3-claude-code.md) · [GLM](glm-claude-code.md)。

## 用链接一键导入

CC Switch 支持 `ccswitch://` 深度链接：点一下链接就能把供应商配置导入 CC Switch，不用手填。有的服务商在控制台提供了这种「一键导入」按钮。

> 🔐 导入链接里通常**带着你的 Key**，不要发到群里或公开的地方。

以 Orbis 为例：在控制台为线路创建 Key → 打开这条线路的「快速接入 → 工具接入 → Claude Code / Codex CLI」→ 选「CC Switch 一键导入」→ 在 CC Switch 里核对地址、模型、Key 后确认。注意 Claude 线路和 GPT 线路要**分别创建 Key**，不能一个 Key 混用。详见 [Orbis 文档：CC Switch 接入](https://orbiorbi.com/docs/cc-switch/?utm_source=github&utm_medium=docs&utm_campaign=claude-code-china-guide&utm_content=ccswitch)。

## 进阶：路由和聚合

| 功能 | 支持的工具 | 做什么 |
|---|---|---|
| **路由（本地代理）** | Claude Code、Codex、Gemini CLI、Grok Build | 请求经 `http://127.0.0.1:15721` 转发并转换协议，比如在 Claude Code 里用只支持 OpenAI 格式的模型；支持故障自动切换 |
| **聚合** | Claude Code（需 2.1.243+）、Codex | 把多个供应商的模型合并进同一个模型选择列表，每个请求发给所选模型的供应商；**不会自动故障切换** |

使用聚合时要让 CC Switch 一直运行；Codex 在聚合列表变化后需要完全重启（包括后台进程）。Orbis 的聚合配置步骤见 [CC Switch 聚合接入](https://orbiorbi.com/docs/cc-switch-aggregation/?utm_source=github&utm_medium=docs&utm_campaign=claude-code-china-guide&utm_content=ccswitch-aggregation)。

## 常见问题

| 现象 | 检查什么 |
|---|---|
| 切换后还在用旧供应商 | 有没有重新打开工具；有没有手写的 profile 或环境变量覆盖了 CC Switch 写入的配置 |
| `401` | Key 是否属于这个供应商 / 线路 |
| `404` | Claude Code 用的地址**不带** `/v1`，Codex 用的地址**带** `/v1` |
| 想恢复原来的配置 | 在 CC Switch 里启用原供应商，重开工具；或者换回你备份的配置文件 |

确认切换是否真的成功：在工具里输入 `/status` 看地址和模型，再到服务商的调用日志核对，**不要只看 CC Switch 卡片上的选中状态**。
