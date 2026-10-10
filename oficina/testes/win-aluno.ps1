# Runs AS the standard (non-admin) student account. Mirrors what a participant does.
param([string]$Out, [string]$Variant)
$ErrorActionPreference = 'Continue'
$res = [ordered]@{ os = 'windows'; variant = $Variant; user = $env:USERNAME }
function Save { $res | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 "$Out\result-win-$Variant.json" }

$id = [Security.Principal.WindowsIdentity]::GetCurrent()
$res.is_admin = ([Security.Principal.WindowsPrincipal]$id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$res.exec_policy_effective = "$(Get-ExecutionPolicy)"
$res.ps_version = "$($PSVersionTable.PSVersion)"
# The harness was launched with -ExecutionPolicy Bypass; children must NOT inherit it.
Remove-Item Env:PSExecutionPolicyPreference -ErrorAction SilentlyContinue

function Run([string]$name, [string]$cmdline, [int]$timeoutSec = 600, [string]$shell = 'cmd') {
    $log = "$Out\$Variant-$name.log"
    if ($shell -eq 'cmd') { $fp = 'cmd.exe'; $a = "/d /c $cmdline > `"$log`" 2>&1" }
    else { $fp = 'powershell.exe'; $a = "-NoProfile -Command `"& { $cmdline } *> '$log'`"" }
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $p = Start-Process -FilePath $fp -ArgumentList $a -NoNewWindow -PassThru
    $done = $p.WaitForExit($timeoutSec * 1000)
    if (-not $done) { try { $p.Kill() } catch {} }
    $txt = if (Test-Path $log) { (Get-Content $log -Raw -ErrorAction SilentlyContinue) } else { '' }
    if ($null -eq $txt) { $txt = '' }
    $tail = if ($txt.Length -gt 1500) { $txt.Substring($txt.Length - 1500) } else { $txt }
    $res[$name] = [ordered]@{ exit = $(if ($done) { $p.ExitCode } else { 'TIMEOUT' }); secs = [math]::Round($sw.Elapsed.TotalSeconds); tail = $tail }
    Save
    return $txt
}

# 1. Install exactly from the official URL, as the participant would (PowerShell 5.1, iex-style).
$flags = '-NonInteractive'
if ($Variant -eq 'lean') { $flags = '-NonInteractive -SkipBrowser -SkipComputerUse' }
Run 'install' "`$sb=[scriptblock]::Create((Invoke-RestMethod https://hermes-agent.nousresearch.com/install.ps1)); & `$sb $flags" 2400 'ps' | Out-Null

# New terminal = fresh PATH from the registry (what the participant gets after reopening).
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'User') + ';' + [Environment]::GetEnvironmentVariable('Path', 'Machine')
$res.hermes_resolves = "$((Get-Command hermes -ErrorAction SilentlyContinue).Source)"

Run 'version_cmd' 'hermes --version' 120 | Out-Null
Run 'version_powershell' 'hermes --version' 120 'ps' | Out-Null
Run 'doctor' 'hermes doctor' 300 | Out-Null
Run 'skill_install' 'hermes skills install Rafaelrr5/minds-hermes/skills/minds-boas-vindas --yes' 300 | Out-Null
$list = Run 'skills_list' 'hermes skills list' 120
$res.skill_listed = [bool]($list -match 'minds-boas-vindas')

# 2. Brain (cortex.py, stdlib only) with the Python that Hermes itself brought.
$py = Get-ChildItem "$env:LOCALAPPDATA\hermes" -Recurse -Filter python.exe -ErrorAction SilentlyContinue |
      Where-Object { $_.FullName -match '\\Scripts\\python\.exe$' } | Select-Object -First 1
$res.python = "$($py.FullName)"
if ($py) {
    $cx = "$env:USERPROFILE\cortex.py"
    Invoke-WebRequest https://raw.githubusercontent.com/Rafaelrr5/agent-cortex/main/cortex.py -OutFile $cx -UseBasicParsing
    Run 'brain_add' "`"$($py.FullName)`" `"$cx`" add `"Ana prefere respostas curtas e informais`" --category preference" 120 | Out-Null
    $s = Run 'brain_search' "`"$($py.FullName)`" `"$cx`" search `"respostas curtas`" -n 3" 120
    $res.brain_ok = [bool]($s -match 'Ana prefere')
}
$res.finished = $true
Save
New-Item "$Out\done-$Variant.flag" -ItemType File -Force | Out-Null
