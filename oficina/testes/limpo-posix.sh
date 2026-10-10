#!/bin/bash
# Runs AS the student on a stripped machine/container (macOS or Linux).
# Inventory -> preparar.sh (as in the guide) -> inventory -> preparar.sh again -> checks.
OUT="$1"; NAME="$2"; REF="$3"
P="$OUT/$NAME"; S="$P-steps.txt"; : > "$S"
cd "$HOME"
inv() {
  echo "PATH=$PATH"
  for t in git curl wget python3 node cargo rustc hermes; do
    printf '%s: ' "$t"
    if command -v "$t" >/dev/null 2>&1; then
      v=$("$t" --version 2>&1 | head -1); echo "$(command -v $t) | $v"
    else echo absent; fi
  done
  [ "$(uname -s)" = Darwin ] && { printf 'xcode-select -p: '; xcode-select -p 2>&1; }
  [ -x /usr/bin/dpkg ] && { echo "pacotes:"; dpkg -l git curl wget libatomic1 2>/dev/null | awk '/^ii/ {print "  " $2}'; }
  [ -x /usr/bin/rpm ] && { echo "pacotes:"; rpm -q git curl wget libatomic 2>/dev/null | sed 's/^/  /'; }
}
step() { name="$1"; shift; t0=$(date +%s); bash -c "$*" > "$P-$name.log" 2>&1; ec=$?; echo "$name exit=$ec secs=$(( $(date +%s) - t0 ))" >> "$S"; }

inv > "$P-inventario-antes.txt" 2>&1
URL="https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/$REF/oficina/preparar.sh"
if command -v curl >/dev/null 2>&1; then GET="curl -fsSL $URL"; else GET="wget -qO- $URL"; fi
echo "fetcher=$(echo $GET | cut -d' ' -f1)" >> "$S"
step preparar_1 "$GET | bash"
export PATH="$HOME/.local/bin:$PATH"
grep -q 'Pronto:' "$P-preparar_1.log" && echo "preparar_1_ok=yes" >> "$S" || echo "preparar_1_ok=no" >> "$S"
inv > "$P-inventario-depois.txt" 2>&1
step preparar_2 "$GET | bash"
grep -q 'Nada para fazer' "$P-preparar_2.log" && echo "preparar_2_pulou=yes" >> "$S" || echo "preparar_2_pulou=no" >> "$S"

step version "hermes --version"
RAW="https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/$REF"
step skill_install "hermes skills install $RAW/skills/minds-boas-vindas/SKILL.md --yes"
step skill_install_cerebro "hermes skills install $RAW/skills/minds-cerebro/SKILL.md --yes"
step skills_list "hermes skills list"
grep -q minds-cerebro "$P-skills_list.log" && echo "cerebro_listed=yes" >> "$S" || echo "cerebro_listed=no" >> "$S"
PY=$(find "$HOME/.hermes/installs" -path '*venv/bin/python' 2>/dev/null | head -1)
if [ -n "$PY" ]; then
  hermes_get() { if command -v curl >/dev/null; then curl -fsSL "$1" -o "$2"; else wget -qO "$2" "$1"; fi; }
  hermes_get "$RAW/skills/minds-cerebro/SKILL.md" "$HOME/sk.md"
  hermes_get "$RAW/oficina/testes/testa_cerebro.py" "$HOME/tc.py"
  step brain "'$PY' '$HOME/tc.py' '$HOME/sk.md' $REF"
  grep -q CEREBRO_OK "$P-brain.log" && echo "brain_ok=yes" >> "$S" || echo "brain_ok=no" >> "$S"
fi
du -sm "$HOME" 2>/dev/null | awk '{print "home_disk_mb="$1}' >> "$S"
touch "$OUT/done-$NAME.flag"
