# Claude Code 配置模板（settings.json）

把对应文件里的 `env` **合并**进 `~/.claude/settings.json`（Windows：`%USERPROFILE%\.claude\settings.json`），把 `YOUR_..._API_KEY` 换成你的 Key，然后重启 Claude Code 并输入 `/status` 核对。

| 文件 | 服务商 | 教程 |
|---|---|---|
| [deepseek.settings.json](deepseek.settings.json) | DeepSeek 官方 | [DeepSeek 接入 Claude Code](../../docs/deepseek-claude-code.md) |
| [kimi.settings.json](kimi.settings.json) | Kimi 官方 | [Kimi K3 接入 Claude Code](../../docs/kimi-k3-claude-code.md) |
| [glm.settings.json](glm.settings.json) | 智谱 GLM 官方 | [GLM 接入 Claude Code](../../docs/glm-claude-code.md) |
| [orbis.settings.json](orbis.settings.json) | Orbis | [通用教程](../../docs/claude-code-third-party-api.md#示例接入-orbis) |

- `orbis.settings.json` 故意没写 Key：Orbis 推荐在终端里临时输入 Key（`ANTHROPIC_AUTH_TOKEN`），见[Key 不落盘的写法](../../docs/claude-code-third-party-api.md#更安全的做法key-不落盘)。模型 ID 以 Orbis 控制台接入页显示的为准。
- 写了 Key 的 `settings.json` **不要提交到 Git**。
