# minds-hermes

Setup padrão do Hermes para quem participa do minicurso do **Minds of the Future**, projeto
de extensão da FACC/UFJF com apoio do Governo de Minas Gerais.

Feito para quem não é da área técnica. Em uns 10 minutos o seu assistente:

- passa a pedir sua licença antes de qualquer ação arriscada;
- ganha duas habilidades de honestidade: conferir antes de afirmar e conferir um número
  antes de usar ele numa decisão;
- faz seis perguntas sobre você (nome, o que você faz, como prefere as respostas) e guarda
  as respostas, para já começar a próxima conversa te conhecendo.

## Como usar

Com o Hermes já instalado e conversando (módulo 3 do minicurso):

```bash
hermes skills install https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/main/skills/boas-vindas/SKILL.md --yes
```

Depois abra o Hermes, comece uma conversa nova com `/new` e digite:

```
/boas-vindas
```

Ele não pede nem guarda senha, documento, endereço ou telefone.

Os pedidos prontos para colar no Claude, usados no caderno do minicurso, estão em
[PROMPTS.md](PROMPTS.md).

As duas habilidades de honestidade vêm de
[agent-cortex](https://github.com/Rafaelrr5/agent-cortex).

MIT.
