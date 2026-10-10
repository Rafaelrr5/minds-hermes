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

## Antes de rodar, tenha uma destas contas

- **ChatGPT**: uma conta em chatgpt.com.
- **Claude**: uma conta em claude.ai. Atenção: segundo a documentação do Hermes, o plano
  Pro do Claude não libera esse uso. Se você só tem o Pro, prefira o ChatGPT.

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

## Depois de instalar: conferência e login

Quando a instalação termina, o próprio comando confere se tudo ficou certo e depois
pergunta com qual conta você quer usar o Hermes:

- **1) ChatGPT**: aparece um endereço e um código. Abra o endereço no navegador, entre na
  sua conta do ChatGPT e digite o código.
- **2) Claude**: o navegador abre sozinho. Entre na sua conta do Claude, autorize, copie o
  código que aparecer e cole na janela do PowerShell ou do Terminal.

Depois do login, o comando faz uma pergunta de teste ao Hermes. Se ele responder, aparece
`[ok] Tudo pronto`. **Mande um print dessa tela no grupo.**

Se o login não der certo, tudo bem: o Hermes continua instalado e a conexão é feita junto
na oficina. Mande o print do mesmo jeito.

Rodar o comando de novo é seguro: ele não instala outra vez, só confere e oferece o login.

## Se travar

Mande no grupo um print da tela inteira, com a última mensagem visível. Na véspera da
oficina tem plantão online de 30 minutos para resolver.
