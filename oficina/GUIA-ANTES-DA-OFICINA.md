# Antes da oficina: instale o Hermes em casa

Leva de 10 a 20 minutos, a maior parte esperando o download. Faça com a internet de casa:
o Hermes baixa cerca de 1,6 GB no Windows e 0,5 GB no Mac. Na oficina, a internet é
dividida por toda a turma e não aguenta 20 instalações ao mesmo tempo.

Você **não** precisa ser administrador do computador nem desligar o antivírus.

## Antes de começar

- Deixe pelo menos **6 GB livres** no disco.
- No Mac, veja o tipo do computador: menu Apple, depois "Sobre este Mac".
  - Se aparecer **Chip Apple (M1, M2, M3 ou M4)**, siga o guia.
  - Se aparecer **Processador Intel**, não instale. Hoje o Hermes não instala nesses Macs.
    Avise no grupo: você vai fazer a oficina em dupla.

## Windows

1. Abra o menu Iniciar, digite **PowerShell** e abra o programa normalmente. Não precisa
   escolher "Executar como administrador".
2. Copie a linha abaixo inteira, cole na janela azul com o botão direito do mouse e aperte
   Enter:

```powershell
& ([scriptblock]::Create((irm https://hermes-agent.nousresearch.com/install.ps1))) -NonInteractive -SkipBrowser -SkipComputerUse
```

3. Espere aparecer `Hermes Agent install complete`. Pode demorar uns 10 minutos e parecer
   parado de vez em quando. Não feche a janela.

## Mac (chip Apple) e Linux

1. Abra o **Terminal**. No Mac, aperte Cmd + Espaço, digite Terminal e aperte Enter.
2. Copie a linha abaixo inteira, cole no Terminal e aperte Enter:

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --non-interactive --skip-browser --skip-computer-use
```

3. Espere aparecer `Hermes Agent install complete`.

No Mac, se abrir uma janela pedindo para instalar as "ferramentas de desenvolvedor", clique
em **Instalar**, espere terminar e cole a linha de novo.

## Conferir

1. **Feche a janela** e abra uma nova (PowerShell ou Terminal).
2. Digite `hermes --version` e aperte Enter.
3. Se aparecer `Hermes Agent v...`, está pronto. **Mande um print dessa tela no grupo.**

Não precisa configurar mais nada. A conexão com o ChatGPT, o Gemini ou o Claude é feita
junto na oficina.

## Se travar

Mande no grupo um print da tela inteira, com a última mensagem visível. Na véspera da
oficina tem plantão online de 30 minutos para resolver.

## Para a oficina, crie uma destas contas

- **ChatGPT**: uma conta em chatgpt.com.
- **Gemini** (gratuito): entre em aistudio.google.com com sua conta Google e clique em
  "Get API key". Guarde a chave só para você e nunca mande no grupo.
