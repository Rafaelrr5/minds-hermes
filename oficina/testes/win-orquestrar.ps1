# Runs as the CI admin. Creates a STANDARD (non-admin) Windows account and runs
# win-aluno.ps1 as that account through Task Scheduler, measuring network and disk.
param([string]$Variant = 'full')
$ErrorActionPreference = 'Stop'
$root = 'C:\oficina'; $out = "$root\out"
New-Item -ItemType Directory -Force $out | Out-Null
Copy-Item "$PSScriptRoot\win-aluno.ps1" $root -Force
icacls $root /grant 'Everyone:(OI)(CI)F' /T | Out-Null

# Windows 10/11 client default is Restricted (servers default to RemoteSigned).
# Set it for Windows PowerShell 5.1 (what participants have), not for this pwsh 7.
powershell.exe -NoProfile -Command "Set-ExecutionPolicy Restricted -Scope LocalMachine -Force; Get-ExecutionPolicy -List | Out-String"

$user = "aluno$Variant"
$pw = 'Mf!' + [guid]::NewGuid().ToString('N').Substring(0, 14) + 'Az9'
net user $user $pw /add /y | Out-Null
Write-Host "Groups of ${user}:"; net user $user | Select-String 'Local Group'

# Standard users lack "log on as a batch job" on Server SKUs; grant only that right.
$sid = (New-Object Security.Principal.NTAccount($user)).Translate([Security.Principal.SecurityIdentifier]).Value
secedit /export /cfg "$root\sec.inf" /areas USER_RIGHTS | Out-Null
$c = Get-Content "$root\sec.inf"
if ($c -match '^SeBatchLogonRight') { $c = $c -replace '^(SeBatchLogonRight = .*)$', "`$1,*$sid" }
else { $c = $c -replace '^\[Privilege Rights\]$', "[Privilege Rights]`r`nSeBatchLogonRight = *$sid" }
Set-Content "$root\sec2.inf" $c -Encoding Unicode
secedit /configure /db "$root\sec.sdb" /cfg "$root\sec2.inf" /areas USER_RIGHTS | Out-Null

function RxBytes { (Get-NetAdapterStatistics | Measure-Object ReceivedBytes -Sum).Sum }
$rx0 = RxBytes; $t0 = Get-Date
$tr = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File $root\win-aluno.ps1 -Out $out -Variant $Variant"
schtasks /create /tn "oficina-$Variant" /ru $user /rp $pw /sc once /st 23:59 /rl LIMITED /f /tr $tr | Out-Null
schtasks /run /tn "oficina-$Variant" | Out-Null

$deadline = (Get-Date).AddMinutes(55)
while (-not (Test-Path "$out\done-$Variant.flag") -and (Get-Date) -lt $deadline) {
    Start-Sleep 20
    $st = (schtasks /query /tn "oficina-$Variant" /fo csv /v | ConvertFrom-Csv).Status
    Write-Host "$(Get-Date -f HH:mm:ss) task=$st"
}
$rx1 = RxBytes
$prof = "C:\Users\$user"
$size = (Get-ChildItem $prof -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
$meta = [ordered]@{
    variant = $Variant; image = $env:ImageOS; os_caption = (Get-CimInstance Win32_OperatingSystem).Caption
    download_mb = [math]::Round(($rx1 - $rx0) / 1MB); wall_min = [math]::Round(((Get-Date) - $t0).TotalMinutes, 1)
    profile_disk_mb = [math]::Round($size / 1MB); finished = (Test-Path "$out\done-$Variant.flag")
}
$meta | ConvertTo-Json | Set-Content -Encoding UTF8 "$out\meta-win-$Variant.json"
$meta | ConvertTo-Json
Get-Content "$out\result-win-$Variant.json" -ErrorAction SilentlyContinue
