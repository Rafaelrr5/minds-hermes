# Oficina Hermes: plano revisto

Duração: 2 horas. Meta: em 1h30 cada pessoa sai com o Hermes funcionando, conectado a um
provedor, com a apresentação feita, as habilidades do Minds e o cérebro instalados. Os 30
minutos finais ficam para casos de uso. Os números citados aqui estão em
`RESULTADOS-TESTES.md`.

## A mudança principal: instalar antes da oficina

Cada instalação baixa de 1,5 a 2 GB (Windows e Linux). Com 20 pessoas no mesmo Wi-Fi, isso
dá mais de 30 GB. Por isso a instalação sai da oficina e passa a ser feita em casa, com a
internet da própria pessoa. Na oficina, a internet fica só para entrar no provedor e
conversar.

### 3 dias antes: mensagem para a turma

Mandar o `GUIA-ANTES-DA-OFICINA.md`, com um único comando por sistema. O comando
(`oficina/preparar.*`) confere o que o computador tem e instala só o que falta. Exemplos: as
ferramentas da Apple num Mac que não tem, o git e o curl num Linux zerado. Depois instala o
Hermes enxuto, sem administrador e sem perguntas no meio. Rodar de novo não baixa nada. Foi
testado em máquinas sem nada instalado (`RESULTADOS-TESTES.md`, segunda rodada).

No fim, o próprio comando confere a instalação, abre o login do ChatGPT ou do Claude e faz
uma pergunta de teste. Cada pessoa manda no grupo o print da tela final. "Tudo pronto" quer
dizer instalado e conectado; "a conexão fica para a oficina" quer dizer só instalado. Esses
prints viram a lista de prontos.

### 1 dia antes: plantão online de 30 minutos

Para quem travou. Quem continuar sem instalar fica marcado como "instala na oficina".

### Separar as máquinas antes de chegar

| Situação | O que fazer |
|---|---|
| Instalou em casa | Começa direto pela parte do provedor |
| Windows, Linux ou Mac com chip Apple, mas não instalou | Instala na oficina pela rede reserva, no máximo 5 pessoas |
| Mac Intel | **Não instala hoje** (testado). Faz a oficina em dupla com quem instalou |
| Menos de 6 GB livres no disco | Libera espaço antes ou faz em dupla |

Para saber se o Mac é Intel: menu Apple, depois "Sobre este Mac". Se aparecer "Chip Apple
M1/M2/M3/M4", instala. Se aparecer "Processador Intel", fica em dupla.

## O que levar

- **Roteador 4G ou celular para a rede reserva**, só para as instalações atrasadas. São
  cerca de 1,6 GB por máquina Windows ou Linux e até 1,4 GB por Mac com chip Apple que não
  tem as ferramentas da Apple.
- **Três notebooks reserva já instalados e com provedor configurado**, para as duplas.
- 1 monitor para cada 6 a 8 pessoas.

## Roteiro da oficina

| Tempo | Bloco | Resultado esperado |
|---|---|---|
| 0:00 – 0:10 | Abertura e demonstração ao vivo do resultado final | A turma vê aonde vai chegar |
| 0:10 – 0:20 | Conferência: cada um abre o terminal e roda `hermes --version` | Grupos separados: prontos, atrasados, duplas |
| 0:20 – 0:45 | Quem não conectou em casa roda o mesmo comando de novo: ele pula a instalação e abre o login. Enquanto isso, os atrasados instalam pela rede reserva | Hermes respondendo um "oi" |
| 0:45 – 1:15 | `/boas-vindas`: segurança, idioma, três habilidades e entrevista | O Hermes sabe quem a pessoa é |
| 1:15 – 1:30 | Cérebro: guardar dois fatos da própria rotina e buscar um deles | Memória longa funcionando |
| 1:30 – 2:00 | Casos de uso, Telegram, testes e outros provedores | Primeira tarefa real |

Avisar no bloco das 0:10: o `hermes doctor` mostra "Found 5 issues" mesmo quando está tudo
certo, porque ainda não há provedor configurado.

## Provedores (padrão: OpenAI, Anthropic e Gemini)

| Provedor | Como entra | Situação |
|---|---|---|
| **ChatGPT (OpenAI)** | `hermes model`, opção ChatGPT. Aparece um código para digitar no site da OpenAI | Testado até a tela do código. **Falta testar se conta gratuita funciona** |
| **Gemini** | Chave gratuita criada em aistudio.google.com e colada no `hermes model` | Não testado com chave real. A documentação avisa que a cota gratuita acaba rápido |
| **Claude (Anthropic)** | Link de login e código colado de volta | Testado até a tela do link. A documentação diz que **o plano Pro não funciona** e que o Max só funciona com créditos extras. Sem isso, só com chave de API paga |

Recomendação: ChatGPT como padrão da turma e Gemini como plano gratuito. Claude só para
quem já tem créditos de API ou Max com créditos extras. Antes da oficina, testar o login
com uma conta ChatGPT gratuita e uma chave Gemini gratuita.

## Habilidades e cérebro

- `boas-vindas`: configura a segurança e o idioma, instala três habilidades (duas de
  honestidade e o cérebro), faz seis perguntas e guarda as respostas.
- `cerebro`: o caderno de memória longa, na versão simples do cérebro do Rafael. É um
  arquivo só, roda com o Python que já vem no Hermes e nada sai do computador.
- **Toda instalação usa o endereço completo** (`https://raw.githubusercontent.com/...`).
  O atalho `Rafaelrr5/...` quebra quando mais de 60 pedidos saem da mesma internet.

## Pendências antes de marcar a próxima oficina

1. Instalar com o guia num notebook Windows 11 de verdade, com antivírus ligado.
2. Testar o login com uma conta ChatGPT gratuita e uma chave Gemini gratuita.
