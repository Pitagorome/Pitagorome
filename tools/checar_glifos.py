# Procura nos textos do jogo caracteres que NÃO existem nas fontes do projeto.
# No Windows o Godot acha esses símbolos numa fonte do sistema, mas na versão
# WEB não existe fonte reserva e eles viram um quadradinho.
# Uso: python tools/checar_glifos.py   (na pasta Pitagorome; precisa de fontTools)
import os
import re
import sys
sys.stdout.reconfigure(encoding="utf-8")
from fontTools.ttLib import TTFont

RAIZ = os.path.normpath(os.path.join(os.path.dirname(__file__), ".."))
PASTAS = ["scenes", "scripts", "data", "tests/botao_pular_fase2.gd"]

cobertos = set()
pasta_fontes = os.path.join(RAIZ, "assets", "fonts")
for f in os.listdir(pasta_fontes):
    if f.lower().endswith((".ttf", ".otf")):
        cobertos |= set(TTFont(os.path.join(pasta_fontes, f)).getBestCmap().keys())

STRING = re.compile(r'"((?:[^"\\]|\\.)*)"')
problemas = {}
for alvo in PASTAS:
    caminho = os.path.join(RAIZ, alvo)
    arquivos = [caminho] if os.path.isfile(caminho) else [
        os.path.join(b, a) for b, _, aa in os.walk(caminho) for a in aa if a.endswith((".gd", ".tscn", ".tres"))]
    for arq in arquivos:
        for n, linha in enumerate(open(arq, encoding="utf-8"), 1):
            if linha.lstrip().startswith("#"):
                continue
            for s in STRING.findall(linha):
                for c in s:
                    if ord(c) > 0x7E and ord(c) not in cobertos:
                        problemas.setdefault(c, []).append(f"{os.path.relpath(arq, RAIZ)}:{n}")

for c, onde in sorted(problemas.items()):
    print(f"U+{ord(c):04X} {c!r}: {len(onde)}x  ex.: {', '.join(onde[:4])}")
print("OK: nenhum símbolo fora das fontes" if not problemas else f"{len(problemas)} símbolo(s) sem glifo nas fontes")
sys.exit(1 if problemas else 0)
