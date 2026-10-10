# Testes de instalação da oficina (10/10/2026)

Máquinas limpas do GitHub Actions, instalando como um participante sem permissão de
administrador. Workflow: `.github/workflows/oficina-testes.yml`. Logs brutos no branch
`oficina-resultados`.

## O que foi medido

| Sistema | Instalou sem admin | Download | Disco ocupado | Tempo (rede de datacenter) |
|---|---|---|---|---|
| Windows Server 2022, completo | sim | 2.081 MB | 4,4 GB | 6 a 7 min |
| Windows Server 2022, enxuto | sim | 1.640 MB | 3,9 GB | 7 a 10 min |
| Windows Server 2025, completo | sim | 2.085 MB | 4,4 GB | 9 min |
| Windows Server 2025, enxuto | sim | 1.621 MB | 3,9 GB | 7 a 9 min |
| macOS 15 Apple Silicon, completo | sim | 783 MB | 2,6 GB | 2 min |
| macOS 15 Apple Silicon, enxuto | sim | 513 a 536 MB | 2,1 GB | 1 a 2 min |
| macOS 15 Intel | **não instala** | — | — | falha em 2 min |
| Ubuntu 24.04, completo | sim | 1.991 MB | 4,1 GB | 1 min |
| Ubuntu 24.04, enxuto | sim | 1.516 MB | 3,6 GB | 1 a 2 min |

"Enxuto" = `-SkipBrowser -SkipComputerUse` (Windows) ou `--skip-browser --skip-computer-use`
(macOS/Linux): tira o navegador automático e o controle de tela, que a oficina não usa.

## Achados

1. **A instalação não precisa de administrador.** No Windows a conta de teste era usuária
   comum, com a política de scripts no padrão dos notebooks (`Restricted`). O instalador
   rodou, e o `hermes` funcionou no PowerShell e no Prompt de Comando.
2. **O peso é o problema.** São de 1,5 a 2 GB por computador no Windows e no Linux. Com 20
   pessoas, isso dá de 30 a 40 GB passando pela internet do local. Esse foi o gargalo da
   última oficina.
3. **Mac Intel não instala hoje.** Uma dependência de criptografia não tem versão pronta
   para Intel e tenta compilar, o que exige ferramentas que o participante não tem. O Mac
   com chip Apple (M1 a M4) instala normal.
4. **Instalar habilidade pelo atalho `Rafaelrr5/...` quebra em sala de aula.** O atalho
   consulta um serviço do GitHub limitado a 60 pedidos por hora por internet. O teste gastou
   essa cota antes, como 20 pessoas no mesmo Wi-Fi gastariam, e o atalho falhou nos três
   sistemas. O endereço completo (`https://raw.githubusercontent.com/...SKILL.md`) instalou
   em todos, mesmo sem cota.
5. **O cérebro funciona nos três sistemas** usando o Python que vem com o Hermes, sem
   instalar mais nada. A primeira versão da habilidade foi barrada pela verificação de
   segurança do Hermes. A versão atual passou como `SAFE`.
6. **O `hermes doctor` mostra "Found 5 issues" numa instalação nova e correta.** Os avisos
   são sobre provedor ainda não configurado e alertas de pacotes. É preciso avisar a turma
   que isso é normal, para ninguém achar que deu errado.
7. **O login dos provedores não exige programa extra.** O ChatGPT mostra um código para
   digitar no site e o Claude mostra um link. Os dois fluxos foram abertos até essa tela.
   O login real com cada tipo de conta **não foi testado**.

## Segunda rodada: máquinas sem nada instalado

As máquinas da primeira rodada já vinham com Python, Node, Git e ferramentas de
desenvolvedor. Na segunda rodada (workflow `oficina-limpa.yml`, logs no branch
`oficina-resultados-limpo`):

- **Windows:** o caminho de busca ficou só com as pastas do Windows, e Git, Node, Python e
  Rust foram tirados do lugar.
