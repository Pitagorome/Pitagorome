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
                   calca=(40, 40, 50), sapato=(30, 30, 38), olho=(50, 34, 28), oculos_cor=(125, 130, 158)),
}

# ---------------- cabeças desenhadas à mão (pixel art) ----------------
# Repintar só a cor do cabelo do sprite base mantinha o FORMATO do cabelo dele (o topete
# do Adam), e ficava bem diferente da arte do grupo. Por isso cada personagem tem a cabeça
# desenhada aqui, 16 x 13 pixels, nas visões de frente ('baixo'), de costas ('cima') e de
# lado ('direita'; a esquerda é o espelho). O script encaixa a cabeça em cada quadro
# (acompanhando o "pulinho" da animação).
# Letras: . transparente | o O contorno | H cabelo, L cabelo claro, D cabelo escuro
#         S pele, s pele sombra, B bochecha | E olho | G óculos
CABECAS = {
    'grupo1': {  # João: cabelo curto castanho-claro com franja reta
        'baixo': [
            "....oooooooo....",
            "..ooHHLLLHHHoo..",
            ".oHHLLLHHHHHHHo.",
            ".oHLLHHHHHHHHDo.",
            "oHHHHHHHHHHHHHDo",
            "oHHHHHHHHHHHHHDo",
            "oDHHHHHHHHHHHHDo",
            "oDHHHHHHHHHHHHDo",
            "oSDDDDDDDDDDDDSo",
            "oDSSSSSSSSSSSSDo",
            "OsSSSSSSSSSSSSsO",
            ".oSSSoSSSSoSSSo.",
            "..osSESSSSESso..",
        ],
        'cima': [
            "....oooooooo....",
            "..ooHHLLLHHHoo..",
            ".oHHLLLHHHHHHHo.",
            ".oHLLHHHHHHHHDo.",
            "oHHHHHHHHHHHHHDo",
            "oHHHHHHHHHHHHHDo",
            "oHHHHHHHHHHHHHDo",
            "oDHHHHHHHHHHHHDo",
            "oDHHHHHHHHHHHDDo",
            "oDDHHHHHHHHHHDDo",
            "OSDDDDDDDDDDDDSO",
            ".oSsssssssssSSo.",
            "..osSSSSSSSSso..",
        ],
        'direita': [
            ".....oooooooo...",
            "...ooHHHHLLLLoo.",
            "..oHHHHHHHLLLHo.",
            ".oHHHHHHHHHHLHHo",
            ".oHHHHHHHHHHHHHo",
            "oDHHHHHHHHHHHHHo",
            "oDHHHHHHHHHHHHHo",
            "oDHHHHHHHHHHHHo.",
            "oDDHHHHHDDDDDDo.",
            "oDDHHSSSSSSSSSo.",
            "oDDDSsSSSSSSSo..",
            ".oDDSSSSSSSoSo..",
            "..oDsSSSSSSESo..",
        ],
    },
    'grupo2': {  # Edu: cabelo preto curto e crespo
        'baixo': [
            "....oooooooo....",
            "..ooHLHHLHHLoo..",
            ".oHLHHLHHLHHLHo.",
            ".oHHLHHLHHLHHHo.",
            "oHLHHLHHLHHLHHHo",
            "oHHLHHLHHLHHLHHo",
            "oDHHHHHHHHHHHHDo",
            "oDDHDDHDDHDDHDDo",
            "oSDSSSSSSSSSSDSo",
            "oSSSSSSSSSSSSSSo",
            "OsSSSSSSSSSSSSsO",
            ".oSSSoSSSSoSSSo.",
            "..osSESSSSESso..",
        ],
        'cima': [
            "....oooooooo....",
            "..ooHLHHLHHLoo..",
            ".oHLHHLHHLHHLHo.",
            ".oHHLHHLHHLHHHo.",
            "oHLHHLHHLHHLHHHo",
            "oHHLHHLHHLHHLHHo",
            "oHLHHLHHLHHLHHHo",
            "oHHLHHLHHLHHLHDo",
            "oDHHHHHHHHHHHHDo",
            "oDDHDDHDDHDDHDDo",
            "OSSDSSDSSDSSDSSO",
            ".oSsssssssssSSo.",
            "..osSSSSSSSSso..",
        ],
        'direita': [
            ".....oooooooo...",
            "...ooHLHHLHHLoo.",
            "..oHLHHLHHLHHLo.",
            ".oHHLHHLHHLHHLHo",
            ".oHLHHLHHLHHLHHo",
            "oHHLHHLHHLHHLHHo",
            "oDHHHHHHHHHHHHHo",
            "oDDHHLHHDDHDDHo.",
            "oDDHDSSSSSSSSSo.",
            "oDDHSSSSSSSSSSo.",
            "oDDsSsSSSSSSSo..",
            ".oDSSSSSSSSoSo..",
            "..oDsSSSSSSESo..",
        ],
    },
    'grupo3': {  # Guigas: cabelo castanho-escuro mais comprido, franja cobrindo a testa
        'baixo': [
            "....oooooooo....",
            "..ooHHLLHHHHoo..",
            ".oHHLLHHHHHHHHo.",
            ".oHLLHHHHHHHHDo.",
            "oHHHHHHHHHHHHHDo",
            "oHHHHHHHHHHHHHDo",
            "oHHHHHHHHHHHHHDo",
            "oHHHHHHHHHHHHHHo",
            "oHHDHHHDHHHDHHHo",
            "oHHSDSSDSSDSSHHo",
            "oHSSSSSSSSSSSSHo",
            ".oHSSoSSSSoSSHo.",
            "..oHSESSSSESHo..",
        ],
        'cima': [
            "....oooooooo....",
            "..ooHHLLHHHHoo..",
            ".oHHLLHHHHHHHHo.",
            ".oHLLHHHHHHHHDo.",
            "oHHHHHHHHHHHHHDo",
            "oHHHHHHHHHHHHHDo",
            "oHHHHHHHHHHHHHDo",
            "oHHHHHHHHHHHHHDo",
            "oHHHHHHHHHHHHHDo",
            "oDHHHHHHHHHHHHDo",
            "oDHHHHHHHHHHHHDo",
            ".oDDHHHHHHHHDDo.",
            "..oDDDDDDDDDDo..",
        ],
        'direita': [
            ".....oooooooo...",
            "...ooHHHHLLHHoo.",
            "..oHHHHHHHLLHHo.",
            ".oHHHHHHHHHHLHHo",
            ".oHHHHHHHHHHHHHo",
            "oHHHHHHHHHHHHHHo",
            "oHHHHHHHHHHHHHHo",
            "oHHHHHHHHHHHHHo.",
            "oDHHHHHHHDHHDHo.",
            "oDHHHHHHSDSSDSo.",
            "oDHHHHHSSSSSSo..",
            ".oDHHSSSSSSoSo..",
            "..oDHsSSSSSESo..",
        ],
    },
    'grupo4': {  # Ana: franja reta e óculos (só de frente; de lado/costas fica o cabelo comprido da base)
        'baixo': [
            "....oooooooo....",
            "...oHHLLHHHHo...",
            "..oHLLHHHHHHHo..",
            "..oHLHHHHHHHHo..",
            ".oHHHHHHHHHHHHo.",
            ".oHHHHHHHHHHHHo.",
            ".oHHHHHHHHHHHHo.",
            "oHHDHDDHDDHDDHHo",
            "oHDSSSSSSSSSSDHo",
            "oHDSGGGSSGGGSDHo",  # óculos: aro em volta de cada olho
            "oHDSGEGGGGEGSDHo",  # (o olho fica DENTRO da lente)
            "oHDsGGGSSGGGsDHo",
            "DHHsBSSSSSSBsHHD",
        ],
    },
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

    return out


def cores_da_cabeca(p):
    hair = p['cabelo']
    clarear = lambda c, k: tuple(min(255, int(v * k + 18)) for v in c)
    escurecer = lambda c, k: tuple(int(v * k) for v in c)
    return {
        'o': (58, 58, 80), 'O': (70, 70, 94),
        'H': hair, 'L': clarear(hair, 1.3), 'D': escurecer(hair, 0.68),
        'S': p['pele'], 's': escurecer(p['pele'], 0.9),
        'B': tuple(int(p['pele'][i] * 0.7 + (235, 120, 120)[i] * 0.3) for i in range(3)),
        'E': p['olho'], 'G': p.get('oculos_cor', (236, 238, 246)),
    }


def encaixar_cabecas(im, nome, p):
    """Troca a cabeça de cada quadro pela cabeça desenhada em CABECAS."""
    if nome not in CABECAS:
        return im
    cores = cores_da_cabeca(p)
    out = im.copy()
    o = out.load()
    direcoes = ['direita', 'cima', 'esquerda', 'baixo']  # ordem dos quadros no sprite (6 de cada)
    for f in range(im.size[0] // 16):
        direcao = direcoes[(f // 6) % 4]
        desenho = CABECAS[nome].get('direita' if direcao == 'esquerda' else direcao)
        if desenho is None:
            continue  # essa visão fica a do sprite base
        if direcao == 'esquerda':
            desenho = [linha[::-1] for linha in desenho]
        x0 = f * 16
        topo = next(y for y in range(32) if any(im.getpixel((x0 + x, y))[3] for x in range(16)))
        for i, linha in enumerate(desenho):
            y = topo + i
            for x, ch in enumerate(linha):
                o[x0 + x, y] = (0, 0, 0, 0) if ch == '.' else cores[ch] + (255,)
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
            novo = encaixar_cabecas(novo, nome, p)
            novo.save(OUT_PNG + f'{nome}_{tipo}.png')
        gerar_tres(nome)
        print('gerado', nome)


if __name__ == '__main__':
    main()
