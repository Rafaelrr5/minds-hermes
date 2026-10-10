# Prepara o computador para a oficina Hermes do Minds of the Future (Windows).
# Confere o que já existe e só instala o que falta. Pode rodar de novo sem problema.
# Não precisa de administrador. No PowerShell normal:
#   irm https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/main/oficina/preparar.ps1 | iex
function Ok([string]$m)   { Write-Host "  [ok] $m" -ForegroundColor Green }
function Faz([string]$m)  { Write-Host "  [..] $m" -ForegroundColor Cyan }
function Para([string]$m) { Write-Host "`n  [X] $m`n" -ForegroundColor Red }

function Preparar-Oficina {
    Write-Host "`n  Preparando o computador para a oficina Hermes`n"
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'User') + ';' + [Environment]::GetEnvironmentVariable('Path', 'Machine')

    # 1. Já instalado? Então não baixa nada.
    $h = Get-Command hermes -ErrorAction SilentlyContinue
    if ($h) {
        $v = (& $h.Source --version 2>$null | Select-Object -First 1)
        if ($v) { Ok "O Hermes já está instalado: $v"; Ok "Nada para fazer. Pode ir para a oficina."; return }
    }

    # 2. Computador compatível?
    $build = [Environment]::OSVersion.Version.Build
    if ($build -lt 17763) { Para "Este Windows é antigo demais (build $build). Avise no grupo: você faz a oficina em dupla."; return }
    $drive = (Get-Item $env:LOCALAPPDATA).PSDrive
    $livreGB = [math]::Floor($drive.Free / 1GB)
    if ($livreGB -lt 6) { Para "Falta espaço: há $livreGB GB livres e o Hermes precisa de 6 GB. Libere espaço e rode de novo."; return }
    Ok "Espaço livre: $livreGB GB"
    Ok "Não precisa instalar mais nada: o Hermes traz tudo o que usa"

    # 3. Hermes, versão enxuta (sem navegador automático e sem controle de tela).
    Faz "Instalando o Hermes. Leva de 5 a 15 minutos e às vezes parece parado. Não feche."
    & ([scriptblock]::Create((Invoke-RestMethod https://hermes-agent.nousresearch.com/install.ps1))) -NonInteractive -SkipBrowser -SkipComputerUse

    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'User') + ';' + [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $h = Get-Command hermes -ErrorAction SilentlyContinue
    if ($h -and (& $h.Source --version 2>$null)) {
        Write-Host ""
        Ok "Pronto: $(& $h.Source --version | Select-Object -First 1)"
        Ok "Feche esta janela, abra outra, digite: hermes --version"
        Ok "e mande um print no grupo da oficina."
    } else {
        Para "A instalação do Hermes não terminou. Mande um print desta tela no grupo."
    }
}
Preparar-Oficina
