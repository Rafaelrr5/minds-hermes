# Runs AS the standard (non-admin) student account. Mirrors what a participant does.
param([string]$Out, [string]$Variant, [string]$Ref = 'oficina-testes')
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
    if ($shell -eq 'cmd') { $fp = 'cmd.exe'; $a = "/d /s /c `"$cmdline > `"$log`" 2>&1`"" }
    else { $fp = 'powershell.exe'; $a = "-NoProfile -Command `"& { $cmdline } *> '$log'`"" }
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $p = Start-Process -FilePath $fp -ArgumentList $a -NoNewWindow -PassThru
    $null = $p.Handle   # cache the handle, otherwise ExitCode comes back empty
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
Run 'child_policy' 'Get-ExecutionPolicy' 60 'ps' | Out-Null

# Classroom simulation: 20 people behind one IP burn GitHub's 60 req/h anonymous quota.
1..65 | ForEach-Object { try { Invoke-WebRequest https://api.github.com/repos/Rafaelrr5/minds-hermes -UseBasicParsing | Out-Null } catch {} }
try { Invoke-WebRequest https://api.github.com/repos/Rafaelrr5/minds-hermes -UseBasicParsing | Out-Null; $res.api_quota_exhausted = $false } catch { $res.api_quota_exhausted = $true }

$raw = "https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/$Ref/skills"
Run 'skill_install_shortcut' 'hermes skills install Rafaelrr5/minds-hermes/skills/minds-boas-vindas --yes' 300 | Out-Null
Run 'skill_install' "hermes skills install $raw/minds-boas-vindas/SKILL.md --yes" 300 | Out-Null
Run 'skill_install_cerebro' "hermes skills install $raw/minds-cerebro/SKILL.md --yes" 300 | Out-Null
$list = Run 'skills_list' 'hermes skills list' 120
$res.skill_listed = [bool]($list -match 'minds-boas-vindas')
$res.cerebro_listed = [bool]($list -match 'minds-cerebro')

# Brain: run the skill's own code block with the Python Hermes brought (as execute_code does).
$py = Get-ChildItem "$env:LOCALAPPDATA\hermes\installs" -Recurse -Filter python.exe -ErrorAction SilentlyContinue |
      Where-Object { $_.FullName -match '\\venv\\Scripts\\python\.exe$' } | Select-Object -First 1
$res.python = "$($py.FullName)"
if ($py) {
    $sk = "$env:USERPROFILE\minds-cerebro-SKILL.md"
    Invoke-WebRequest "$raw/minds-cerebro/SKILL.md" -OutFile $sk -UseBasicParsing
    Invoke-WebRequest "https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/$Ref/oficina/testes/testa_cerebro.py" -OutFile "$env:USERPROFILE\testa_cerebro.py" -UseBasicParsing
    $s = Run 'brain' "`"$($py.FullName)`" `"$env:USERPROFILE\testa_cerebro.py`" `"$sk`" $Ref" 180
    $res.brain_ok = [bool]($s -match 'CEREBRO_OK')
}
$res.finished = $true
Save
New-Item "$Out\done-$Variant.flag" -ItemType File -Force | Out-Null
