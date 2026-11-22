# Gera assets/ui/icone_pular.png: ícone de "skip" (▶▶|) em pixel-art 13x9,
# usado no botão de pular a historinha do começo.
# Uso: python tools/gerar_icone_pular.py  (na pasta Pitagorome)
import os
from PIL import Image

MAPA = [
    "#....#.....##",
    "##...##....##",
    "###..###...##",
    "####.####..##",
    "##########.##",
    "####.####..##",
    "###..###...##",
    "##...##....##",
    "#....#.....##",
]

COR = (253, 242, 217, 255)  # mesmo creme do texto da UI

img = Image.new("RGBA", (len(MAPA[0]), len(MAPA)), (0, 0, 0, 0))
for y, linha in enumerate(MAPA):
    for x, c in enumerate(linha):
        if c == "#":
            img.putpixel((x, y), COR)

saida = os.path.join(os.path.dirname(__file__), "..", "assets", "ui", "icone_pular.png")
os.makedirs(os.path.dirname(saida), exist_ok=True)
img.save(saida)
print("gerado:", os.path.normpath(saida))
