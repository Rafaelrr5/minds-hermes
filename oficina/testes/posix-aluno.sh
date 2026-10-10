#!/bin/bash
# Runs AS the student account (no sudo). Mirrors what a participant does on macOS/Linux.
# Plain bash 3.2 (macOS default): no associative arrays.
OUT="$1"; VARIANT="$2"; OSNAME="$3"
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
step skill_install 300 "hermes skills install Rafaelrr5/minds-hermes/skills/minds-boas-vindas --yes"
step skills_list 120 "hermes skills list"
grep -q minds-boas-vindas "$P-skills_list.log" && echo "skill_listed=yes" >> "$STEPS" || echo "skill_listed=no" >> "$STEPS"

PY=$(find "$HOME/.hermes" -path '*venv/bin/python' 2>/dev/null | head -1)
echo "python=$PY" >> "$STEPS"
if [ -n "$PY" ]; then
  curl -fsSL https://raw.githubusercontent.com/Rafaelrr5/agent-cortex/main/cortex.py -o "$HOME/cortex.py"
  step brain_add 120 "'$PY' '$HOME/cortex.py' add 'Ana prefere respostas curtas e informais' --category preference"
  step brain_search 120 "'$PY' '$HOME/cortex.py' search 'respostas curtas' -n 3"
  grep -q 'Ana prefere' "$P-brain_search.log" && echo "brain_ok=yes" >> "$STEPS" || echo "brain_ok=no" >> "$STEPS"
fi
du -sm "$HOME" 2>/dev/null | awk '{print "home_disk_mb="$1}' >> "$STEPS"
touch "$OUT/done-$OSNAME-$VARIANT.flag"
