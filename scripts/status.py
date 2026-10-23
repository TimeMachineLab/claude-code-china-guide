"""接口在线状态检测：不带 Key 请求各服务商的 Anthropic 兼容接口，更新 README 里的状态表。

判断规则：
  返回 401 / 403（没带 Key 被拒）、400 / 422（参数被拒）、429（限速）→ 服务在线
  返回网页而不是 API 响应、404                                      → 路径异常
  超时、连不上、5xx                                                → 异常
每个接口失败时最多重试 3 次，避免偶发网络抖动造成误报。
只有状态变化时才改写 data/status.json 和 README，没变化就不产生提交。

用法：python scripts/status.py      只用 Python 标准库。MIT License.
"""
import datetime
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(ROOT, "data", "status.json")
README = os.path.join(ROOT, "README.md")

PROVIDERS = [
    ("DeepSeek 官方", "https://api.deepseek.com/anthropic"),
    ("Kimi 官方", "https://api.moonshot.cn/anthropic"),
    ("智谱 GLM 官方", "https://open.bigmodel.cn/api/anthropic"),
    ("Orbis", "https://api.orbiorbi.com"),
]
BODY = json.dumps({"model": "status-check", "max_tokens": 1,
                   "messages": [{"role": "user", "content": "hi"}]}).encode()
LABEL = {"up": "✅ 在线", "path": "⚠️ 路径异常", "down": "❌ 异常"}


def probe_once(base):
    req = urllib.request.Request(
        base + "/v1/messages", data=BODY, method="POST",
        headers={"content-type": "application/json", "anthropic-version": "2023-06-01",
                 "user-agent": "claude-code-china-guide-status/1.0"})
    try:
        with urllib.request.urlopen(req, timeout=20) as r:
            code, text = r.status, r.read(300).decode("utf-8", "replace")
    except urllib.error.HTTPError as e:
        code, text = e.code, e.read(300).decode("utf-8", "replace")
    except Exception as e:  # 超时、DNS、TLS 等
        return "down", f"连接失败：{type(e).__name__}"
    if re.match(r"\s*<(!doctype|html)", text, re.I):
        return "path", f"HTTP {code}，返回的是网页"
    if code in (400, 401, 403, 422, 429):
        return "up", f"HTTP {code}"
    if code == 404:
        return "path", "HTTP 404"
    return "down", f"HTTP {code}"


def probe(base):
    for attempt in range(3):
        state, detail = probe_once(base)
        if state == "up":
            return state, detail
        time.sleep(5 * (attempt + 1))
    return state, detail


def render(data):
    rows = ["| 服务商 | Claude Code 接入地址 | 状态 | 状态变化时间（北京时间） |", "|---|---|:---:|---|"]
    for name, base in PROVIDERS:
        s = data[name]
        rows.append(f"| {name} | `{base}` | {LABEL[s['state']]} | {s['since']} |")
    rows.append("")
    rows.append("> 每天由 GitHub Actions 自动检测一次（不带 Key 发一个最小请求，收到「未授权」即说明服务在线）。"
                "检测服务器在海外，**只代表服务本身在线，不代表国内网络能直连**。"
                "运行记录见 [Actions](../../actions/workflows/status.yml)。")
    return "\n".join(rows)


def main():
    now = datetime.datetime.now(datetime.timezone(datetime.timedelta(hours=8))).strftime("%Y-%m-%d %H:%M")
    old = json.load(open(DATA, encoding="utf-8")) if os.path.exists(DATA) else {}
    new, changed = {}, False
    for name, base in PROVIDERS:
        state, detail = probe(base)
        print(f"{name:12} {state:5} {detail}")
        prev = old.get(name)
        if prev and prev["state"] == state:
            new[name] = prev
        else:
            new[name] = {"state": state, "since": now, "detail": detail}
            changed = True
    if not changed and set(old) == set(new):
        print("状态没有变化")
        return
    os.makedirs(os.path.dirname(DATA), exist_ok=True)
    json.dump(new, open(DATA, "w", encoding="utf-8", newline="\n"), ensure_ascii=False, indent=1)
    text = open(README, encoding="utf-8").read()
    text, n = re.subn(r"(<!-- BEGIN:status -->\r?\n).*?(<!-- END:status -->)",
                      lambda m: m.group(1) + render(new) + "\n" + m.group(2), text, flags=re.S)
    if n != 1:
        sys.exit("README.md 里没有找到唯一的 BEGIN/END:status 标记")
    open(README, "w", encoding="utf-8", newline="\n").write(text)
    print("已更新 README 状态表")


if __name__ == "__main__":
    main()
