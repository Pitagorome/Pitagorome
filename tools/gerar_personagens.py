"""
Gera os 4 visuais novos do jogador (os personagens da arte "Obrigado!" do grupo)
recolorindo os sprites base do pacote Modern Interiors, que já têm idle e corrida
nas 4 direções:
  - grupo1..grupo3: base Adam (cabelo curto)
  - grupo4:         base Amelia (cabelo comprido) + óculos desenhados por cima

Rodar (na pasta Pitagorome):  python tools/gerar_personagens.py
Saída: assets/characters/grupoN_idle.png, grupoN_run.png e
       assets/character_frames/grupoN_frames.tres (copiado do adam_frames.tres)

Como funciona: cada pixel do sprite base é classificado (cabelo, pele, camisa,
calça, sapato, olho, contorno) pela cor e pela linha onde está, e ganha a cor
nova mantendo o sombreado original (proporção de luminosidade).
"""
import os
import re
from PIL import Image

BASE = 'Tilemap-pronto/Modern tiles_Free/Characters_free/'
OUT_PNG = 'assets/characters/'
OUT_TRES = 'assets/character_frames/'

# ---------------- paletas dos sprites base ----------------
ADAM = {
    'contorno': [(86, 89, 114), (70, 70, 94), (58, 58, 80)],
    'verde': [(149, 157, 88), (104, 114, 83), (95, 105, 74), (93, 96, 67)],  # cabelo E calça
    'transicao': [(187, 163, 134)],                                           # cabelo encostando na pele
    'pele': [(255, 203, 176), (246, 174, 159), (246, 151, 132), (255, 184, 147), (225, 155, 155), (211, 163, 141)],
    'roxo': [(128, 94, 142), (159, 116, 168), (108, 89, 129)],                 # camisa E sapato
}
ADAM_REF = {'verde': (104, 114, 83), 'pele': (255, 203, 176), 'roxo': (128, 94, 142)}

AMELIA = {
    'contorno': [(86, 89, 114), (70, 70, 94), (58, 58, 80)],
    'cabelo': [(186, 141, 94), (149, 115, 80), (141, 112, 81), (138, 101, 82)],
    'escuro': [(103, 77, 73)],                       # sombra do cabelo OU olho
    'pele': [(191, 139, 120), (181, 121, 114), (167, 122, 103), (178, 115, 109), (170, 94, 86)],
    'camisa': [(168, 83, 119), (185, 93, 114), (108, 89, 129)],
    'saia': [(199, 140, 89), (179, 94, 63)],
    'sapato': [(171, 74, 54)],
}
AMELIA_REF = {'cabelo': (138, 101, 82), 'pele': (191, 139, 120), 'camisa': (168, 83, 119), 'saia': (199, 140, 89), 'sapato': (171, 74, 54)}

# ---------------- os 4 personagens (cores tiradas da arte do grupo) ----------------
PERSONAGENS = {
    'grupo1': dict(base='Adam', cabelo=(160, 120, 70), pele=(255, 214, 186), camisa=(236, 236, 240),
                   calca=(150, 195, 225), sapato=(45, 45, 55), olho=(70, 50, 40), bermuda=True),
    'grupo2': dict(base='Adam', cabelo=(38, 36, 44), pele=(172, 112, 74), camisa=(214, 48, 48),
                   calca=(42, 42, 52), sapato=(30, 30, 38), olho=(40, 28, 24)),
    'grupo3': dict(base='Adam', cabelo=(80, 52, 40), pele=(226, 170, 128), camisa=(236, 236, 240),
                   calca=(42, 42, 52), sapato=(30, 30, 38), olho=(50, 34, 28)),
    'grupo4': dict(base='Amelia', cabelo=(78, 50, 44), pele=(255, 214, 190), camisa=(140, 42, 62),
                   calca=(40, 40, 50), sapato=(30, 30, 38), olho=(50, 34, 28), oculos=(214, 218, 230)),
}


def lum(c):
    return 0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2]


def tom(orig, ref, alvo):
    """Pinta 'orig' com a cor 'alvo', mantendo o quanto ele era mais claro/escuro que 'ref'."""
    k = lum(orig) / max(lum(ref), 1)
    return tuple(max(0, min(255, int(round(a * k)))) for a in alvo) + (255,)


def misturar(a, b, t=0.5):
    return tuple(int(a[i] * (1 - t) + b[i] * t) for i in range(3)) + (255,)


def recolor_adam(im, p):
    w, h = im.size
    src = im.copy()
    out = im.copy()
    px = src.load()
    o = out.load()

    def eh(c, grupo):
        return c[3] > 0 and c[:3] in ADAM[grupo]

    for x in range(w):
        for y in range(h):
            c = px[x, y]
            if c[3] == 0 or eh(c, 'contorno'):
                continue
            rgb = c[:3]
            if eh(c, 'verde'):
                if y >= 25:   # calça
                    abaixo = px[x, y + 1] if y + 1 < h else (0, 0, 0, 0)
                    if p.get('bermuda') and not eh(abaixo, 'verde'):
                        o[x, y] = tom(rgb, (255, 203, 176), p['pele'])  # perna aparecendo
                    else:
                        o[x, y] = tom(rgb, ADAM_REF['verde'], p['calca'])
                else:
                    esq = px[x - 1, y] if x > 0 else (0, 0, 0, 0)
                    dir_ = px[x + 1, y] if x + 1 < w else (0, 0, 0, 0)
                    if y >= 19 and (eh(esq, 'pele') or eh(dir_, 'pele')) and (eh(esq, 'pele') and eh(dir_, 'pele')):
                        o[x, y] = p['olho'] + (255,)  # parte de baixo do olho
                    else:
                        o[x, y] = tom(rgb, ADAM_REF['verde'], p['cabelo'])
            elif eh(c, 'transicao'):
                o[x, y] = misturar(tom(rgb, rgb, p['cabelo']), p['pele'] + (255,), 0.55)
            elif eh(c, 'pele'):
                o[x, y] = tom(rgb, ADAM_REF['pele'], p['pele'])
            elif eh(c, 'roxo'):
                o[x, y] = tom(rgb, ADAM_REF['roxo'], p['sapato'] if y >= 29 else p['camisa'])
    return out


