# GLM 接入 Claude Code 配置教程（智谱 GLM-5.2，2026）

> 返回 [Claude Code / Codex 国内使用教程](../README.md) · 最后核对：2026-10-23 · 依据 [智谱开放平台：Claude Code 接入](https://docs.bigmodel.cn/cn/guide/develop/claude)

智谱官方提供 Anthropic 兼容接口，可以在 Claude Code 里使用 GLM 系列模型。智谱主推的是专门给编程工具用的 **GLM Coding Plan**。

## 需要准备

- 已安装 Claude Code（[安装教程](install-claude-code.md)）
- 智谱开放平台的 **Coding Plan Key**

> ⚠️ 智谱的个人套餐、团队套餐和普通 API Key 是**分开管理、不能混用**的。拿普通 API Key 去配 Coding Plan 的用法会失败，反之亦然。

## 配置

写进 `~/.claude/settings.json`（Windows：`%USERPROFILE%\.claude\settings.json`）的 `env`：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://open.bigmodel.cn/api/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "YOUR_ZHIPU_API_KEY",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.7",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-5.2[1m]",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-5.2[1m]",
    "CLAUDE_CODE_AUTO_COMPACT_WINDOW": "1000000",
    "API_TIMEOUT_MS": "3000000",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  }
}
```

可复制的文件：[`configs/claude-code/glm.settings.json`](../configs/claude-code/glm.settings.json)。

- 不设模型变量的话，服务端会把三档都映射到 GLM-4.7。
- `[1m]` 启用 1M 上下文。Claude Code 提示 `[1m]` 模型不存在时，先把 Claude Code 升级到最新版。
- `API_TIMEOUT_MS` 调大超时，适合长任务。

智谱官方还建议在 `~/.claude.json` 里加上 `"hasCompletedOnboarding": true`，跳过首次启动的登录引导。

## 验证

```bash
bash scripts/check-api.sh anthropic https://open.bigmodel.cn/api/anthropic glm-5.2
```

改完**新开一个终端**再启动 Claude Code，输入 `/status` 确认当前模型。

## 想对比 GLM 和其他模型？

- 编程能力对比：[AI 编程模型排行榜](https://orbiorbi.com/leaderboards/code/?utm_source=github&utm_medium=docs&utm_campaign=claude-code-china-guide&utm_content=glm)（每日更新，标注数据来源）
- 不买套餐、按量付费用 GLM 和其他模型：[Orbis 上的 GLM 5.3](https://orbiorbi.com/pricing/glm-5.3?utm_source=github&utm_medium=docs&utm_campaign=claude-code-china-guide&utm_content=glm)（本仓库维护方）

报错排查见 [常见报错排查](troubleshooting.md)。
