# Runs AS the standard student account on a machine stripped of developer tools.
# Inventory -> preparar.ps1 (as in the guide) -> inventory -> preparar.ps1 again -> checks.
param([string]$Out, [string]$Variant, [string]$Ref = 'oficina-testes')
$ErrorActionPreference = 'Continue'
$res = [ordered]@{ os = 'windows'; variant = $Variant; user = $env:USERNAME }
function Save { $res | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 "$Out\result-win-$Variant.json" }
$res.is_admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Remove-Item Env:PSExecutionPolicyPreference -ErrorAction SilentlyContinue

function Run([string]$name, [string]$cmdline, [int]$timeoutSec = 600, [string]$shell = 'cmd') {
    $log = "$Out\$Variant-$name.log"
    if ($shell -eq 'cmd') { $fp = 'cmd.exe'; $a = "/d /s /c `"$cmdline > `"$log`" 2>&1`"" }
    else { $fp = 'powershell.exe'; $a = "-NoProfile -Command `"& { $cmdline } *> '$log'`"" }
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $p = Start-Process -FilePath $fp -ArgumentList $a -NoNewWindow -PassThru
    $null = $p.Handle
    $done = $p.WaitForExit($timeoutSec * 1000)
    if (-not $done) { try { $p.Kill() } catch {} }
    $txt = ''; if (Test-Path $log) { $txt = [string](Get-Content $log -Raw -ErrorAction SilentlyContinue) }
    $tail = if ($txt.Length -gt 1500) { $txt.Substring($txt.Length - 1500) } else { $txt }
    $res[$name] = [ordered]@{ exit = $(if ($done) { $p.ExitCode } else { 'TIMEOUT' }); secs = [math]::Round($sw.Elapsed.TotalSeconds); tail = $tail }
    Save
    return $txt
}
function Rx { try { (Get-NetAdapterStatistics -ErrorAction Stop | Measure-Object ReceivedBytes -Sum).Sum } catch { $null } }

$inv = 'where git & where python & where python3 & where node & where cargo & where rustc & echo PATH=%PATH%'
Run 'inventario_antes' $inv 60 | Out-Null
$res.user_path_antes = [Environment]::GetEnvironmentVariable('Path', 'User')

$url = "https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/$Ref/oficina/preparar.ps1"
$r0 = Rx
$t = Run 'preparar_1' "irm $url | iex" 2400 'ps'
$r1 = Rx
$res.preparar_1_ok = [bool]($t -match 'Pronto:')
$res.preparar_1_download_mb = if ($r0 -and $r1) { [math]::Round(($r1 - $r0) / 1MB) } else { 'n/a' }

$res.user_path_depois = [Environment]::GetEnvironmentVariable('Path', 'User')
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'User') + ';' + [Environment]::GetEnvironmentVariable('Path', 'Machine')
Run 'inventario_depois' $inv 60 | Out-Null

$t = Run 'preparar_2' "irm $url | iex" 600 'ps'
$r2 = Rx
$res.preparar_2_pulou = [bool]($t -match 'Nada para fazer')
$res.preparar_2_download_mb = if ($r1 -and $r2) { [math]::Round(($r2 - $r1) / 1MB, 1) } else { 'n/a' }

Run 'version' 'hermes --version' 120 | Out-Null
$raw = "https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/$Ref/skills"
Run 'skill_install' "hermes skills install $raw/minds-boas-vindas/SKILL.md --yes" 300 | Out-Null
Run 'skill_install_cerebro' "hermes skills install $raw/minds-cerebro/SKILL.md --yes" 300 | Out-Null
$list = Run 'skills_list' 'hermes skills list' 120
$res.skill_listed = [bool]($list -match 'minds-boas-vindas')
$res.cerebro_listed = [bool]($list -match 'minds-cerebro')
$py = Get-ChildItem "$env:LOCALAPPDATA\hermes\installs" -Recurse -Filter python.exe -ErrorAction SilentlyContinue |
      Where-Object { $_.FullName -match '\\venv\\Scripts\\python\.exe$' } | Select-Object -First 1
if ($py) {
    Invoke-WebRequest "$raw/minds-cerebro/SKILL.md" -OutFile "$env:USERPROFILE\sk.md" -UseBasicParsing
    Invoke-WebRequest "https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/$Ref/oficina/testes/testa_cerebro.py" -OutFile "$env:USERPROFILE\tc.py" -UseBasicParsing
    $s = Run 'brain' "`"$($py.FullName)`" `"$env:USERPROFILE\tc.py`" `"$env:USERPROFILE\sk.md`" $Ref" 180
    $res.brain_ok = [bool]($s -match 'CEREBRO_OK')
}
$res.finished = $true
Save
New-Item "$Out\done-$Variant.flag" -ItemType File -Force | Out-Null