def recolor_amelia(im, p):
    w, h = im.size
    src = im.copy()
    out = im.copy()
    px = src.load()
    o = out.load()

    def eh(c, grupo):
        return c[3] > 0 and c[:3] in AMELIA[grupo]

    olhos = []
    for x in range(w):
        for y in range(h):
            c = px[x, y]
            if c[3] == 0:
                continue
            rgb = c[:3]
            esq = px[x - 1, y] if x > 0 else (0, 0, 0, 0)
            dir_ = px[x + 1, y] if x + 1 < w else (0, 0, 0, 0)
            pele_dos_lados = eh(esq, 'pele') and eh(dir_, 'pele')
            if eh(c, 'contorno'):
                if 19 <= y <= 22 and pele_dos_lados:
                    olhos.append((x, y))  # olho (desenhado com a cor do contorno)
                continue
            if eh(c, 'escuro'):
                if 19 <= y <= 22 and pele_dos_lados:
                    o[x, y] = p['olho'] + (255,)
                    olhos.append((x, y))
                else:
                    o[x, y] = tom(rgb, AMELIA_REF['cabelo'], p['cabelo'])
            elif eh(c, 'cabelo'):
                o[x, y] = tom(rgb, AMELIA_REF['cabelo'], p['cabelo'])
            elif eh(c, 'pele'):
                o[x, y] = tom(rgb, AMELIA_REF['pele'], p['pele'])
            elif eh(c, 'camisa'):
                o[x, y] = tom(rgb, AMELIA_REF['camisa'], p['camisa'])
            elif eh(c, 'saia'):
                o[x, y] = tom(rgb, AMELIA_REF['saia'], p['calca'])
            elif eh(c, 'sapato'):
                o[x, y] = tom(rgb, AMELIA_REF['sapato'], p['sapato'])

    # óculos: aro claro em volta de cada olho (só por cima da pele) + ponte entre os dois
    if p.get('oculos'):
        cor = p['oculos'] + (255,)
        por_quadro = {}
        for (x, y) in olhos:
            por_quadro.setdefault(x // 16, []).append((x, y))
        for q, pts in por_quadro.items():
            # agrupa os pixels de olho por coluna (cada olho tem 1 px de largura e 1-2 de altura)
            colunas = {}
            for (x, y) in pts:
                colunas.setdefault(x, []).append(y)
            xs_olhos = sorted(colunas)
            if len(xs_olhos) < 2 or xs_olhos[-1] - xs_olhos[0] <= 2:
                continue  # de lado/de costas: a 16 px os óculos viram um borrão, então só de frente
            for x, ys in colunas.items():
                topo = min(ys)
                # aro fino: linha em cima do olho + uma lateral de cada lado (não cobre o olho)
                for nx, ny in [(x - 1, topo - 1), (x, topo - 1), (x + 1, topo - 1), (x - 1, topo), (x + 1, topo)]:
                    if 0 <= nx < w and 0 <= ny < h and eh(px[nx, ny], 'pele'):
                        o[nx, ny] = cor
            xs = sorted(colunas)
            if len(xs) >= 2 and xs[-1] - xs[0] > 2:  # dois olhos (de frente): ponte entre as lentes
                ytopo = min(min(v) for v in colunas.values())
                for nx in range(xs[0] + 2, xs[-1] - 1):
                    if eh(px[nx, ytopo], 'pele'):
                        o[nx, ytopo] = cor
    return out


def gerar_tres(nome):
    s = open(OUT_TRES + 'adam_frames.tres', encoding='utf-8').read()
    s = re.sub(r'\[gd_resource type="SpriteFrames" format=3 uid="[^"]*"\]', '[gd_resource type="SpriteFrames" format=3]', s)
    s = re.sub(r'\[ext_resource type="Texture2D" uid="[^"]*" path="[^"]*Adam_idle_anim_16x16.png" id="1_idle"\]',
               f'[ext_resource type="Texture2D" path="res://{OUT_PNG}{nome}_idle.png" id="1_idle"]', s)
    s = re.sub(r'\[ext_resource type="Texture2D" uid="[^"]*" path="[^"]*Adam_run_16x16.png" id="2_run"\]',
               f'[ext_resource type="Texture2D" path="res://{OUT_PNG}{nome}_run.png" id="2_run"]', s)
    assert f'{nome}_idle.png' in s and f'{nome}_run.png' in s, 'adam_frames.tres mudou de formato'
    open(OUT_TRES + f'{nome}_frames.tres', 'w', encoding='utf-8', newline='\n').write(s)


def main():
    os.makedirs(OUT_PNG, exist_ok=True)
    for nome, p in PERSONAGENS.items():
        for tipo, arq in [('idle', '_idle_anim_16x16.png'), ('run', '_run_16x16.png')]:
            im = Image.open(BASE + p['base'] + arq).convert('RGBA')
            novo = recolor_adam(im, p) if p['base'] == 'Adam' else recolor_amelia(im, p)
            novo.save(OUT_PNG + f'{nome}_{tipo}.png')
        gerar_tres(nome)
        print('gerado', nome)


if __name__ == '__main__':
    main()
