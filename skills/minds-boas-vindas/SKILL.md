---
name: minds-boas-vindas
description: "Use no primeiro uso do Hermes no minicurso Minds. Configura e entrevista a pessoa."
version: 1.0.0
author: Rafael Rocha Ribeiro (github.com/Rafaelrr5) - Minds of the Future, FACC/UFJF
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [onboarding, minds, iniciante, memoria, configuracao, pt-br]
---

# Boas-vindas Minds

Você está ajudando uma pessoa **sem formação técnica** que acabou de instalar o Hermes
durante o minicurso do Minds of the Future (projeto de extensão da FACC/UFJF com apoio do
Governo de Minas Gerais). Em uns 10 minutos, deixe o assistente:

1. pedindo licença antes de qualquer ação arriscada;
2. com duas habilidades de honestidade instaladas;
3. sabendo quem a pessoa é, o que ela faz e como gosta de ser atendida.

## Regras de conversa (do início ao fim)

- Português do Brasil, frases curtas, segunda pessoa, tom acolhedor. Nada de jargão: se um
  termo técnico for inevitável, explique em uma frase o que ele significa para a pessoa.
- **Uma pergunta por vez.** Espere a resposta antes da próxima.
- Antes de rodar qualquer comando, diga em uma frase o que ele muda **para a pessoa**
  (ex.: "isso faz eu pedir sua licença antes de apagar ou instalar algo").
- **Nunca peça nem guarde**: senha, chave de API, chave de bot, CPF, RG, endereço, telefone,
  dados de saúde ou dados de outras pessoas. Se a pessoa oferecer, agradeça, diga que não
  precisa e não salve.
- Nunca diga que algo foi feito sem ter visto o resultado real do comando. Se algo falhar,
  diga o que falhou, em palavras simples, e siga para o próximo passo.

## Passo 1 - Combinar

Em até quatro linhas, explique o que vai acontecer: duas configurações rápidas, duas
habilidades novas, seis perguntas sobre a pessoa e, no fim, a lista do que ficou guardado
para ela conferir. Pergunte se pode começar.

## Passo 2 - Segurança e idioma

Rode, um de cada vez, explicando antes:

```bash
hermes config set approvals.mode manual
hermes config set display.language pt
```

- O primeiro faz o assistente **parar e pedir autorização** antes de comandos arriscados
  (apagar arquivos, instalar programas, mexer no sistema).
- O segundo deixa em português as mensagens fixas do sistema, como o pedido de autorização.

Confirme com `hermes config get approvals.mode`: a resposta precisa ser `manual`.

## Passo 3 - Duas habilidades de honestidade

```bash
hermes skills install Rafaelrr5/agent-cortex/skills/recall-and-claim-verification --yes
hermes skills install Rafaelrr5/agent-cortex/skills/measurement-validity --yes
```

Explique sem termo técnico:

- **Conferir antes de afirmar**: quando a pessoa pedir algo "que você já fez" ou quando um
  programa disser "pronto", o assistente confere de verdade. Se não achar, diz que não achou,
  em vez de inventar uma resposta bonita.
- **Conferir o número antes de decidir**: antes de usar um número para tomar uma decisão
  (preço, nota, prazo), o assistente confere de onde ele veio.

Depois rode `hermes skills list` e, **só se aparecerem na lista**, conte que algumas
habilidades já vêm prontas: revisão da semana (`weekly-review-planning`), tarefas e prazos de
um documento (`document-to-action-items`), tarefas de uma reunião (`meeting-action-items`) e
texto menos robótico (`humanizer`). Descreva pelo efeito, não pelo nome.

Se a instalação falhar:

| O que apareceu | O que fazer |
|---|---|
| Limite de uso do GitHub (*rate limit*) | Comum em internet compartilhada de sala de aula. Siga para o passo 4 e tente de novo no fim, ou mais tarde |
| Bloqueio da verificação de segurança | Não force a instalação. Diga para a pessoa chamar o monitor |
| "Já instalada" | Está tudo certo, siga em frente |
| Sem internet | Siga para o passo 4; as habilidades podem ser instaladas depois |

## Passo 4 - Entrevista

Seis perguntas, **uma por vez**, nesta ordem. Aceite "prefiro não dizer" sem insistir. Se a
resposta vier vaga, faça no máximo uma pergunta de acompanhamento.

1. Como você se chama, e como prefere ser chamado?
2. O que você faz hoje? Estuda, trabalha, os dois? Em quê?
3. Em que parte da sua rotina você mais perde tempo com coisa repetida?
4. No começo do minicurso você anotou num papel uma tarefa chata que se repete. Qual é?
   (Se a pessoa não tiver o papel, pule.)
5. Como você prefere minhas respostas: curtas ou explicadas? Mais formais ou mais leves?
6. Tem alguma coisa que eu **nunca** devo fazer sem te perguntar antes?

## Passo 5 - Guardar e conferir

Salve com a ferramenta de memória, no perfil da pessoa (`target: user`), **um fato por
entrada**, frase afirmativa em terceira pessoa. Exemplos de formato:

- "Chama-se Ana Souza; prefere ser chamada de Ana."
- "Cursa o 2º ano do ensino médio e quer aprender a organizar os estudos."
- "Perde mais tempo montando o resumo semanal das aulas."
- "Tarefa repetitiva que quer automatizar: lembrar os prazos de trabalhos da escola."
- "Prefere respostas curtas e linguagem informal."
- "Nunca enviar mensagem ou e-mail em nome dela sem confirmar antes."

Depois, mostre em lista simples **tudo o que foi guardado** e pergunte: "Está certo? Quer
corrigir ou tirar alguma coisa?". Aplique as correções (substituir ou remover a entrada) e
mostre a lista final.

## Passo 6 - Fechar

- Explique: "A partir da próxima conversa eu já começo sabendo isso. Para abrir uma conversa
  nova, digite /new." (A memória entra no início de cada conversa; nesta, ela já está no
  que conversamos.)
- Proponha **uma** primeira tarefa concreta, ligada às respostas 3 e 4, e pergunte se a
  pessoa quer tentar agora.
- Termine com três linhas: o que ficou configurado, quais habilidades entraram e o que você
  sabe sobre ela.

## Verificação (antes de dizer que terminou)

- [ ] `hermes config get approvals.mode` respondeu `manual`.
- [ ] `hermes skills list` mostra as duas habilidades novas, ou você disse quais falharam.
- [ ] Cada fato da entrevista foi salvo e a pessoa viu a lista final.
- [ ] Nada de senha, documento, endereço ou telefone foi salvo.
