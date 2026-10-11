#!/bin/bash
# Prepara o computador para usar o Hermes (macOS e Linux), sem precisar de ninguém olhando:
# confere o que já existe, instala só o que falta, espera a internet voltar se ela cair,
# deixa as habilidades e o cérebro prontos e confere tudo no fim. Pode rodar de novo.
#   curl -fsSL https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/main/oficina/preparar.sh | bash
#   wget -qO- https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/main/oficina/preparar.sh | bash
set -u
REF="${PREPARAR_REF:-main}"                       # só os testes automáticos mudam isto
RAW_MH="https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/$REF"
RAW_AC="https://raw.githubusercontent.com/Rafaelrr5/agent-cortex/main"
FERR="$HOME/.hermes-ferramentas"                  # git/curl próprios, quando o sistema não tem
SO=$(uname -s); ARQ=$(uname -m)

ok()   { printf '  [ok] %s\n' "$*"; }
faz()  { printf '  [..] %s\n' "$*"; }
para() { printf '\n  [X] %s\n\n' "$*"; exit 1; }
tem()  { command -v "$1" >/dev/null 2>&1; }
baixar() {  # baixar URL ARQUIVO
  if tem curl; then curl -fsSL --retry 3 --connect-timeout 20 "$1" -o "$2"; else wget -q --tries=3 --timeout=20 -O "$2" "$1"; fi
}
tem_internet() {
  if tem curl; then curl -fsI --max-time 15 https://github.com >/dev/null 2>&1
  else wget -q --spider --timeout=15 https://github.com >/dev/null 2>&1; fi
}
esperar_internet() {  # espera até 6 horas, sem perguntar nada
  tem_internet && return 0
  faz "Sem internet agora. Vou esperando ela voltar; pode deixar o computador ligado."
  t=0
  until tem_internet; do
    sleep 20; t=$((t + 20))
    [ $((t % 300)) -eq 0 ] && faz "ainda sem internet ($((t / 60)) min). Continuo esperando."
    [ "$t" -ge 21600 ] && return 1
  done
  ok "A internet voltou"
}
tentar() {  # tentar DESCRIÇÃO MÁXIMO COMANDO...
  desc="$1"; max="$2"; shift 2; n=1
  while :; do
    "$@" && return 0
    [ "$n" -ge "$max" ] && return 1
    faz "$desc não terminou (tentativa $n de $max). Vou tentar de novo, continuando de onde parou."
    esperar_internet || return 1
    sleep $(( n * 15 > 120 ? 120 : n * 15 )); n=$((n + 1))
  done
}

# Quando o script chega por "curl | bash", a entrada é o próprio script: a pergunta final
# lê o teclado pelo terminal (/dev/tty). Sem terminal, não pergunta nada.
if (exec </dev/tty) 2>/dev/null; then TECLADO=/dev/tty; else TECLADO=/dev/null; fi

manter_acordado() {
  if [ "$SO" = Darwin ] && tem caffeinate; then caffeinate -dims -w $$ >/dev/null 2>&1 &
  elif tem systemd-inhibit; then
    systemd-inhibit --what=sleep:idle --who=Hermes --why="Instalando o Hermes" sleep 21600 >/dev/null 2>&1 &
    INIBIDOR=$!; trap 'kill $INIBIDOR 2>/dev/null' EXIT
  fi
}

# git e curl próprios, sem administrador e sem janela (micromamba, conda-forge).
ferramentas_proprias() {  # ferramentas_proprias PACOTE...
  case "$SO-$ARQ" in
    Darwin-arm64) PLAT=osx-arm64 ;; Linux-x86_64) PLAT=linux-64 ;; Linux-aarch64) PLAT=linux-aarch64 ;;
    *) return 1 ;;
  esac
  mkdir -p "$FERR" "$HOME/.local/bin"
  if [ ! -x "$FERR/bin/micromamba" ]; then
    tentar "Download do ajudante" 5 baixar "https://micro.mamba.pm/api/micromamba/$PLAT/latest" "$FERR/mm.tar.bz2" || return 1
    tar -xjf "$FERR/mm.tar.bz2" -C "$FERR" bin/micromamba || return 1
    rm -f "$FERR/mm.tar.bz2"
  fi
  tentar "Download de $*" 5 "$FERR/bin/micromamba" create -y -q -r "$FERR/raiz" -p "$FERR/env" -c conda-forge "$@" >/dev/null || return 1
  for p in "$@"; do
    printf '#!/bin/sh\nexec "%s/env/bin/%s" "$@"\n' "$FERR" "$p" > "$HOME/.local/bin/$p"
    chmod +x "$HOME/.local/bin/$p"
  done
  hash -r
}

