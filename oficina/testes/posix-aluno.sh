#!/bin/bash
# Runs AS the student account (no sudo). Mirrors what a participant does on macOS/Linux.
# Plain bash 3.2 (macOS default): no associative arrays.
OUT="$1"; VARIANT="$2"; OSNAME="$3"; REF="${4:-oficina-testes}"
P="$OUT/$OSNAME-$VARIANT"
STEPS="$P-steps.txt"; : > "$STEPS"
cd "$HOME"
flags="--non-interactive"
[ "$VARIANT" = lean ] && flags="$flags --skip-browser --skip-computer-use"

TO=""; command -v timeout >/dev/null && TO=timeout; command -v gtimeout >/dev/null && TO=gtimeout
step() {  # step NAME TIMEOUT_SECS CMD
  name="$1"; to="$2"; shift 2
  t0=$(date +%s)
  if [ -n "$TO" ]; then $TO "$to" bash -c "$*" > "$P-$name.log" 2>&1; else bash -c "$*" > "$P-$name.log" 2>&1; fi
  ec=$?
  echo "$name exit=$ec secs=$(( $(date +%s) - t0 ))" >> "$STEPS"
}

{ echo "user=$(id -un)"; echo "uname=$(uname -a)"; sudo -n true 2>/dev/null && echo "sudo=yes" || echo "sudo=no"; } > "$P-env.txt"

step install 2400 "curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- $flags"
export PATH="$HOME/.local/bin:$PATH"
step version 120 "hermes --version"
step doctor 300 "hermes doctor"
# Classroom simulation: burn GitHub's anonymous API quota (60/h per IP) first.
for i in $(seq 1 65); do curl -s -o /dev/null https://api.github.com/repos/Rafaelrr5/minds-hermes; done
code=$(curl -s -o /dev/null -w '%{http_code}' https://api.github.com/repos/Rafaelrr5/minds-hermes); echo "api_after_burn=$code" >> "$STEPS"
RAW="https://raw.githubusercontent.com/Rafaelrr5/minds-hermes/$REF"
step skill_install_shortcut 300 "hermes skills install Rafaelrr5/minds-hermes/skills/boas-vindas --yes"
step skill_install 300 "hermes skills install $RAW/skills/boas-vindas/SKILL.md --yes"
step skill_install_cerebro 300 "hermes skills install $RAW/skills/cerebro/SKILL.md --yes"
step skills_list 120 "hermes skills list"
grep -q boas-vindas "$P-skills_list.log" && echo "skill_listed=yes" >> "$STEPS" || echo "skill_listed=no" >> "$STEPS"
grep -q cerebro "$P-skills_list.log" && echo "cerebro_listed=yes" >> "$STEPS" || echo "cerebro_listed=no" >> "$STEPS"

PY=$(find "$HOME/.hermes/installs" -path '*venv/bin/python' 2>/dev/null | head -1)
echo "python=$PY" >> "$STEPS"
if [ -n "$PY" ]; then
  curl -fsSL "$RAW/skills/cerebro/SKILL.md" -o "$HOME/cerebro-SKILL.md"
  curl -fsSL "$RAW/oficina/testes/testa_cerebro.py" -o "$HOME/testa_cerebro.py"
  step brain 180 "'$PY' '$HOME/testa_cerebro.py' '$HOME/cerebro-SKILL.md' $REF"
  grep -q CEREBRO_OK "$P-brain.log" && echo "brain_ok=yes" >> "$STEPS" || echo "brain_ok=no" >> "$STEPS"
fi
du -sm "$HOME" 2>/dev/null | awk '{print "home_disk_mb="$1}' >> "$STEPS"
touch "$OUT/done-$OSNAME-$VARIANT.flag"
