#!/bin/bash
# Prepara o computador para a oficina Hermes do Minds of the Future (macOS e Linux).
# Confere o que já existe e só instala o que falta. Pode rodar de novo sem problema.
#   curl -fsSL https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/main/oficina/preparar.sh | bash
#   wget -qO- https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/main/oficina/preparar.sh | bash
set -u
ok()   { printf '  [ok] %s\n' "$*"; }
faz()  { printf '  [..] %s\n' "$*"; }
para() { printf '\n  [X] %s\n\n' "$*"; exit 1; }
tem()  { command -v "$1" >/dev/null 2>&1; }

main() {
echo ""
echo "  Preparando o computador para a oficina Hermes"
echo ""

SO=$(uname -s); ARQ=$(uname -m)
export PATH="$HOME/.local/bin:$PATH"

# 1. Já instalado? Então não baixa nada.
if tem hermes && hermes --version >/dev/null 2>&1; then
  ok "O Hermes já está instalado: $(hermes --version 2>/dev/null | head -1)"
  ok "Nada para fazer. Pode ir para a oficina."
  exit 0
fi

# 2. Computador compatível?
if [ "$SO" = Darwin ] && [ "$ARQ" != arm64 ]; then
  para "Este Mac tem processador Intel. Hoje o Hermes não instala nele. Avise no grupo: você faz a oficina em dupla."
fi
LIVRE_MB=$(df -Pm "$HOME" | awk 'NR==2 {print $4}')
if [ "${LIVRE_MB:-0}" -lt 6000 ]; then
  para "Falta espaço: há $((LIVRE_MB / 1024)) GB livres e o Hermes precisa de 6 GB. Libere espaço e rode de novo."
fi
ok "Espaço livre: $((LIVRE_MB / 1024)) GB"

# 3. Peças que o instalador do Hermes exige: git e curl (e, no Linux, libatomic).
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
    if   tem apt-get; then PK="sudo apt-get install -y"; NOMES=$(echo $FALTA | sed 's/libatomic/libatomic1/'); sudo apt-get update -qq || true
    elif tem dnf;     then PK="sudo dnf install -y";     NOMES=$FALTA
    elif tem pacman;  then PK="sudo pacman -S --noconfirm"; NOMES=$(echo $FALTA | sed 's/libatomic/gcc-libs/')
    elif tem zypper;  then PK="sudo zypper -n install";  NOMES=$(echo $FALTA | sed 's/libatomic/libatomic1/')
    else para "Não reconheci o gerenciador de pacotes. Instale:$FALTA e rode de novo."; fi
    $PK $NOMES || para "Não consegui instalar:$FALTA. Mande um print desta tela no grupo."
    ok "Instalado:$FALTA"
  fi
fi

# 4. Hermes, versão enxuta (sem navegador automático e sem controle de tela).
faz "Instalando o Hermes. Leva de 5 a 15 minutos e às vezes parece parado. Não feche."
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --non-interactive --skip-browser --skip-computer-use
if tem hermes && hermes --version >/dev/null 2>&1; then
  echo ""
  ok "Pronto: $(hermes --version | head -1)"
  ok "Feche esta janela, abra outra, digite: hermes --version"
  ok "e mande um print no grupo da oficina."
else
  para "A instalação do Hermes não terminou. Mande um print desta tela no grupo."
fi
}
main "$@"
