#!/usr/bin/env bash
# check-api.sh: 发一条最小请求，检测「地址 + Key + 模型」是否接通，并把 HTTP 状态翻译成人话。
#
# 用法：
#   bash scripts/check-api.sh <协议> <地址> <模型ID>
#
#   协议 anthropic  Claude Code 用的 Anthropic Messages。地址写根地址，不带 /v1
#                   例：bash scripts/check-api.sh anthropic https://api.deepseek.com/anthropic deepseek-flash
#   协议 responses  Codex 用的 OpenAI Responses。地址带 /v1
#                   例：bash scripts/check-api.sh responses https://api.orbiorbi.com/v1 gpt-6.1-sol
#   协议 chat       WorkBuddy 等工具用的 OpenAI Chat Completions。地址带 /v1
#                   例：bash scripts/check-api.sh chat https://api.deepseek.com/v1 deepseek-flash
#
# Key：优先读取环境变量 API_KEY；没有的话会提示你粘贴（输入不显示，不进命令历史）。
# 这条请求会消耗极少量额度（最多 32 个输出 token）。
# https://github.com/TimeMachineLab/claude-code-china-guide  ·  MIT License

set -u

proto="${1:-}"
base="${2:-}"
model="${3:-}"

if [ -z "$proto" ] || [ -z "$base" ] || [ -z "$model" ]; then
  sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
fi

command -v curl >/dev/null 2>&1 || { echo "需要 curl，请先安装。" >&2; exit 2; }

warn() { printf '⚠ %s\n' "$1" >&2; }

base="${base%/}"
case "$model" in
  *"[1m]")
    model="${model%\[1m\]}"
    warn "已去掉模型名末尾的 [1m]：这是 Claude Code 的写法，接口本身只认 ${model}。"
    ;;
esac

key="${API_KEY:-}"
if [ -z "$key" ]; then
  printf '粘贴 API Key（输入不显示）：' >&2
  IFS= read -rs key
  printf '\n' >&2
fi
[ -n "$key" ] || { echo "没有拿到 Key。" >&2; exit 2; }

prompt='Reply with only OK.'
case "$proto" in
  anthropic)
    case "$base" in
      */v1) warn "Anthropic 协议（Claude Code）的地址末尾一般不带 /v1，脚本会请求 ${base}/v1/messages，很可能 404。" ;;
    esac
    url="${base}/v1/messages"
    body="{\"model\":\"${model}\",\"max_tokens\":32,\"messages\":[{\"role\":\"user\",\"content\":\"${prompt}\"}]}"
    ;;
  responses)
    case "$base" in
      */v1) ;;
      *) warn "OpenAI 协议（Codex）的地址通常以 /v1 结尾，你填的是 ${base}。" ;;
    esac
    url="${base}/responses"
    body="{\"model\":\"${model}\",\"input\":\"${prompt}\",\"max_output_tokens\":32}"
    ;;
  chat)
    case "$base" in
      */chat/completions) base="${base%/chat/completions}" ;;
      */v1) ;;
      *) warn "OpenAI 协议的地址通常以 /v1 结尾，你填的是 ${base}。" ;;
    esac
    url="${base}/chat/completions"
    body="{\"model\":\"${model}\",\"max_tokens\":32,\"messages\":[{\"role\":\"user\",\"content\":\"${prompt}\"}]}"
    ;;
  *)
    echo "协议只能是 anthropic、responses 或 chat。" >&2
    exit 2
    ;;
esac

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
chmod 700 "$tmpdir"
# Key 写进临时请求头文件，避免出现在进程列表里
{
  printf 'Authorization: Bearer %s\n' "$key"
  if [ "$proto" = anthropic ]; then
    printf 'x-api-key: %s\n' "$key"
    printf 'anthropic-version: 2023-06-01\n'
  fi
  printf 'Content-Type: application/json\n'
} > "$tmpdir/headers"

printf '→ POST %s  (model: %s)\n' "$url" "$model"

code="$(curl -sS -m 60 -o "$tmpdir/body" -w '%{http_code}' \
  -H @"$tmpdir/headers" --data "$body" "$url" 2>"$tmpdir/err")"
resp="$(cat "$tmpdir/body" 2>/dev/null)"
msg="$(printf '%s' "$resp" | grep -o '"message" *: *"[^"]*"' | head -n 1 | sed 's/^"message" *: *"//; s/"$//')"

# 有的网站对任何路径都返回网页（HTTP 200），这说明请求根本没打到 API 上
if [ "$code" = 200 ] && printf '%s' "$resp" | head -c 200 | grep -qi '<!doctype\|<html'; then
  echo "✗ HTTP 200，但返回的是网页而不是 API 响应：地址路径不对，请求打到了网站上。"
  echo "  Claude Code（anthropic）地址不带 /v1；Codex 和 chat 地址要带 /v1。对照服务商文档里的 API 地址（常常是 api. 开头的域名）。"
  exit 1
fi

case "$code" in
  200)
    reply="$(printf '%s' "$resp" | grep -o '"\(text\|content\)" *: *"[^"]*"' | head -n 1 | sed 's/^"[a-z]*" *: *//')"
    printf '✓ HTTP 200：接通了。模型回复：%s\n' "${reply:-（未解析到文本，原始响应前 200 字：${resp:0:200}）}"
    echo "  下一步：在工具里输入 /status 核对配置，并到服务商的调用日志确认实际模型和扣费。"
    exit 0
    ;;
  000)
    echo "✗ 没有收到响应：网络不通、超时或域名写错。"
    echo "  curl 报错：$(cat "$tmpdir/err")"
    ;;
  401|403)
    echo "✗ HTTP ${code}：Key 无效、已停用或没有权限。重新复制完整 Key，确认它属于这个服务商 / 这条线路。"
    ;;
  404)
    echo "✗ HTTP 404：地址路径不对，或模型不存在。"
    echo "  Claude Code（anthropic）地址不带 /v1；Codex 和 chat 地址要带 /v1。模型 ID 要和服务商列表完全一致。"
    ;;
  400|422)
    echo "✗ HTTP ${code}：请求被拒绝。最常见的是模型 ID 不对，或这个模型要求特定参数（比如必须开启思考）。"
    ;;
  402|429)
    echo "✗ HTTP ${code}：余额不足、额度用完或触发限速。检查账户余额和 Key 的额度设置。"
    ;;
  5*)
    echo "✗ HTTP ${code}：服务商那边出错了。稍后重试；持续出现就联系服务商，附上下面的报错。"
    ;;
  *)
    echo "✗ HTTP ${code}：未归类的状态。"
    ;;
esac

[ -n "$msg" ] && printf '  服务商返回：%s\n' "$msg"
[ -z "$msg" ] && [ -n "$resp" ] && printf '  原始响应前 200 字：%s\n' "${resp:0:200}"
exit 1
