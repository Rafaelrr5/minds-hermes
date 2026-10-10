# Pedidos para o Claude - Minicurso Hermes

Copie o bloco inteiro e cole na aba Code do aplicativo do Claude, com a permissão em Manual.
Nunca cole senha, chave de acesso ou chave do bot no Claude.

## Módulo 2 - Instalar e conferir

Leva 3 a 10 minutos.

```text
Quero instalar o Hermes Agent neste computador. Sou iniciante: antes de cada passo, me explique em uma frase, sem jargão, o que você vai fazer.

1. Descubra qual é o meu sistema: Windows, macOS ou Linux.
2. Instale usando só o instalador oficial do site hermes-agent.nousresearch.com. No Windows, rode o install.ps1 pelo PowerShell com a opção -NonInteractive. No macOS ou Linux, rode o install.sh com a opção --non-interactive. Não use outra fonte.
3. A instalação leva de 3 a 10 minutos. Não interrompa se parecer parada.
4. No fim, confira de verdade: rode hermes --version e hermes doctor. Se o comando hermes não for encontrado, use o caminho completo que o instalador mostrou.
5. Me responda em três linhas: se instalou, qual versão, e o que o diagnóstico diz que ainda falta.

Não configure modelo, chave nem Telegram: isso eu faço depois. Não desative antivírus nem nenhuma proteção do computador.
```

## Módulo 3 - Escolher o cérebro

Leva 10 minutos.

```text
Instalei o Hermes e agora preciso escolher o modelo de inteligência artificial que ele vai usar. Seja meu consultor, sem jargão.

1. Me faça no máximo três perguntas, uma de cada vez: quanto posso gastar por mês, quais assinaturas de IA eu já tenho (ChatGPT, Claude, Gemini ou outra) e se o meu computador é forte.
2. Recomende UM caminho e explique o porquê em três linhas. Leve em conta: a assinatura Claude Pro não funciona dentro do Hermes; a conta do ChatGPT pode ser usada pelo login da OpenAI; modelos muito pequenos erram em tarefas de vários passos.
3. Me diga o que escolher em cada tela do hermes setup. Quem digita sou eu, no terminal.
4. Quando eu disser que terminei, rode hermes doctor e me diga se o cérebro ficou ligado.

Nunca me peça senha nem chave de acesso aqui no chat.
```

## Módulo 4 - Setup padrão do Minds

Leva 2 minutos.

```text
Quero aplicar o setup padrão do minicurso Minds of the Future no meu Hermes.

1. Rode este comando e me conte o resultado em uma linha:
hermes skills install https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/main/skills/minds-boas-vindas/SKILL.md --yes
2. Confira com hermes skills list se a habilidade minds-boas-vindas aparece na lista.
3. Não mude mais nada. A conversa de apresentação eu faço com o próprio Hermes.
```

## Módulo 5 - Diagnóstico do Telegram

Leva 2 a 5 minutos.

```text
Já configurei o Telegram no Hermes com o hermes gateway setup. Quero conferir se o bot está funcionando. Me explique tudo em português simples.

1. Rode hermes gateway status e me diga se o atendente está rodando e se o Telegram aparece como conectado.
2. Se algo estiver errado, leia os registros de erro do Hermes e me diga a causa mais provável e como corrigir.
3. Se a correção for reiniciar o atendente, rode hermes gateway restart e confira o status de novo.

Regra importante: nunca mostre, copie ou repita a chave do bot, nem trechos dos registros que contenham a chave.
```
