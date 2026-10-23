<#
check-api.ps1: 发一条最小请求，检测「地址 + Key + 模型」是否接通，并把 HTTP 状态翻译成人话。
适用于 Windows PowerShell 5.1 和 PowerShell 7。

用法：
  powershell -ExecutionPolicy Bypass -File scripts\check-api.ps1 <协议> <地址> <模型ID>

  协议 anthropic  Claude Code 用的 Anthropic Messages。地址写根地址，不带 /v1
                  例：... check-api.ps1 anthropic https://api.moonshot.cn/anthropic kimi-k3
  协议 responses  Codex 用的 OpenAI Responses。地址带 /v1
                  例：... check-api.ps1 responses https://api.orbiorbi.com/v1 gpt-6.1-sol
  协议 chat       WorkBuddy 等工具用的 OpenAI Chat Completions。地址带 /v1
                  例：... check-api.ps1 chat https://api.deepseek.com/v1 deepseek-flash

Key：优先读取环境变量 API_KEY；没有的话会提示你粘贴（输入不显示）。
这条请求会消耗极少量额度（最多 32 个输出 token）。
https://github.com/TimeMachineLab/claude-code-china-guide  ·  MIT License
#>
param(
    [Parameter(Position = 0)][string]$Protocol,
    [Parameter(Position = 1)][string]$BaseUrl,
    [Parameter(Position = 2)][string]$Model
)

$ErrorActionPreference = 'Stop'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

function Warn([string]$text) { Write-Host "⚠ $text" -ForegroundColor Yellow }

if (-not $Protocol -or -not $BaseUrl -or -not $Model) {
    (Get-Content -Path $PSCommandPath -Encoding UTF8 -TotalCount 17 | Select-Object -Skip 1) -join "`n" | Write-Host
    exit 2
}

$BaseUrl = $BaseUrl.TrimEnd('/')
if ($Model.EndsWith('[1m]')) {
    $Model = $Model.Substring(0, $Model.Length - 4)
    Warn "已去掉模型名末尾的 [1m]：这是 Claude Code 的写法，接口本身只认 $Model。"
}

$key = $env:API_KEY
if (-not $key) {
    $secure = Read-Host '粘贴 API Key（输入不显示）' -AsSecureString
    $key = [System.Net.NetworkCredential]::new('', $secure).Password
}
if (-not $key) { Write-Host '没有拿到 Key。'; exit 2 }

$prompt = 'Reply with only OK.'
$headers = @{ 'Authorization' = "Bearer $key" }

switch ($Protocol) {
    'anthropic' {
        if ($BaseUrl.EndsWith('/v1')) { Warn "Anthropic 协议（Claude Code）的地址末尾一般不带 /v1，脚本会请求 $BaseUrl/v1/messages，很可能 404。" }
        $url = "$BaseUrl/v1/messages"
        $headers['x-api-key'] = $key
        $headers['anthropic-version'] = '2023-06-01'
        $body = @{ model = $Model; max_tokens = 32; messages = @(@{ role = 'user'; content = $prompt }) }
    }
    'responses' {
        if (-not $BaseUrl.EndsWith('/v1')) { Warn "OpenAI 协议（Codex）的地址通常以 /v1 结尾，你填的是 $BaseUrl。" }
        $url = "$BaseUrl/responses"
        $body = @{ model = $Model; input = $prompt; max_output_tokens = 32 }
    }
    'chat' {
        if ($BaseUrl.EndsWith('/chat/completions')) { $BaseUrl = $BaseUrl.Substring(0, $BaseUrl.Length - 17) }
        elseif (-not $BaseUrl.EndsWith('/v1')) { Warn "OpenAI 协议的地址通常以 /v1 结尾，你填的是 $BaseUrl。" }
        $url = "$BaseUrl/chat/completions"
        $body = @{ model = $Model; max_tokens = 32; messages = @(@{ role = 'user'; content = $prompt }) }
    }
    default { Write-Host '协议只能是 anthropic、responses 或 chat。'; exit 2 }
}