- **Mac com chip Apple:** as ferramentas de desenvolvedor da Apple e o Xcode foram
  escondidos, e a conta de teste só via os programas do próprio macOS.
- **Linux:** Ubuntu 24.04 e Fedora 41 zerados, em contêiner.

Cada máquina registrou o que tinha antes. Depois rodou o comando do guia
(`oficina/preparar.*`) e rodou de novo, para provar que a segunda vez não instala nada.

| Máquina | O que tinha | O que o preparar instalou | 2ª vez |
|---|---|---|---|
| Windows Server 2022/2025, usuária comum | nada de desenvolvedor | só o Hermes (1,6 GB) | não baixou nada |
| Mac chip Apple, sem ferramentas da Apple | só o macOS | ferramentas da Apple (1.003 MB, ~2 min) e o Hermes. Total: 1,4 GB | não baixou nada |
| Mac Intel | — | nada: parou com o aviso de dupla | — |
| Ubuntu zerado (só wget) | sem git, sem curl | git, curl e libatomic, depois o Hermes | não baixou nada |
| Ubuntu que já tinha git e curl | git, curl, libatomic | só o Hermes | não baixou nada |
| Fedora zerado | curl | git e libatomic, depois o Hermes | não baixou nada |

Nos três sistemas o Hermes baixou o próprio Python e não usou o do computador. Nos três,
o cérebro e as habilidades pelo endereço completo funcionaram depois da instalação.

Limitações desta rodada:

- No Mac de teste, a instalação das ferramentas da Apple foi feita pelo comando que essa
  janela usa, porque uma máquina de teste não clica em botão.
- No Linux, a conta de teste podia instalar pacotes sem digitar senha; na vida real o
  computador pede a senha.

## Terceira rodada: conferência e login no fim do preparar

Depois de instalar, o `preparar` confere três coisas: se o Hermes abre, se as peças estão
íntegras (`hermes pm doctor`) e se o comando vai funcionar nas próximas janelas do terminal.
Em seguida faz uma pergunta de teste ao Hermes. Se não houver resposta, pergunta qual conta
usar (1 ChatGPT, 2 Claude), abre o login e repete a pergunta de teste.

A pergunta de teste é "quanto é dois mais três, por extenso", e o script procura "cinco" na
resposta. A primeira versão pedia para o Hermes repetir uma palavra, e o teste passava mesmo
sem conta conectada, porque a mensagem de erro repetia a pergunta. O CI pegou isso, e foi
corrigido.

| Máquina | Conferência | Tela de login apareceu | Mensagem final |
|---|---|---|---|
| Windows 2025 (ChatGPT, login direto no console) | ok | endereço + código; esperou os ~15 min do código e seguiu | "conexão fica para a oficina" |
| Windows 2022 (Claude, login direto no console) | ok | link (o navegador abriu sozinho), esperando o código colado | — (a máquina de teste não tem teclado e ficou esperando) |
| Mac chip Apple (Claude) | ok | link | "conexão fica para a oficina" |
| Ubuntu zerado, Ubuntu com git, Fedora | ok | endereço + código / link | "conexão fica para a oficina" |
| Linux com terminal de verdade (VM) | ok | o menu 1/2 funcionou, inclusive quando o comando chega por `curl \| bash` | "conexão fica para a oficina" |

Nas máquinas de teste ninguém completa o login, então todas terminaram no caminho
"conexão fica para a oficina". O caminho com o login completo, que termina em "Tudo pronto",
foi conferido só até o teste de conversa, numa máquina que já tinha conta conectada (a VM).
**O login real até o fim ainda não foi feito com uma conta de participante.**

## O que não deu para testar aqui

- Notebook Windows 10/11 doméstico com antivírus ativo (os testes rodaram em Windows Server).
- Linux de laboratório onde a pessoa não pode instalar pacotes (sem senha de administrador).
- Login real com conta ChatGPT gratuita, conta Claude Pro e chave Gemini gratuita.
- Velocidade em Wi-Fi ruim. A conta acima vem do tamanho medido, não de uma simulação.
