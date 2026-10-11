#!/bin/bash
# Runs AS the student on a stripped machine/container (macOS or Linux).
# inventory -> preparar.sh as in the guide (CONTA set: login screen is shown and capped)
# -> inventory -> preparar.sh again with no account and no keyboard (must finish alone,
# install nothing) -> independent checks.
OUT="$1"; NAME="$2"; REF="$3"; CONTA="${4:-chatgpt}"
P="$OUT/$NAME"; S="$P-steps.txt"; : > "$S"
cd "$HOME"
inv() {
  echo "PATH=$PATH"
  for t in git curl wget python3 node cargo rustc hermes micromamba; do
    printf '%s: ' "$t"
    if command -v "$t" >/dev/null 2>&1; then v=$("$t" --version 2>&1 | head -1); echo "$(command -v $t) | $v"; else echo absent; fi
  done
  [ "$(uname -s)" = Darwin ] && { printf 'xcode-select -p: '; xcode-select -p 2>&1; }
  [ -x /usr/bin/dpkg ] && { echo "pacotes:"; dpkg -l git curl wget libatomic1 2>/dev/null | awk '/^ii/ {print "  " $2}'; }
  [ -x /usr/bin/rpm ] && { echo "pacotes:"; rpm -q git curl wget libatomic 2>/dev/null | sed 's/^/  /'; }
  printf 'sudo sem senha: '; sudo -n true 2>/dev/null && echo sim || echo nao
}
step() { name="$1"; shift; t0=$(date +%s); bash -c "$*" > "$P-$name.log" 2>&1; ec=$?; echo "$name exit=$ec secs=$(( $(date +%s) - t0 ))" >> "$S"; }
yes_no() { if eval "$2"; then echo "$1=yes" >> "$S"; else echo "$1=no" >> "$S"; fi; }

inv > "$P-inventario-antes.txt" 2>&1
URL="https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/$REF/oficina/preparar.sh"
if command -v curl >/dev/null 2>&1; then GET="curl -fsSL $URL"; else GET="wget -qO- $URL"; fi
echo "fetcher=$(echo $GET | cut -d' ' -f1)" >> "$S"

step preparar_1 "$GET | PREPARAR_REF=$REF CONTA=$CONTA PREPARAR_LIMITE=40 bash"
export PATH="$HOME/.local/bin:$PATH"
L1="$P-preparar_1.log"
yes_no conferencia_ok "grep -q 'Peças do Hermes conferidas' '$L1' && grep -q 'vai funcionar nas próximas' '$L1'"
yes_no habilidades_ok "[ \$(grep -cE 'Habilidade (boas-vindas|cerebro|recall-and-claim-verification|measurement-validity) (instalada|já instalada)' '$L1') -eq 4 ]"
yes_no cerebro_baixado "grep -q 'Cérebro baixado' '$L1' && [ -s '$HOME/.cortex/cortex.py' ]"
yes_no login_aberto "grep -qE 'auth.openai.com/codex/device|claude.ai/oauth/authorize' '$L1'"
yes_no final_honesto "grep -q 'Falta só conectar sua conta' '$L1' && ! grep -q 'já está conectado' '$L1'"
yes_no retentou_rede "grep -qE 'não terminou \\(tentativa|Sem internet agora' '$L1'"
inv > "$P-inventario-depois.txt" 2>&1

step preparar_2 "$GET | PREPARAR_REF=$REF bash"   # no terminal in CI: nobody at the keyboard
L2="$P-preparar_2.log"
yes_no preparar_2_pulou "grep -q 'já está instalado' '$L2' && ! grep -q 'Instalando o Hermes' '$L2' && [ \$(grep -c 'já instalada' '$L2') -eq 4 ]"
yes_no preparar_2_sozinho "grep -q 'Falta só conectar sua conta' '$L2'"

step version "hermes --version"
step approvals "hermes config get approvals.mode"
yes_no approvals_manual "grep -qi manual '$P-approvals.log'"
step skills_list "hermes skills list"
SK="$HOME/.hermes/skills"
yes_no skills_listadas "[ -s $SK/boas-vindas/SKILL.md ] && [ -s $SK/cerebro/SKILL.md ] && [ -s $SK/recall-and-claim-verification/SKILL.md ] && [ -s $SK/measurement-validity/SKILL.md ] && grep -q 'boas-vindas' '$P-skills_list.log'"
yes_no sem_minds_no_nome "! grep -qi minds '$P-skills_list.log'"
PY=$(find "$HOME/.hermes/installs" -path '*venv/bin/python' 2>/dev/null | head -1)
if [ -n "$PY" ]; then
  RAW="https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/$REF"
  get() { if command -v curl >/dev/null; then curl -fsSL "$1" -o "$2"; else wget -qO "$2" "$1"; fi; }
  get "$RAW/skills/cerebro/SKILL.md" "$HOME/sk.md"; get "$RAW/oficina/testes/testa_cerebro.py" "$HOME/tc.py"
  step brain "'$PY' '$HOME/tc.py' '$HOME/sk.md' $REF"
  yes_no brain_ok "grep -q CEREBRO_OK '$P-brain.log'"
fi
du -sm "$HOME" 2>/dev/null | awk '{print "home_disk_mb="$1}' >> "$S"
touch "$OUT/done-$NAME.flag"