pecas() {
  if [ "$SO" = Darwin ]; then
    if git --version >/dev/null 2>&1 && xcode-select -p >/dev/null 2>&1; then ok "git já disponível"; return 0; fi
    if [ -x "$HOME/.local/bin/git" ] && git --version >/dev/null 2>&1; then ok "git já disponível"; return 0; fi
    faz "Baixando o git (uns 40 MB), sem precisar das ferramentas de desenvolvedor da Apple"
    ferramentas_proprias git || para "Não consegui baixar o git. Mande um print desta tela no grupo."
    git --version >/dev/null 2>&1 || para "O git baixado não abriu. Mande um print desta tela no grupo."
    ok "git pronto"
    return 0
  fi
  FALTA=""
  tem git  || FALTA="$FALTA git"
  tem curl || FALTA="$FALTA curl"
  ATOMIC=1
  { ldconfig -p 2>/dev/null | grep -q 'libatomic\.so\.1'; } || ls /usr/lib*/libatomic.so.1 /usr/lib/*/libatomic.so.1 >/dev/null 2>&1 || ATOMIC=0
  [ "$ATOMIC" = 0 ] && FALTA="$FALTA libatomic"
  if [ -z "$FALTA" ]; then ok "git, curl e libatomic já instalados"; return 0; fi
  faz "Faltam:$FALTA"
  if sudo -n true 2>/dev/null; then   # só se der sem pedir senha
    if   tem apt-get; then sudo -n apt-get update -qq </dev/null; PK="sudo -n apt-get install -y -qq"; NOMES=$(echo $FALTA | sed 's/libatomic/libatomic1/')
    elif tem dnf;     then PK="sudo -n dnf install -y -q"; NOMES=$FALTA
    elif tem pacman;  then PK="sudo -n pacman -S --noconfirm"; NOMES=$(echo $FALTA | sed 's/libatomic/gcc-libs/')
    elif tem zypper;  then PK="sudo -n zypper -n install"; NOMES=$(echo $FALTA | sed 's/libatomic/libatomic1/')
    else PK=""; fi
    if [ -n "$PK" ] && tentar "Instalação de$FALTA" 3 $PK $NOMES </dev/null >/dev/null; then ok "Instalado:$FALTA"; return 0; fi
  fi
  if [ "$ATOMIC" = 0 ]; then
    para "Falta uma peça do sistema (libatomic) que só o administrador do computador instala. Peça para ele rodar: sudo apt install libatomic1 (ou o equivalente) e rode este comando de novo."
  fi
  faz "Baixando$FALTA na sua pasta, sem precisar de senha"
  ferramentas_proprias $FALTA || para "Não consegui baixar:$FALTA. Mande um print desta tela no grupo."
  ok "Pronto:$FALTA"
}

instalar_hermes_uma_vez() {
  set -o pipefail
  curl -fsSL --retry 3 https://hermes-agent.nousresearch.com/install.sh \
    | bash -s -- --non-interactive --skip-browser --skip-computer-use
  r=$?; set +o pipefail; hash -r
  [ $r -eq 0 ] && tem hermes && hermes --version >/dev/null 2>&1 && hermes pm doctor >/dev/null 2>&1
}

instalar() {
  if [ "$SO" = Darwin ] && [ "$ARQ" != arm64 ]; then
    para "Este Mac tem processador Intel. Hoje o Hermes não instala nele. Avise no grupo: você faz a oficina em dupla."
  fi
  LIVRE_MB=$(df -Pm "$HOME" | awk 'NR==2 {print $4}')
  [ "${LIVRE_MB:-0}" -lt 6000 ] && para "Falta espaço: há $((LIVRE_MB / 1024)) GB livres e o Hermes precisa de 6 GB. Libere espaço e rode de novo."
  ok "Espaço livre: $((LIVRE_MB / 1024)) GB"
  esperar_internet || para "Fiquei 6 horas sem internet. Rode este comando de novo quando ela voltar."
  pecas
  faz "Instalando o Hermes. Leva de 5 a 30 minutos, conforme a internet. Pode deixar baixando."
  tentar "A instalação do Hermes" 8 instalar_hermes_uma_vez \
    || para "A instalação do Hermes não terminou depois de várias tentativas. Rode este comando de novo; ele continua de onde parou."
}

conferir() {
  echo ""
  faz "Conferindo a instalação"
  tem hermes && hermes --version >/dev/null 2>&1 || return 1
  ok "O Hermes abre: $(hermes --version | head -1)"
  hermes pm doctor >/dev/null 2>&1 || return 1
  ok "Peças do Hermes conferidas"
  grep -qs '\.local/bin' "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile" || return 1
  ok "O comando hermes vai funcionar nas próximas janelas do terminal"
}

habilidade() {  # habilidade NOME URL   (confere pela pasta: a lista do Hermes corta nomes longos)
  PASTA="${HERMES_HOME:-$HOME/.hermes}/skills/$1/SKILL.md"
  if [ -s "$PASTA" ]; then ok "Habilidade $1 já instalada"; return 0; fi
  if tentar "A habilidade $1" 5 sh -c "hermes skills install '$2' --yes </dev/null >/dev/null 2>&1; [ -s '$PASTA' ]"; then
    ok "Habilidade $1 instalada"
  else
    faz "A habilidade $1 não instalou agora; dá para instalar depois, na oficina."
  fi
}

configurar() {
  echo ""
  faz "Deixando tudo pronto para o primeiro uso"
  hermes config set approvals.mode manual >/dev/null 2>&1 && ok "O Hermes vai pedir sua licença antes de ações arriscadas"
  hermes config set display.language pt >/dev/null 2>&1 && ok "Mensagens do Hermes em português"
  habilidade boas-vindas "$RAW_MH/skills/boas-vindas/SKILL.md"
  habilidade cerebro "$RAW_MH/skills/cerebro/SKILL.md"
  habilidade recall-and-claim-verification "$RAW_AC/skills/recall-and-claim-verification/SKILL.md"
  habilidade measurement-validity "$RAW_AC/skills/measurement-validity/SKILL.md"
  mkdir -p "$HOME/.cortex"
  if [ -s "$HOME/.cortex/cortex.py" ]; then ok "Cérebro já baixado"
  elif tentar "O cérebro" 5 baixar "$RAW_AC/cortex.py" "$HOME/.cortex/cortex.py"; then ok "Cérebro baixado"
  else faz "O cérebro não baixou agora; ele baixa sozinho no primeiro uso."; fi
}

conversa_ok() {
  # A pergunta não contém a resposta: assim um erro que repete a pergunta não passa por sucesso.
  hermes chat -q "Quanto é dois mais três? Responda só com o número escrito por extenso." --oneshot </dev/null 2>&1 | grep -qi cinco
}

conectar() {  # nunca trava: a escolha espera 2 minutos e segue sozinha
  echo ""
  faz "Conferindo se o Hermes já conversa com uma inteligência artificial"
  if conversa_ok; then ok "O Hermes já está conectado e respondendo"; return 0; fi
  conta="${CONTA:-}"
  if [ -z "$conta" ] && [ "$TECLADO" = /dev/tty ]; then
    echo ""
    echo "  Se você estiver aqui, já dá para conectar sua conta (opcional):"
    echo "    1) ChatGPT (OpenAI)     2) Claude (Anthropic)"
    printf "  Digite 1 ou 2 e Enter. Sem resposta em 2 minutos, eu termino sem conectar: "
    op=""; read -r -t "${PREPARAR_ESPERA:-120}" op </dev/tty || true; echo ""
    case "$op" in 1) conta=chatgpt ;; 2) conta=claude ;; esac
  fi
  case "$conta" in
    chatgpt) PROV=openai-codex
             faz "Abra o endereço que vai aparecer, entre na sua conta do ChatGPT e digite o código." ;;
    claude)  PROV=anthropic
             faz "O navegador vai abrir. Entre na sua conta do Claude, autorize e cole aqui o código que aparecer." ;;
    *) return 1 ;;
  esac
  LIMITE=""; [ -n "${PREPARAR_LIMITE:-}" ] && tem timeout && LIMITE="timeout $PREPARAR_LIMITE"
  $LIMITE hermes auth add "$PROV" --type oauth <"$TECLADO"
  hermes config set model.provider "$PROV" >/dev/null 2>&1
  faz "Testando uma conversa de verdade"
  if conversa_ok; then ok "Conectado: o Hermes respondeu pela sua conta"; return 0; fi
  if [ "$PROV" = anthropic ] && hermes auth status anthropic 2>/dev/null | grep -q 'logged in'; then
    faz "O login no Claude deu certo, mas a conta não liberou conversa pelo Hermes. O plano Pro não libera esse uso."
  else faz "O login não terminou."; fi
  return 1
}

main() {
  echo ""
  echo "  Preparando o computador para o Hermes. Pode deixar rodando: não precisa responder nada."
  echo ""
  mkdir -p "$HOME/.local/bin"; export PATH="$HOME/.local/bin:$PATH"
  manter_acordado
  if tem hermes && hermes --version >/dev/null 2>&1; then
    ok "O Hermes já está instalado: $(hermes --version 2>/dev/null | head -1)"
  else
    instalar
  fi
  if ! conferir; then
    faz "A conferência achou um problema. Vou refazer a instalação uma vez."
    tentar "A instalação do Hermes" 4 instalar_hermes_uma_vez && conferir \
      || para "A instalação não ficou certa. Mande um print desta tela no grupo."
  fi
  configurar
  if conectar; then
    echo ""
    ok "Tudo pronto e conectado. Abra uma janela nova do terminal e digite: hermes"
  else
    echo ""
    ok "Tudo instalado. Falta só conectar sua conta, o que leva 2 minutos na oficina:"
    ok "lá você cola este mesmo comando de novo e escolhe ChatGPT ou Claude."
  fi
  ok "Mande um print desta tela no grupo."
}
main "$@"
