"""Gera móveis que o tileset não tem.

Uso:  python tools/gerar_moveis.py

- assets/props/arquivo_aco.png : dois arquivos de aço com 4 gavetas cada (34 x 37 px).
  Substitui o antigo "armario_metal", que usava o sprite de PORTA DE ELEVADOR do tileset
  (o grupo não sabia se era armário ou elevador). Gavetas horizontais com puxador e
  etiqueta deixam claro que é um móvel de escritório/escola.
"""
import os
from PIL import Image

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

CONTORNO = (34, 38, 50, 255)
CORPO = (146, 156, 170, 255)
TOPO = (196, 204, 214, 255)
TOPO_SOMBRA = (168, 177, 190, 255)
GAVETA = (164, 174, 187, 255)
GAVETA_LUZ = (186, 195, 206, 255)
GAVETA_SOMBRA = (104, 112, 126, 255)
PUXADOR = (66, 70, 80, 255)
PUXADOR_LUZ = (222, 226, 232, 255)
ETIQUETA = (238, 230, 200, 255)
ETIQUETA_TEXTO = (150, 140, 110, 255)
PE = (78, 84, 98, 255)

W_UM, H = 16, 37


def arquivo(img: Image.Image, x0: int) -> None:
    px = img.load()

    def rect(x, y, w, h, cor):
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                px[x0 + xx, yy] = cor

    # contorno + corpo
    rect(0, 0, W_UM, H, CONTORNO)
    rect(1, 1, W_UM - 2, H - 2, CORPO)
    # tampo (dá volume de cima)
    rect(1, 1, W_UM - 2, 3, TOPO)
    rect(1, 4, W_UM - 2, 1, TOPO_SOMBRA)
    # 4 gavetas
    y = 6
    for _ in range(4):
        rect(2, y, W_UM - 4, 6, GAVETA)
        rect(2, y, W_UM - 4, 1, GAVETA_LUZ)
        rect(2, y + 6, W_UM - 4, 1, GAVETA_SOMBRA)
        # etiqueta
        rect(6, y + 1, 4, 2, ETIQUETA)
        rect(7, y + 2, 2, 1, ETIQUETA_TEXTO)
        # puxador
        rect(5, y + 4, 6, 1, PUXADOR)
        rect(5, y + 3, 6, 1, PUXADOR_LUZ)
        y += 7
    # pé
    rect(1, H - 3, W_UM - 2, 2, PE)


def main() -> None:
    destino = os.path.join(RAIZ, "assets", "props")
    os.makedirs(destino, exist_ok=True)
    img = Image.new("RGBA", (W_UM * 2 + 2, H), (0, 0, 0, 0))
    arquivo(img, 0)
    arquivo(img, W_UM + 2)
    caminho = os.path.join(destino, "arquivo_aco.png")
    img.save(caminho)
    print("gerado:", caminho)


if __name__ == "__main__":
    main()
