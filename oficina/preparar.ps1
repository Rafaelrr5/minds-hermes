# Prepara o computador para usar o Hermes (Windows), sem precisar de ninguém olhando:
# confere o que já existe, instala só o que falta, espera a internet voltar se ela cair,
# deixa as habilidades e o cérebro prontos e confere tudo no fim. Pode rodar de novo.
# Não precisa de administrador. No PowerShell normal:
#   irm https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/main/oficina/preparar.ps1 | iex
$ProgressPreference = 'SilentlyContinue'
$Ref = if ($env:PREPARAR_REF) { $env:PREPARAR_REF } else { 'main' }   # só os testes mudam isto
$RawMH = "https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/$Ref"
$RawAC = 'https://raw.githubusercontent.com/Rafaelrr5/agent-cortex/main'

function Ok([string]$m)   { Write-Host "  [ok] $m" -ForegroundColor Green }
function Faz([string]$m)  { Write-Host "  [..] $m" -ForegroundColor Cyan }
function Para([string]$m) { Write-Host "`n  [X] $m`n" -ForegroundColor Red }
function Atualizar-Path { $env:Path = [Environment]::GetEnvironmentVariable('Path', 'User') + ';' + [Environment]::GetEnvironmentVariable('Path', 'Machine') }
function Hermes-Versao {
    $h = Get-Command hermes -ErrorAction SilentlyContinue
    if ($h) { return (& $h.Source --version 2>$null | Select-Object -First 1) }
    return $null
}
function Tem-Internet {
    try { Invoke-WebRequest https://github.com -Method Head -TimeoutSec 15 -UseBasicParsing | Out-Null; return $true } catch { return $false }
}
function Esperar-Internet {   # espera até 6 horas, sem perguntar nada
    if (Tem-Internet) { return $true }
    Faz "Sem internet agora. Vou esperando ela voltar; pode deixar o computador ligado."
    $t = 0
    while (-not (Tem-Internet)) {
        Start-Sleep 20; $t += 20
        if ($t % 300 -eq 0) { Faz "ainda sem internet ($([int]($t / 60)) min). Continuo esperando." }
        if ($t -ge 21600) { return $false }
    }
    Ok "A internet voltou"; return $true
}
function Tentar([string]$desc, [int]$max, [scriptblock]$acao) {
    for ($n = 1; $n -le $max; $n++) {
        $ok = $false
        try { $ok = [bool](& $acao) } catch { $ok = $false }
        if ($ok) { return $true }
        if ($n -lt $max) {
            Faz "$desc não terminou (tentativa $n de $max). Vou tentar de novo, continuando de onde parou."
            if (-not (Esperar-Internet)) { return $false }
            Start-Sleep ([Math]::Min(120, 15 * $n))
        }
    }
    return $false
}
function Manter-Acordado {
    try {
        Add-Type -Namespace Hermes -Name Energia -MemberDefinition '[DllImport("kernel32.dll")] public static extern uint SetThreadExecutionState(uint f);' -ErrorAction Stop
        [Hermes.Energia]::SetThreadExecutionState([uint32]'0x80000001') | Out-Null   # contínuo + sistema ligado
    } catch {}
}

function Instalar-Uma-Vez {
    & ([scriptblock]::Create((Invoke-RestMethod https://hermes-agent.nousresearch.com/install.ps1 -TimeoutSec 60))) -NonInteractive -SkipBrowser -SkipComputerUse | Out-Host
    Atualizar-Path
    if (-not (Hermes-Versao)) { return $false }
    hermes pm doctor *> $null          # instalação pela metade não passa aqui
    return ($LASTEXITCODE -eq 0)
}

function Instalar-Hermes {
    $build = [Environment]::OSVersion.Version.Build
    if ($build -lt 17763) { Para "Este Windows é antigo demais (build $build). Avise no grupo: você faz a oficina em dupla."; return $false }
    $livreGB = [math]::Floor((Get-Item $env:LOCALAPPDATA).PSDrive.Free / 1GB)
    if ($livreGB -lt 6) { Para "Falta espaço: há $livreGB GB livres e o Hermes precisa de 6 GB. Libere espaço e rode de novo."; return $false }
    Ok "Espaço livre: $livreGB GB"
    Ok "Não precisa instalar mais nada: o Hermes traz tudo o que usa"
    if (-not (Esperar-Internet)) { Para "Fiquei 6 horas sem internet. Rode este comando de novo quando ela voltar."; return $false }
    Faz "Instalando o Hermes. Leva de 5 a 30 minutos, conforme a internet. Pode deixar baixando."
    if (Tentar 'A instalação do Hermes' 8 { Instalar-Uma-Vez }) { return $true }
    Para "A instalação do Hermes não terminou depois de várias tentativas. Rode este comando de novo; ele continua de onde parou."
    return $false
}

function Conferir-Instalacao {
    Write-Host ""
    Faz "Conferindo a instalação"
    $v = Hermes-Versao
    if (-not $v) { return $false }
    Ok "O Hermes abre: $v"
    hermes pm doctor *> $null
    if ($LASTEXITCODE -ne 0) { return $false }
    Ok "Peças do Hermes conferidas"
    $bin = Split-Path (Get-Command hermes).Source -Parent
    if (-not (([Environment]::GetEnvironmentVariable('Path', 'User') -split ';') -contains $bin)) { return $false }
    Ok "O comando hermes vai funcionar nas próximas janelas do PowerShell"
    return $true
}

function Instalar-Habilidade([string]$nome, [string]$url) {
    # Confere pela pasta: a lista do Hermes corta nomes longos.
    $casa = if ($env:HERMES_HOME) { $env:HERMES_HOME } else { Join-Path $env:LOCALAPPDATA 'hermes' }
    $arq = Join-Path $casa "skills\$nome\SKILL.md"
    if (Test-Path $arq) { Ok "Habilidade $nome já instalada"; return }
    $feito = Tentar "A habilidade $nome" 5 {
        hermes skills install $url --yes *> $null
        Test-Path $arq
    }
    if ($feito) { Ok "Habilidade $nome instalada" } else { Faz "A habilidade $nome não instalou agora; dá para instalar depois, na oficina." }
}

function Configurar {
    Write-Host ""
    Faz "Deixando tudo pronto para o primeiro uso"
    hermes config set approvals.mode manual *> $null; if ($LASTEXITCODE -eq 0) { Ok "O Hermes vai pedir sua licença antes de ações arriscadas" }
    hermes config set display.language pt *> $null; if ($LASTEXITCODE -eq 0) { Ok "Mensagens do Hermes em português" }
    Instalar-Habilidade 'boas-vindas' "$RawMH/skills/boas-vindas/SKILL.md"
    Instalar-Habilidade 'cerebro' "$RawMH/skills/cerebro/SKILL.md"
    Instalar-Habilidade 'recall-and-claim-verification' "$RawAC/skills/recall-and-claim-verification/SKILL.md"
    Instalar-Habilidade 'measurement-validity' "$RawAC/skills/measurement-validity/SKILL.md"
    $cx = Join-Path $HOME '.cortex\cortex.py'
    New-Item -ItemType Directory -Force (Split-Path $cx) | Out-Null
    if ((Test-Path $cx) -and (Get-Item $cx).Length -gt 0) { Ok "Cérebro já baixado" }
    elseif (Tentar 'O cérebro' 5 { Invoke-WebRequest "$RawAC/cortex.py" -OutFile $cx -UseBasicParsing -TimeoutSec 60; (Get-Item $cx).Length -gt 0 }) { Ok "Cérebro baixado" }
    else { Faz "O cérebro não baixou agora; ele baixa sozinho no primeiro uso." }
}

function Conversa-Ok {
    # A pergunta não contém a resposta: assim um erro que repete a pergunta não passa por sucesso.
    $r = (hermes chat -q "Quanto é dois mais três? Responda só com o número escrito por extenso." --oneshot 2>&1 | Out-String)
    return [bool]($r -match '(?i)cinco')
}

function Escolha-Com-Prazo([int]$segundos) {   # nunca trava: sem tecla no prazo, devolve vazio
    try {
        if ([Console]::IsInputRedirected) { return '' }
        $fim = (Get-Date).AddSeconds($segundos)
        while ((Get-Date) -lt $fim) {
            if ([Console]::KeyAvailable) { $k = [Console]::ReadKey($true).KeyChar; if ('1', '2' -contains "$k") { Write-Host $k; return "$k" } }
            Start-Sleep -Milliseconds 200
        }
    } catch {}
    return ''
}

function Conectar-Conta {
    Write-Host ""
    Faz "Conferindo se o Hermes já conversa com uma inteligência artificial"
    if (Conversa-Ok) { Ok "O Hermes já está conectado e respondendo"; return $true }
    $conta = $env:CONTA
    if (-not $conta) {
        Write-Host ""
        Write-Host "  Se você estiver aqui, já dá para conectar sua conta (opcional):"
        Write-Host "    1) ChatGPT (OpenAI)     2) Claude (Anthropic)"
        Write-Host -NoNewline "  Aperte 1 ou 2. Sem resposta em 2 minutos, eu termino sem conectar: "
        $espera = if ($env:PREPARAR_ESPERA) { [int]$env:PREPARAR_ESPERA } else { 120 }
        $op = Escolha-Com-Prazo $espera
        Write-Host ""
        if ($op -eq '1') { $conta = 'chatgpt' } elseif ($op -eq '2') { $conta = 'claude' }
    }
    if ($conta -eq 'chatgpt') { $prov = 'openai-codex'; Faz "Abra o endereço que vai aparecer, entre na sua conta do ChatGPT e digite o código." }
    elseif ($conta -eq 'claude') { $prov = 'anthropic'; Faz "O navegador vai abrir. Entre na sua conta do Claude, autorize e cole aqui o código que aparecer." }
    else { return $false }

    $exe = (Get-Command hermes).Source
    if ($env:PREPARAR_LIMITE) {
        # Só para testes automáticos: limita a espera e mostra o que o login escreveu.
        $tmp = [IO.Path]::GetTempFileName(); $env:PYTHONUNBUFFERED = '1'
        $p = Start-Process -FilePath $exe -ArgumentList "auth add $prov --type oauth" -NoNewWindow -PassThru -RedirectStandardOutput $tmp -RedirectStandardError "$tmp.err"
        if (-not $p.WaitForExit([int]$env:PREPARAR_LIMITE * 1000)) { try { $p.Kill() } catch {} }
        Start-Sleep 1; Get-Content $tmp, "$tmp.err" -ErrorAction SilentlyContinue | Out-Host
    } else {
        # Direto no console: o endereço, o código e a pergunta aparecem na hora.
        Start-Process -FilePath $exe -ArgumentList "auth add $prov --type oauth" -NoNewWindow -Wait
    }
    hermes config set model.provider $prov *> $null
    Faz "Testando uma conversa de verdade"
    if (Conversa-Ok) { Ok "Conectado: o Hermes respondeu pela sua conta"; return $true }
    if ($prov -eq 'anthropic' -and ((hermes auth status anthropic 2>$null | Out-String) -match 'logged in')) {
        Faz "O login no Claude deu certo, mas a conta não liberou conversa pelo Hermes. O plano Pro não libera esse uso."
    } else { Faz "O login não terminou." }
    return $false
}

function Preparar-Hermes {
    Write-Host "`n  Preparando o computador para o Hermes. Pode deixar rodando: não precisa responder nada.`n"
    Manter-Acordado
    Atualizar-Path
    $v = Hermes-Versao
    if ($v) { Ok "O Hermes já está instalado: $v" }
    elseif (-not (Instalar-Hermes)) { return }
    if (-not (Conferir-Instalacao)) {
        Faz "A conferência achou um problema. Vou refazer a instalação uma vez."
        if (-not ((Tentar 'A instalação do Hermes' 4 { Instalar-Uma-Vez }) -and (Conferir-Instalacao))) {
            Para "A instalação não ficou certa. Mande um print desta tela no grupo."; return
        }
    }
    Configurar
    Write-Host ""
    if (Conectar-Conta) {
        Ok "Tudo pronto e conectado. Abra uma janela nova do PowerShell e digite: hermes"
    } else {
        Ok "Tudo instalado. Falta só conectar sua conta, o que leva 2 minutos na oficina:"
        Ok "lá você cola este mesmo comando de novo e escolhe ChatGPT ou Claude."
    }
    Ok "Mande um print desta tela no grupo."
}
Preparar-Hermes
