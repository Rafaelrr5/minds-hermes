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

## O que não deu para testar aqui

- Notebook Windows 10/11 doméstico com antivírus ativo (os testes rodaram em Windows Server).
- Mac sem as ferramentas de desenvolvedor da Apple: os Macs de teste já vêm com elas.
- Login real com conta ChatGPT gratuita, conta Claude Pro e chave Gemini gratuita.
- Velocidade em Wi-Fi ruim. A conta acima vem do tamanho medido, não de uma simulação.
