# Antes da oficina: instale o Hermes em casa

Leva de 10 a 30 minutos, quase tudo esperando o download. Faça com a internet de casa: são
cerca de 1,6 GB no Windows e no Linux, e até 1,5 GB no Mac. Na oficina, a internet é dividida
pela turma toda e não aguenta 20 instalações ao mesmo tempo.

Você **não** precisa ter nada instalado antes, nem ser administrador do Windows, nem
desligar o antivírus. O comando abaixo confere o que o seu computador já tem e instala só o
que falta. Se você rodar duas vezes, a segunda não baixa nada.

## Antes de começar

- Deixe pelo menos **6 GB livres** no disco. Se faltar espaço, o próprio comando avisa.
- Se o seu computador é um **Mac com processador Intel**, o comando avisa que não dá para
  instalar. Nesse caso, avise no grupo: você faz a oficina em dupla.

## Windows

1. Abra o menu Iniciar, digite **PowerShell** e abra o programa normalmente. Não precisa
   escolher "Executar como administrador".
2. Copie a linha abaixo, cole na janela azul (botão direito do mouse) e aperte Enter:

```powershell
irm https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/main/oficina/preparar.ps1 | iex
```

## Mac

1. Aperte Cmd + Espaço, digite **Terminal** e aperte Enter.
2. Copie a linha abaixo, cole no Terminal e aperte Enter:

```bash
curl -fsSL https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/main/oficina/preparar.sh | bash
```

3. Se o Mac não tiver as ferramentas de desenvolvedor da Apple, vai abrir uma janela
   pedindo para instalar. Clique em **Instalar** e aceite. O comando espera essa instalação
   terminar e depois continua sozinho. Não feche o Terminal.

## Linux

1. Abra o **Terminal**.
2. Copie a linha abaixo, cole e aperte Enter. Ela funciona mesmo sem o `curl`, que o Ubuntu
   não traz de fábrica:

```bash
wget -qO- https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/main/oficina/preparar.sh | bash
```

3. Se faltar alguma peça, o computador pede a **sua senha** para instalar. É normal.

## Como saber que deu certo

No fim aparece `[ok] Pronto: Hermes Agent v...`. Até lá pode demorar e parecer parado de vez
em quando. Não feche a janela.

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
