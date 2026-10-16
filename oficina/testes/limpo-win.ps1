# Runs AS the standard student account on a machine stripped of developer tools.
# inventory -> preparar.ps1 as in the guide (CONTA set, login capped) -> preparar.ps1 again
# with no account (must finish alone and install nothing) -> independent checks.
# ASCII-only markers: Windows PowerShell 5.1 reads this BOM-less file as ANSI.
param([string]$Out, [string]$Variant, [string]$Ref = 'oficina-testes', [string]$Conta = 'chatgpt')
$ErrorActionPreference = 'Continue'
$res = [ordered]@{ os = 'windows'; variant = $Variant; user = $env:USERNAME }
function Save { $res | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 "$Out\result-win-$Variant.json" }
$res.is_admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Remove-Item Env:PSExecutionPolicyPreference -ErrorAction SilentlyContinue

function Run([string]$name, [string]$cmdline, [int]$timeoutSec = 600, [string]$shell = 'cmd') {
    $log = "$Out\$Variant-$name.log"
    if ($shell -eq 'cmd') { $fp = 'cmd.exe'; $a = "/d /s /c `"$cmdline > `"$log`" 2>&1`"" }
    else { $fp = 'powershell.exe'; $a = "-NoProfile -Command `"& { $cmdline } *>&1 | Out-File -Encoding utf8 '$log'`"" }
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $p = Start-Process -FilePath $fp -ArgumentList $a -NoNewWindow -PassThru
    $null = $p.Handle
    $done = $p.WaitForExit($timeoutSec * 1000)
    if (-not $done) { try { $p.Kill() } catch {} }
    $txt = ''; if (Test-Path $log) { $txt = [string](Get-Content $log -Raw -Encoding UTF8 -ErrorAction SilentlyContinue) }
    $tail = if ($txt.Length -gt 1500) { $txt.Substring($txt.Length - 1500) } else { $txt }
    $res[$name] = [ordered]@{ exit = $(if ($done) { $p.ExitCode } else { 'TIMEOUT' }); secs = [math]::Round($sw.Elapsed.TotalSeconds); tail = $tail }
    Save
    return $txt
}
function Rx { try { (Get-NetAdapterStatistics -ErrorAction Stop | Measure-Object ReceivedBytes -Sum).Sum } catch { $null } }

$inv = '(where git & where python & where python3 & where node & where cargo & where rustc & echo PATH=%PATH%)'
Run 'inventario_antes' $inv 60 | Out-Null

$url = "https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/$Ref/oficina/preparar.ps1"
$env:PREPARAR_REF = $Ref
$r0 = Rx
$env:CONTA = $Conta; $env:PREPARAR_LIMITE = '40'
if ($Conta -eq 'gemini') { $env:PREPARAR_CHAVE = 'AIzaChaveFalsaDeTesteOficina0000000000' }
$t = Run 'preparar_1' "irm $url | iex" 3000 'ps'
Remove-Item Env:CONTA, Env:PREPARAR_LIMITE, Env:PREPARAR_CHAVE -ErrorAction SilentlyContinue
$r1 = Rx
$res.conferencia_ok = [bool](($t -match 'do Hermes conferidas') -and ($t -match 'vai funcionar nas pr'))
$res.habilidades_ok = ([regex]::Matches($t, 'Habilidade (boas-vindas|cerebro|recall-and-claim-verification|measurement-validity) (instalada|j. instalada)')).Count -eq 4
$res.cerebro_baixado = [bool](($t -match 'rebro baixado') -and (Test-Path "$HOME\.cortex\cortex.py"))
$res.login_aberto = [bool]($t -match 'auth.openai.com/codex/device|claude.ai/oauth/authorize|O Google recusou a chave')
$res.final_honesto = [bool]($t -match 'conectar sua conta')
$res.retentou_rede = [bool]($t -match 'tentativa \d de|Sem internet agora')
$res.preparar_1_download_mb = if ($r0 -and $r1) { [math]::Round(($r1 - $r0) / 1MB) } else { 'n/a' }
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'User') + ';' + [Environment]::GetEnvironmentVariable('Path', 'Machine')
Run 'inventario_depois' $inv 60 | Out-Null

$t = Run 'preparar_2' "irm $url | iex" 900 'ps'
$r2 = Rx
$res.preparar_2_pulou = [bool](($t -match 'j. est. instalado') -and -not ($t -match 'Instalando o Hermes') -and (([regex]::Matches($t, 'j. instalada')).Count -eq 4))
$res.preparar_2_sozinho = [bool]($t -match 'conectar sua conta')
$res.preparar_2_secs = $res['preparar_2'].secs
$res.preparar_2_download_mb = if ($r1 -and $r2) { [math]::Round(($r2 - $r1) / 1MB, 1) } else { 'n/a' }

Run 'version' 'hermes --version' 120 | Out-Null
$a = Run 'approvals' 'hermes config get approvals.mode' 120
$res.approvals_manual = [bool]($a -match 'manual')
$list = Run 'skills_list' 'hermes skills list' 120
$sk = Join-Path $env:LOCALAPPDATA 'hermes\skills'
$res.skills_listadas = [bool](($list -match 'boas-vindas') -and (@('boas-vindas','cerebro','recall-and-claim-verification','measurement-validity' | Where-Object { Test-Path (Join-Path $sk "$_\SKILL.md") }).Count -eq 4))
$res.sem_minds_no_nome = -not ($list -match '(?i)minds')
$py = Get-ChildItem "$env:LOCALAPPDATA\hermes\installs" -Recurse -Filter python.exe -ErrorAction SilentlyContinue |
      Where-Object { $_.FullName -match '\\venv\\Scripts\\python\.exe$' } | Select-Object -First 1
if ($py) {
    $raw = "https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/$Ref"
    Invoke-WebRequest "$raw/skills/cerebro/SKILL.md" -OutFile "$env:USERPROFILE\sk.md" -UseBasicParsing
    Invoke-WebRequest "$raw/oficina/testes/testa_cerebro.py" -OutFile "$env:USERPROFILE\tc.py" -UseBasicParsing
    $s = Run 'brain' "`"$($py.FullName)`" `"$env:USERPROFILE\tc.py`" `"$env:USERPROFILE\sk.md`" $Ref" 180
    $res.brain_ok = [bool]($s -match 'CEREBRO_OK')
}
$res.finished = $true
Save
New-Item "$Out\done-$Variant.flag" -ItemType File -Force | Out-Null