$bytes = [Text.Encoding]::UTF8.GetBytes(($body | ConvertTo-Json -Depth 5 -Compress))
Write-Host "→ POST $url  (model: $Model)"

$code = 0
$resp = ''
try {
    $r = Invoke-WebRequest -Uri $url -Method Post -Headers $headers -ContentType 'application/json' `
        -Body $bytes -TimeoutSec 60 -UseBasicParsing
    $code = [int]$r.StatusCode
    $resp = [string]$r.Content
} catch {
    $ex = $_.Exception
    if ($ex.Response) {
        $code = [int]$ex.Response.StatusCode
        if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
            $resp = $_.ErrorDetails.Message
        } elseif ($ex.Response.GetResponseStream) {
            try { $resp = (New-Object IO.StreamReader($ex.Response.GetResponseStream())).ReadToEnd() } catch {}
        }
    } else {
        Write-Host '✗ 没有收到响应：网络不通、超时或域名写错。'
        Write-Host "  报错：$($ex.Message)"
        exit 1
    }
}

$msg = ''
$text = ''
try {
    $json = $resp | ConvertFrom-Json
    if ($json.error -and $json.error.message) { $msg = $json.error.message }
    elseif ($json.message) { $msg = $json.message }
    if ($json.content) { $text = ($json.content | Where-Object { $_.type -eq 'text' } | Select-Object -First 1).text }
    elseif ($json.choices) { $text = $json.choices[0].message.content }
    elseif ($json.output) {
        $text = ($json.output | ForEach-Object { $_.content } | Where-Object { $_.text } | Select-Object -First 1).text
    }
} catch {}

$snippet = if ($resp.Length -gt 200) { $resp.Substring(0, 200) } else { $resp }

if ($code -eq 200 -and $resp -match '^\s*<(!doctype|html)') {
    Write-Host '✗ HTTP 200，但返回的是网页而不是 API 响应：地址路径不对，请求打到了网站上。'
    Write-Host '  Claude Code（anthropic）地址不带 /v1；Codex 和 chat 地址要带 /v1。对照服务商文档里的 API 地址（常常是 api. 开头的域名）。'
    exit 1
}

switch -Regex ([string]$code) {
    '^200$' {
        if (-not $text) { $text = "（未解析到文本，原始响应前 200 字：$snippet）" }
        Write-Host "✓ HTTP 200：接通了。模型回复：$text" -ForegroundColor Green
        Write-Host '  下一步：在工具里输入 /status 核对配置，并到服务商的调用日志确认实际模型和扣费。'
        exit 0
    }
    '^(401|403)$' { Write-Host "✗ HTTP ${code}：Key 无效、已停用或没有权限。重新复制完整 Key，确认它属于这个服务商 / 这条线路。" -ForegroundColor Red }
    '^404$' {
        Write-Host '✗ HTTP 404：地址路径不对，或模型不存在。' -ForegroundColor Red
        Write-Host '  Claude Code（anthropic）地址不带 /v1；Codex 和 chat 地址要带 /v1。模型 ID 要和服务商列表完全一致。'
    }
    '^(400|422)$' { Write-Host "✗ HTTP ${code}：请求被拒绝。最常见的是模型 ID 不对，或这个模型要求特定参数（比如必须开启思考）。" -ForegroundColor Red }
    '^(402|429)$' { Write-Host "✗ HTTP ${code}：余额不足、额度用完或触发限速。检查账户余额和 Key 的额度设置。" -ForegroundColor Red }
    '^5' { Write-Host "✗ HTTP ${code}：服务商那边出错了。稍后重试；持续出现就联系服务商，附上下面的报错。" -ForegroundColor Red }
    default { Write-Host "✗ HTTP ${code}：未归类的状态。" -ForegroundColor Red }
}

if ($msg) { Write-Host "  服务商返回：$msg" }
elseif ($snippet) { Write-Host "  原始响应前 200 字：$snippet" }
exit 1
