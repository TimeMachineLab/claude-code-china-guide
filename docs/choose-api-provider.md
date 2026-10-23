# Claude Code API 中转站怎么选？靠谱性检查清单（2026）

> 返回 [Claude Code / Codex 国内使用教程](../README.md) · 最后核对：2026-10-23

「中转站」「API 聚合平台」指的是：一个账户、一个接口，就能调用多家厂商的模型，通常支持人民币付款。它解决了支付和网络的麻烦，但质量差别非常大。下面这份清单帮你在充值前把风险筛一遍。

> 披露：本仓库由 [Orbis](https://orbiorbi.com/?utm_source=github&utm_medium=docs&utm_campaign=claude-code-china-guide&utm_content=choose-provider) 团队维护，Orbis 也是一家聚合平台。下面的标准对所有平台（包括 Orbis）一视同仁，请用它来检验任何一家。

## 先想清楚：你真的需要中转站吗？

| 你的需求 | 更合适的选择 |
|---|---|
| 只用 DeepSeek / Kimi / GLM 中的一家 | **直接用官方接口**，最稳也最便宜（[DeepSeek](deepseek-claude-code.md) · [Kimi](kimi-k3-claude-code.md) · [GLM](glm-claude-code.md)） |
| 想在多家模型之间切换，不想注册一堆账号 | 聚合平台 |
| 需要 Claude、GPT 等海外模型，又没有海外支付方式 | 聚合平台，但要自行评估服务条款与合规风险 |

## 10 项检查清单

**模型真不真**

1. **调用日志能看到实际模型**：控制台的日志里要能看到每次请求用的模型、token 数、扣费。看不到的，没法核对。
2. **自己做一次真伪测试**：问一些只有新版本才知道的事，或对比官方的输出风格和速度；社区有开源的检测脚本，比如 [awesome-ai-gateway 的 canary_check.py](https://github.com/cuihuan/awesome-ai-gateway)。
3. **价格低得离谱要警惕**：远低于官方价的，常见原因是拼车账号、逆向网页接口、偷换便宜模型。这类服务随时可能断。

**钱安不安全**

4. **价格公开透明**：每个模型、每条线路的输入 / 输出 / 缓存单价都写清楚，不用私聊问价。
5. **能小额按量付费**：先充一点试用，不被大额套餐绑住。
6. **余额规则写清楚**：会不会过期、能不能退。

**能不能长期用**

7. **有文档、有工单或社群**：出了问题有地方找人。
8. **Key 可以单独设额度、有效期、模型限制**：泄露时损失可控。
9. **协议支持完整**：Claude Code 需要 Anthropic Messages，Codex 需要 OpenAI Responses，并且都要支持流式输出和工具调用。用本仓库的 [`check-api` 脚本](../scripts/) 实测，而不是只看宣传。
10. **有一定运营时间和公开记录**：可以在社区列表里查它的口碑，比如 [awesome-ai-gateway](https://github.com/cuihuan/awesome-ai-gateway)、[awesome-ai-api-proxy](https://github.com/howardpen9/awesome-ai-api-proxy)。

## 用 Key 的安全习惯

- 每个工具、每个项目用**单独的 Key**，方便单独停用
- 不要把 Key 发到群聊、截图，或提交到 Git 仓库（检查 `settings.json` 有没有被提交）
- `ccswitch://` 之类的一键导入链接里通常带着 Key，同样要保密
- 怀疑泄露：**立刻停用旧 Key**，新建一个，再去调用日志里查异常请求

## 用 Orbis 对照这份清单

如果你在考虑 Orbis，可以这样逐项核对：

- 价格：[模型广场](https://orbiorbi.com/pricing?utm_source=github&utm_medium=docs&utm_campaign=claude-code-china-guide&utm_content=choose-provider-check)公开了每条线路的单价
- 计费：人民币按量计费
- Key：可以设置额度、有效期、模型限制和 IP 白名单（见 [API Key 管理文档](https://orbiorbi.com/docs/api-keys/?utm_source=github&utm_medium=docs&utm_campaign=claude-code-china-guide&utm_content=choose-provider-check)）
- 日志：控制台的使用日志会显示每次请求的模型、线路和扣费
- 协议：同时提供 Anthropic Messages、OpenAI Responses 和 Chat Completions 线路

其余几项（模型真伪、稳定性）请用上面的方法自己测，不要只信任何一家的说法。
