# Runs as the CI admin. Strips the machine down to what a participant's Windows laptop has,
# creates a STANDARD account and runs limpo-win.ps1 as that account via Task Scheduler.
param([string]$Variant = 'clean', [string]$Conta = 'chatgpt')
$ErrorActionPreference = 'Continue'
$root = 'C:\oficina'; $out = "$root\out"
New-Item -ItemType Directory -Force $out | Out-Null
Copy-Item "$PSScriptRoot\limpo-win.ps1" $root -Force
icacls $root /grant 'Everyone:(OI)(CI)F' /T | Out-Null

# Notebook default policy, for Windows PowerShell 5.1.
powershell.exe -NoProfile -Command "Set-ExecutionPolicy Restricted -Scope LocalMachine -Force"

# Only Windows' own folders on PATH; preinstalled developer tools moved out of the way.
$min = 'C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Windows\System32\OpenSSH\'
[Environment]::SetEnvironmentVariable('Path', $min, 'Machine')
$hide = @('C:\Program Files\Git', 'C:\Program Files\nodejs', 'C:\hostedtoolcache', 'C:\Strawberry', 'C:\msys64',
          'C:\Program Files (x86)\Git', 'C:\tools', 'C:\Rust', 'C:\Users\runneradmin\.cargo',
          'C:\Users\Default\.cargo', 'C:\Users\Default\.rustup', 'C:\Users\Default\.dotnet', 'C:\Program Files\dotnet')
$hide += (Get-Item 'C:\Program Files\Python*', 'C:\Python*' -ErrorAction SilentlyContinue).FullName
foreach ($d in $hide) {
    if ($d -and (Test-Path $d)) {
        try { Rename-Item $d ((Split-Path $d -Leaf) + '.hidden') -ErrorAction Stop; Write-Host "hidden: $d" }
        catch { Write-Host "could not hide ${d}: $($_.Exception.Message)" }
    }
}

$user = 'alunolimpo'
$pw = 'Mf!' + [guid]::NewGuid().ToString('N').Substring(0, 14) + 'Az9'
net user $user $pw /add /y | Out-Null
$sid = (New-Object Security.Principal.NTAccount($user)).Translate([Security.Principal.SecurityIdentifier]).Value
secedit /export /cfg "$root\sec.inf" /areas USER_RIGHTS | Out-Null
$c = Get-Content "$root\sec.inf"
if ($c -match '^SeBatchLogonRight') { $c = $c -replace '^(SeBatchLogonRight = .*)$', "`$1,*$sid" }
else { $c = $c -replace '^\[Privilege Rights\]$', "[Privilege Rights]`r`nSeBatchLogonRight = *$sid" }
Set-Content "$root\sec2.inf" $c -Encoding Unicode
secedit /configure /db "$root\sec.sdb" /cfg "$root\sec2.inf" /areas USER_RIGHTS | Out-Null

function RxBytes { (Get-NetAdapterStatistics | Measure-Object ReceivedBytes -Sum).Sum }
$rx0 = RxBytes; $t0 = Get-Date
$tr = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File $root\limpo-win.ps1 -Out $out -Variant $Variant -Ref $env:GITHUB_SHA -Conta $Conta"
schtasks /create /tn "oficina-limpo" /ru $user /rp $pw /sc once /st 23:59 /rl LIMITED /f /tr $tr | Out-Null
schtasks /run /tn "oficina-limpo" | Out-Null
# Internet drop in the middle of the install: everything outbound blocked for 90 s.
$queda = Start-Job -ScriptBlock {
    Start-Sleep 150
    Set-NetFirewallProfile -All -Enabled True
    New-NetFirewallRule -DisplayName 'queda-teste' -Direction Outbound -Action Block | Out-Null
    $inicio = Get-Date -Format HH:mm:ss
    Start-Sleep 5
    $efetiva = try { Invoke-WebRequest https://github.com -Method Head -TimeoutSec 10 -UseBasicParsing | Out-Null; $false } catch { $true }
    Start-Sleep 85
    Remove-NetFirewallRule -DisplayName 'queda-teste'
    "queda_inicio=$inicio queda_efetiva=$efetiva queda_fim=$(Get-Date -Format HH:mm:ss)"
}
$deadline = (Get-Date).AddMinutes(65)
while (-not (Test-Path "$out\done-$Variant.flag") -and (Get-Date) -lt $deadline) { Start-Sleep 20; Write-Host "$(Get-Date -f HH:mm:ss) waiting" }
$rx1 = RxBytes
$size = (Get-ChildItem "C:\Users\$user" -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
$meta = [ordered]@{
    variant = $Variant; image = $env:ImageOS; os_caption = (Get-CimInstance Win32_OperatingSystem).Caption
    download_mb_total = [math]::Round(($rx1 - $rx0) / 1MB); wall_min = [math]::Round(((Get-Date) - $t0).TotalMinutes, 1)
    profile_disk_mb = [math]::Round($size / 1MB); finished = (Test-Path "$out\done-$Variant.flag")
    queda = [string](Receive-Job $queda -Wait -ErrorAction SilentlyContinue)
}
$meta | ConvertTo-Json | Set-Content -Encoding UTF8 "$out\meta-win-$Variant.json"
$meta | ConvertTo-Json
