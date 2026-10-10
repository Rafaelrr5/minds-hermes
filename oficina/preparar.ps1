# Prepara o computador para a oficina Hermes do Minds of the Future (Windows).
# Confere o que já existe e só instala o que falta. No fim confere a instalação e abre o
# login do ChatGPT ou do Claude. Pode rodar de novo sem problema. Não precisa de administrador.
# No PowerShell normal:
#   irm https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/main/oficina/preparar.ps1 | iex
function Ok([string]$m)   { Write-Host "  [ok] $m" -ForegroundColor Green }
function Faz([string]$m)  { Write-Host "  [..] $m" -ForegroundColor Cyan }
function Para([string]$m) { Write-Host "`n  [X] $m`n" -ForegroundColor Red }
function Atualizar-Path { $env:Path = [Environment]::GetEnvironmentVariable('Path', 'User') + ';' + [Environment]::GetEnvironmentVariable('Path', 'Machine') }
function Hermes-Versao {
    $h = Get-Command hermes -ErrorAction SilentlyContinue
    if ($h) { return (& $h.Source --version 2>$null | Select-Object -First 1) }
    return $null
}

function Instalar-Hermes {
    $build = [Environment]::OSVersion.Version.Build
    if ($build -lt 17763) { Para "Este Windows é antigo demais (build $build). Avise no grupo: você faz a oficina em dupla."; return $false }
    $livreGB = [math]::Floor((Get-Item $env:LOCALAPPDATA).PSDrive.Free / 1GB)
    if ($livreGB -lt 6) { Para "Falta espaço: há $livreGB GB livres e o Hermes precisa de 6 GB. Libere espaço e rode de novo."; return $false }
    Ok "Espaço livre: $livreGB GB"
    Ok "Não precisa instalar mais nada: o Hermes traz tudo o que usa"
    Faz "Instalando o Hermes. Leva de 5 a 15 minutos e às vezes parece parado. Não feche."
    & ([scriptblock]::Create((Invoke-RestMethod https://hermes-agent.nousresearch.com/install.ps1))) -NonInteractive -SkipBrowser -SkipComputerUse | Out-Host
    Atualizar-Path
    return $true
}

function Conferir-Instalacao {
    Write-Host ""
    Faz "Conferindo a instalação"
    $v = Hermes-Versao
    if (-not $v) { Para "O Hermes não abre. Mande um print desta tela no grupo."; return $false }
    Ok "O Hermes abre: $v"
    hermes pm doctor *> $null
    if ($LASTEXITCODE -ne 0) { Para "Uma peça do Hermes veio com defeito. Rode este comando de novo; se repetir, mande um print no grupo."; return $false }
    Ok "Peças do Hermes conferidas"
    $bin = Split-Path (Get-Command hermes).Source -Parent
    if (([Environment]::GetEnvironmentVariable('Path', 'User') -split ';') -contains $bin) {
        Ok "O comando hermes vai funcionar nas próximas janelas do PowerShell"
    } else { Para "O PowerShell não vai achar o comando hermes. Mande um print desta tela no grupo."; return $false }
    return $true
}

function Conversa-Ok {
    # A pergunta não contém a resposta: assim um erro que repete a pergunta não passa por sucesso.
    $r = (hermes chat -q "Quanto é dois mais três? Responda só com o número escrito por extenso." --oneshot 2>&1 | Out-String)
    return [bool]($r -match '(?i)cinco')
}

function Conectar-Conta {
    Write-Host ""
    Faz "Conferindo se o Hermes já conversa com uma inteligência artificial"
    if (Conversa-Ok) { Ok "O Hermes já está conectado e respondendo"; return $true }

    $conta = $env:CONTA
    if (-not $conta -and [Environment]::UserInteractive -and -not [Console]::IsInputRedirected) {
        Write-Host ""
        Write-Host "  Com qual conta você quer usar o Hermes?"
        Write-Host "    1) ChatGPT (OpenAI)"
        Write-Host "    2) Claude (Anthropic)"
        $op = Read-Host "  Digite 1 ou 2 e aperte Enter"
        if ($op -eq '1') { $conta = 'chatgpt' } elseif ($op -eq '2') { $conta = 'claude' }
    }
    if ($conta -eq 'chatgpt') { $prov = 'openai-codex'; Faz "Vai aparecer um endereço e um código. Abra o endereço no navegador, entre na sua conta do ChatGPT e digite o código." }
    elseif ($conta -eq 'claude') { $prov = 'anthropic'; Faz "Vai aparecer um link. Abra no navegador, entre na sua conta do Claude, autorize e cole aqui o código que aparecer." }
    else { Faz "Login não feito agora. Na oficina, rode: hermes model"; return $false }

    $exe = (Get-Command hermes).Source
    if ($env:PREPARAR_LIMITE) {
        # Só para testes automáticos: limita a espera e mostra o que o login escreveu.
        $tmp = [IO.Path]::GetTempFileName()
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
        Faz "Rode este comando de novo e escolha ChatGPT, ou deixe para a oficina."
    } else { Faz "O login não terminou. Rode este comando de novo ou deixe para a oficina." }
    return $false
}

function Preparar-Oficina {
    Write-Host "`n  Preparando o computador para a oficina Hermes`n"
    Atualizar-Path
    $v = Hermes-Versao
    if ($v) { Ok "O Hermes já está instalado: $v" }
    elseif (-not (Instalar-Hermes)) { return }
    if (-not (Conferir-Instalacao)) { return }
    Write-Host ""
    if (Conectar-Conta) {
        Ok "Tudo pronto. Feche esta janela, abra outra e digite: hermes"
        Ok "Mande um print dessa tela no grupo da oficina."
    } else {
        Ok "O Hermes está instalado. A conexão com a conta fica para a oficina."
        Ok "Feche esta janela, abra outra, digite hermes --version e mande um print no grupo."
    }
}
Preparar-Oficina
