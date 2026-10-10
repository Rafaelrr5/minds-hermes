---
name: minds-cerebro
description: "Use para instalar e usar o cérebro de longo prazo do minicurso Minds."
version: 1.0.0
author: Rafael Rocha Ribeiro (github.com/Rafaelrr5) - Minds of the Future, FACC/UFJF
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [memoria, cerebro, minds, iniciante, pt-br]
    related_skills: [minds-boas-vindas]
---

# Cérebro Minds

O Hermes já tem uma memória curta, que entra em toda conversa. O **cérebro** é a memória
longa: um caderno sem limite de tamanho, onde cada fato fica guardado e só é lido quando
a conversa precisa dele. É a mesma ideia que o Rafael usa no dia a dia, em versão simples:
um arquivo, sem programa extra para instalar e sem nada saindo do computador da pessoa.

## Regras de conversa

- Português do Brasil, frases curtas, sem jargão. Fale do efeito para a pessoa
  ("assim eu lembro disso daqui a um mês"), nunca de arquivo ou comando.
- **Nunca guarde** senha, chave de acesso, documento, endereço, telefone, dado de saúde
  ou dado de outra pessoa. Se a pessoa pedir para guardar algo assim, explique que não
  guarda e por quê.
- Nunca diga que guardou ou achou algo sem ter visto o resultado real.

## Como rodar o cérebro (vale para Windows, macOS e Linux)

Use **sempre a ferramenta `execute_code`**, nunca o terminal. Ela roda com o Python que
veio junto com o Hermes, então funciona igual em qualquer sistema e não depende de a
pessoa ter Python instalado.

```python
import os, subprocess, sys, urllib.request
from pathlib import Path

home = Path(os.environ.get("HERMES_HOME") or "")
if not home.name:
    home = Path(os.environ["LOCALAPPDATA"]) / "hermes" if os.name == "nt" else Path.home() / ".hermes"
pasta = home / "cerebro"
pasta.mkdir(parents=True, exist_ok=True)
cortex = pasta / "cortex.py"
if not cortex.exists():
    url = "https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/main/cerebro/cortex.py"
    urllib.request.urlretrieve(url, cortex)

def cerebro(*args):
    env = dict(os.environ, CORTEX_HOME=str(pasta), PYTHONIOENCODING="utf-8")
    r = subprocess.run([sys.executable, str(cortex), *args], capture_output=True,
                       text=True, encoding="utf-8", env=env)
    print(r.stdout or r.stderr)

cerebro("stats")
```

Depois, no mesmo bloco, chame `cerebro(...)`:

| Para | Chamada |
|---|---|
| Guardar um fato | `cerebro("add", "Ana estuda enfermagem no 3º período", "--category", "perfil")` |
| Buscar | `cerebro("search", "enfermagem", "-n", "5")` |
| Corrigir um fato | `cerebro("supersede", "<hash>", "texto corrigido")` (o hash aparece na busca) |
| Ver quantos fatos há | `cerebro("stats")` |

Categorias úteis: `perfil`, `preferencia`, `rotina`, `projeto`, `decisao`.

## Instalar (primeira vez)

1. Explique em até três linhas: "Vou criar um caderno de memória longa. Ele fica só no seu
   computador. Eu consulto quando precisar, sem você ter que repetir as coisas."
2. Rode o bloco acima. A saída precisa mostrar `facts` ou um total de fatos. Se der erro de
   internet, diga que o caderno será criado quando a internet voltar e siga a conversa.
3. Guarde **um** fato de teste que a pessoa escolher, busque por uma palavra dele e mostre
   que voltou. Só então diga que o cérebro está funcionando.

## Usar no dia a dia

- **Antes de responder** sobre a vida, os estudos, o trabalho ou um projeto da pessoa,
  busque no cérebro com duas ou três palavras-chave. A busca é por palavra: use as palavras
  que a pessoa usaria, não sinônimos.
- **Guarde** quando aparecer algo que vai valer daqui a um mês: uma preferência, um prazo
  recorrente, uma decisão com o motivo, um jeito de fazer que deu certo.
- **Um fato por entrada**, frase completa que se entende sozinha
  ("Prefere receber o resumo da semana na sexta à noite"), nunca uma lista.
- Quando a pessoa corrigir algo, use `supersede`: o fato antigo fica no histórico e
  para de aparecer na busca.

## Verificação (antes de dizer que terminou)

- [ ] `cerebro("stats")` mostrou o total de fatos.
- [ ] O fato de teste voltou numa busca real.
- [ ] Nada sensível foi guardado.
