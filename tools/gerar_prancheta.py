"""
Gera o ícone da prancheta do HUD (canto superior esquerdo), em pixel art.
Apontamento do grupo (18/11): a caixa verde grande da tarefa atrapalhava a visão;
agora fica só uma prancheta pequena e a tarefa aparece ao clicar nela (ou apertar Tab).

Rodar (na pasta Pitagorome):  python tools/gerar_prancheta.py
Saída: assets/props/prancheta.png (20 x 24 px)
"""
from PIL import Image

# . transparente | o contorno | M madeira | m madeira escura | P papel | l linha do papel
# C prendedor (metal) | c sombra do prendedor | V visto verde
DESENHO = [
    "......oooooooo......",
    "......oCCCCCCo......",
    "..oooooCccccCooooo..",
    ".oMMMMoCCCCCCoMMMMo.",
    ".oMMMMMooooooMMMMMo.",
    ".oMPPPPPPPPPPPPPPMo.",
    ".oMPPPPPPPPPPPPPPMo.",
    ".oMPVPPllllllllPPMo.",
    ".oMPVVPPPPPPPPPPPMo.",
    ".oMVPVPllllllllPPMo.",
    ".oMPPPPPPPPPPPPPPMo.",
    ".oMPVPPllllllPPPPMo.",
    ".oMPVVPPPPPPPPPPPMo.",
    ".oMVPVPllllllllPPMo.",
    ".oMPPPPPPPPPPPPPPMo.",
    ".oMPPPPlllllllPPPMo.",
    ".oMPPPPPPPPPPPPPPMo.",
    ".oMPPPPllllllllPPMo.",
    ".oMPPPPPPPPPPPPPPMo.",
    ".oMPPPPPPPPPPPPPPMo.",
    ".oMMMMMMMMMMMMMMMMo.",
    ".ommmmmmmmmmmmmmmmo.",
    "..oooooooooooooooo..",
    "....................",
]
CORES = {
    'o': (58, 40, 30), 'M': (176, 120, 70), 'm': (130, 86, 50),
    'P': (246, 240, 222), 'l': (170, 182, 200), 'C': (200, 204, 212), 'c': (130, 134, 146),
    'V': (74, 150, 70),
}


def main():
    h, w = len(DESENHO), len(DESENHO[0])
    im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    for y, linha in enumerate(DESENHO):
        assert len(linha) == w, (y, linha)
        for x, ch in enumerate(linha):
            if ch != '.':
                im.putpixel((x, y), CORES[ch] + (255,))
    im.save('assets/props/prancheta.png')
    print('gerado assets/props/prancheta.png', im.size)


if __name__ == '__main__':
    main()
