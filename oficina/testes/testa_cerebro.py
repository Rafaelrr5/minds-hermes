"""Runs the exact code block from skills/cerebro/SKILL.md with the Python that
Hermes installed, the same way the execute_code tool would. Usage:
    <hermes python> testa_cerebro.py <SKILL.md path> <git ref for raw URLs>
Prints CEREBRO_OK on success."""
import io, os, re, sys, contextlib
from pathlib import Path

skill, ref = Path(sys.argv[1]), sys.argv[2]
code = re.search(r"```python\n(.*?)```", skill.read_text(encoding="utf-8"), re.S).group(1)
code = code.replace("/minds-hermes/main/", f"/minds-hermes/{ref}/")
ns = {}
buf = io.StringIO()
with contextlib.redirect_stdout(buf):
    exec(code, ns)                                   # downloads cortex.py, prints stats
    ns["cerebro"]("add", "Ana estuda enfermagem e não gosta de jargão técnico", "--category", "perfil")
    ns["cerebro"]("search", "enfermagem", "-n", "3")
out = buf.getvalue()
print(out)
pasta = Path.home() / ".cortex"
ok = "não gosta de jargão" in out and (pasta / "facts.jsonl").exists()
print("CEREBRO_OK" if ok else "CEREBRO_FAIL", pasta)
sys.exit(0 if ok else 1)
