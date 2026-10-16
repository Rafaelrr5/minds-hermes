# Antes da oficina: instale o Hermes em casa

Leva de 10 a 30 minutos, e você não precisa ficar olhando. Faça com a internet de casa: são
cerca de 1,6 GB no Windows e no Linux, e até 1,5 GB no Mac. Na oficina, a internet é dividida
pela turma toda e não aguenta 20 instalações ao mesmo tempo.

Você **não** precisa ter nada instalado antes, nem ser administrador do Windows, nem
desligar o antivírus. O comando abaixo confere o que o seu computador já tem e instala só o
que falta. Se você rodar duas vezes, a segunda não baixa nada.

Prefere ver? Vídeo de 1 minuto: [instalar-hermes.mp4](video/instalar-hermes.mp4)

## Antes de começar

- Deixe pelo menos **6 GB livres** no disco. Se faltar espaço, o próprio comando avisa.
- Se o seu computador é um **Mac com processador Intel**, o comando avisa que não dá para
  instalar. Nesse caso, avise no grupo: você faz a oficina em dupla.

## Antes de rodar, tenha uma destas contas

- **ChatGPT**: uma conta em chatgpt.com.
- **Claude**: uma conta em claude.ai. Atenção: segundo a documentação do Hermes, o plano
  Pro do Claude não libera esse uso. Se você só tem o Pro, prefira o ChatGPT.
- **Gemini**: uma conta Google. A chave gratuita é criada em aistudio.google.com/apikey;
  o comando mostra o caminho na hora de conectar. A chave gratuita usa o Gemini 3.8 Flash. O
  modelo mais novo, o Gemini 4 Argon, só funciona com cobrança ativada no Google, nem o
  plano Google AI Pro libera.

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

3. Não precisa instalar as ferramentas de desenvolvedor da Apple: se faltar o git, o
   comando baixa uma cópia só para você, sem abrir janela nem pedir senha.

## Linux

1. Abra o **Terminal**.
2. Copie a linha abaixo, cole e aperte Enter. Ela funciona mesmo sem o `curl`, que o Ubuntu
   não traz de fábrica:

```bash
wget -qO- https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/main/oficina/preparar.sh | bash
```

3. O comando não pede senha. Se faltar o git ou o curl, ele baixa uma cópia só para você.
   A única peça que ele não consegue pôr sozinho é a `libatomic`, que quase todo Linux já
   traz; se faltar, a mensagem diz o que pedir ao dono do computador.

## Depois de colar: pode deixar baixando

Você não precisa responder nada. O comando:

- espera a internet voltar, se ela cair, e continua de onde parou (até 6 horas);
- não deixa o computador dormir enquanto baixa;
- instala o Hermes, as habilidades (boas-vindas, cérebro e as duas de honestidade) e o cérebro;
- confere se ficou tudo certo.

No fim, se você estiver na frente do computador, ele oferece conectar sua conta do ChatGPT
(1), do Claude (2) ou do Gemini (3). Se ninguém responder em 2 minutos, ele termina sozinho com
`[ok] Tudo instalado. Falta só conectar sua conta`. **Mande um print dessa tela no grupo.**

A conta é conectada na oficina, em 2 minutos: você cola o mesmo comando de novo e escolhe
1, 2 ou 3. Rodar o comando de novo é seguro: ele não baixa nada outra vez.

## Se travar

Mande no grupo um print da tela inteira, com a última mensagem visível. Na véspera da
oficina tem plantão online de 30 minutos para resolver.
