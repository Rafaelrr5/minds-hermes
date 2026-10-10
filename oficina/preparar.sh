#!/bin/bash
# Prepara o computador para a oficina Hermes do Minds of the Future (macOS e Linux).
# Confere o que já existe e só instala o que falta. No fim confere a instalação e abre o
# login do ChatGPT ou do Claude. Pode rodar de novo sem problema.
#   curl -fsSL https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/main/oficina/preparar.sh | bash
#   wget -qO- https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/main/oficina/preparar.sh | bash
set -u
ok()   { printf '  [ok] %s\n' "$*"; }
faz()  { printf '  [..] %s\n' "$*"; }
para() { printf '\n  [X] %s\n\n' "$*"; exit 1; }
tem()  { command -v "$1" >/dev/null 2>&1; }

# Quando o script chega por "curl | bash", a entrada é o próprio script: perguntas e
# logins leem o teclado pelo terminal (/dev/tty). Sem terminal, não pergunta nada.
if (exec </dev/tty) 2>/dev/null; then TECLADO=/dev/tty; else TECLADO=/dev/null; fi

instalar() {
  SO=$(uname -s); ARQ=$(uname -m)
  if [ "$SO" = Darwin ] && [ "$ARQ" != arm64 ]; then
    para "Este Mac tem processador Intel. Hoje o Hermes não instala nele. Avise no grupo: você faz a oficina em dupla."
  fi
  LIVRE_MB=$(df -Pm "$HOME" | awk 'NR==2 {print $4}')
  if [ "${LIVRE_MB:-0}" -lt 6000 ]; then
    para "Falta espaço: há $((LIVRE_MB / 1024)) GB livres e o Hermes precisa de 6 GB. Libere espaço e rode de novo."
  fi
  ok "Espaço livre: $((LIVRE_MB / 1024)) GB"

  # Peças que o instalador do Hermes exige: git e curl (e, no Linux, libatomic).
  if [ "$SO" = Darwin ]; then
    if xcode-select -p >/dev/null 2>&1 && git --version >/dev/null 2>&1; then
      ok "Ferramentas da Apple já instaladas"
    else
      faz "Faltam as ferramentas de desenvolvedor da Apple (traz o git)."
      faz "Vai abrir uma janela: clique em Instalar e aceite. Pode levar de 5 a 20 minutos."
      xcode-select --install >/dev/null 2>&1 || true
      espera=0
      until xcode-select -p >/dev/null 2>&1 && git --version >/dev/null 2>&1; do
        sleep 15; espera=$((espera + 15))
        [ $((espera % 120)) -eq 0 ] && faz "aguardando as ferramentas da Apple terminarem... ($((espera / 60)) min)"
        [ "$espera" -ge 3600 ] && para "As ferramentas da Apple não terminaram em 1 hora. Rode este comando de novo depois que a janela concluir."
      done
      ok "Ferramentas da Apple instaladas"
    fi
  else
    FALTA=""
    tem git  || FALTA="$FALTA git"
    tem curl || FALTA="$FALTA curl"
    if ! { ldconfig -p 2>/dev/null | grep -q 'libatomic\.so\.1'; } && ! ls /usr/lib*/libatomic.so.1 /usr/lib/*/libatomic.so.1 >/dev/null 2>&1; then
      FALTA="$FALTA libatomic"
    fi
    if [ -z "$FALTA" ]; then
      ok "git, curl e libatomic já instalados"
    else
      faz "Faltam:$FALTA. Vou instalar só isso; o computador pode pedir a sua senha."
      if   tem apt-get; then PK="sudo apt-get install -y"; NOMES=$(echo $FALTA | sed 's/libatomic/libatomic1/'); sudo apt-get update -qq </dev/null || true
      elif tem dnf;     then PK="sudo dnf install -y";     NOMES=$FALTA
      elif tem pacman;  then PK="sudo pacman -S --noconfirm"; NOMES=$(echo $FALTA | sed 's/libatomic/gcc-libs/')
      elif tem zypper;  then PK="sudo zypper -n install";  NOMES=$(echo $FALTA | sed 's/libatomic/libatomic1/')
      else para "Não reconheci o gerenciador de pacotes. Instale:$FALTA e rode de novo."; fi
      $PK $NOMES </dev/null || para "Não consegui instalar:$FALTA. Mande um print desta tela no grupo."
      ok "Instalado:$FALTA"
    fi
  fi

  faz "Instalando o Hermes. Leva de 5 a 15 minutos e às vezes parece parado. Não feche."
  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --non-interactive --skip-browser --skip-computer-use
}

conferir() {
  echo ""
  faz "Conferindo a instalação"
  tem hermes && hermes --version >/dev/null 2>&1 || para "O Hermes não abre. Mande um print desta tela no grupo."
  ok "O Hermes abre: $(hermes --version | head -1)"
  if hermes pm doctor >/dev/null 2>&1; then ok "Peças do Hermes conferidas"
  else para "Uma peça do Hermes veio com defeito. Rode este comando de novo; se repetir, mande um print no grupo."; fi
  if grep -qs '\.local/bin' "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; then
    ok "O comando hermes vai funcionar nas próximas janelas do terminal"
  else
    para "O terminal não vai achar o comando hermes. Mande um print desta tela no grupo."
  fi
}

conversa_ok() {
  hermes chat -q "Responda apenas com a palavra: funcionando" --oneshot </dev/null 2>&1 | grep -qi funcionando
}

conectar() {
  echo ""
  faz "Conferindo se o Hermes já conversa com uma inteligência artificial"
  if conversa_ok; then ok "O Hermes já está conectado e respondendo"; return 0; fi

  conta="${CONTA:-}"
  if [ -z "$conta" ] && [ "$TECLADO" = /dev/tty ]; then
    echo ""
    echo "  Com qual conta você quer usar o Hermes?"
    echo "    1) ChatGPT (OpenAI)"
    echo "    2) Claude (Anthropic)"
    printf "  Digite 1 ou 2 e aperte Enter: "
    read -r op </dev/tty
    case "$op" in 1) conta=chatgpt ;; 2) conta=claude ;; esac
  fi
  case "$conta" in
    chatgpt) PROV=openai-codex
             faz "Vai aparecer um endereço e um código. Abra o endereço no navegador, entre na sua conta do ChatGPT e digite o código." ;;
    claude)  PROV=anthropic
             faz "Vai aparecer um link. Abra no navegador, entre na sua conta do Claude, autorize e cole aqui o código que aparecer." ;;
    *) faz "Login não feito agora. Na oficina, rode: hermes model"; return 1 ;;
  esac
  LIMITE=""; [ -n "${PREPARAR_LIMITE:-}" ] && tem timeout && LIMITE="timeout $PREPARAR_LIMITE"
  $LIMITE hermes auth add "$PROV" --type oauth <"$TECLADO"
  hermes config set model.provider "$PROV" >/dev/null 2>&1
  faz "Testando uma conversa de verdade"
  if conversa_ok; then
    ok "Conectado: o Hermes respondeu pela sua conta"
  elif [ "$PROV" = anthropic ]; then
    faz "O Hermes não conseguiu conversar pela conta do Claude. O plano Pro não libera esse uso."
    faz "Rode este comando de novo e escolha ChatGPT, ou deixe para a oficina."
    return 1
  else
    faz "O login não terminou. Rode este comando de novo ou deixe para a oficina."
    return 1
  fi
}

main() {
  echo ""
  echo "  Preparando o computador para a oficina Hermes"
  echo ""
  export PATH="$HOME/.local/bin:$PATH"
  if tem hermes && hermes --version >/dev/null 2>&1; then
    ok "O Hermes já está instalado: $(hermes --version 2>/dev/null | head -1)"
  else
    instalar
  fi
  conferir
  if conectar; then
    echo ""
    ok "Tudo pronto. Feche esta janela, abra outra e digite: hermes"
    ok "Mande um print dessa tela no grupo da oficina."
  else
    echo ""
    ok "O Hermes está instalado. A conexão com a conta fica para a oficina."
    ok "Feche esta janela, abra outra, digite hermes --version e mande um print no grupo."
  fi
}
main "$@"
