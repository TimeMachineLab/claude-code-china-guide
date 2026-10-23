# Claude Code 安装教程（Windows / macOS / Linux，2026）

> 返回 [Claude Code / Codex 国内使用教程](../README.md) · 最后核对：2026-10-23 · 依据 [Claude Code 官方安装文档](https://code.claude.com/docs/en/setup)

Claude Code 是 Anthropic 出的命令行 AI 编程工具，装在本机终端里运行。这篇讲清楚三种系统怎么装、装完怎么验证，以及国内最常遇到的安装问题。**安装本身不需要 Claude 账号**，装好后可以接 DeepSeek、Kimi、GLM 或其他兼容服务。

## 系统要求

- macOS 13+、Windows 10 1809+、Ubuntu 20.04+、Debian 10+、Alpine 3.19+
- 4 GB 以上内存，x64 或 ARM64 处理器
- 用 npm 安装时需要 Node.js 22+（原生安装不需要 Node.js）

## macOS / Linux / WSL

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

装完**打开一个新终端**，运行：

```bash
claude --version
```

能打印出类似 `2.1.xxx (Claude Code)` 的版本号就成功了。原生安装会在后台自动更新。

macOS 也可以用 Homebrew：`brew install --cask claude-code`（不会自动更新，需要 `brew upgrade claude-code`）。

## Windows

在 **PowerShell**（提示符是 `PS C:\...>`）里运行：

```powershell
irm https://claude.ai/install.ps1 | iex
```

如果你在 **CMD**（提示符是 `C:\...>`，没有 `PS`）里：

```batch
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```

也可以用 WinGet：`winget install Anthropic.ClaudeCode`。

**建议装上 [Git for Windows](https://git-scm.com/downloads/win)**：有了 Git Bash，Claude Code 才能用 Bash 工具执行命令；没有的话会退回用 PowerShell。如果 Claude Code 找不到 Git Bash，在 `settings.json` 里指定路径：

```json
{
  "env": {
    "CLAUDE_CODE_GIT_BASH_PATH": "C:\\Program Files\\Git\\bin\\bash.exe"
  }
}
```

## 用 npm 安装（备选）

```bash
npm install -g @anthropic-ai/claude-code
```

国内下载慢可以加镜像：

```bash
npm install -g @anthropic-ai/claude-code --registry=https://registry.npmmirror.com
```

- 不要用 `sudo npm install -g`，容易产生权限问题。
- 升级用 `npm install -g @anthropic-ai/claude-code@latest`，不要用 `npm update -g`。

## 安装常见问题

| 现象 | 原因 | 处理 |
|---|---|---|
| `claude: command not found` / 不是内部或外部命令 | 安装目录没加进 PATH，或者没开新终端 | 先开一个新终端再试；还不行就把 `~/.local/bin`（Windows 是 `%USERPROFILE%\.local\bin`）加进 PATH |
| `The token '&&' is not a valid statement separator` | 在 PowerShell 里运行了 CMD 的命令 | 改用 PowerShell 那行命令 |
| `'irm' is not recognized` | 在 CMD 里运行了 PowerShell 的命令 | 改用 CMD 那行命令 |
| 安装脚本下载失败、超时、`403` | 网络访问 `claude.ai` 不稳定 | 改用 npm + 国内镜像安装 |
| 装了两个版本，`claude --version` 不是最新 | npm 版和原生版同时存在 | 用 `claude doctor` 查看安装诊断，卸掉其中一个 |

`claude doctor` 会输出只读的安装诊断：安装是否健康、设置文件有没有语法错误、更新状态。遇到奇怪的问题先跑它。

## 下一步

装好之后，`claude` 默认会要求登录 Claude 账号。在国内更常见的做法是**接入其他 API**，跳过登录：

- [Claude Code 接入第三方 API / 中转站（通用教程）](claude-code-third-party-api.md)
- [DeepSeek 接入 Claude Code](deepseek-claude-code.md) · [Kimi K3 接入 Claude Code](kimi-k3-claude-code.md) · [GLM 接入 Claude Code](glm-claude-code.md)

想用一个 Key 同时调用 Claude、GPT、Gemini 和国产模型，可以看 [Orbis 的 Claude Code 接入文档](https://orbiorbi.com/docs/claude-code/?utm_source=github&utm_medium=docs&utm_campaign=claude-code-china-guide&utm_content=install-next)（本仓库维护方）。
