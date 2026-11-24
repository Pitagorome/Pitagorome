"""Gera todos os sons e músicas do jogo (efeitos + 3 trilhas em loop).

Uso:  python tools/gerar_sons.py

Tudo é sintetizado aqui mesmo (ondas quadrada, triangular, seno e ruído), com melodias
compostas pelo grupo para o Pitagorome. Ou seja: não há nenhuma gravação ou música de
terceiros e nada tem direitos autorais de outra pessoa (sem copyright para usar no jogo).

Saída (assets/audio/), WAV mono 16-bit 22050 Hz:
  sfx/clique.wav    botões
  sfx/dialogo.wav   cada fala nova da caixa de diálogo
  sfx/interagir.wav apertar E em NPC/objeto
  sfx/porta.wav     passar por uma porta
  sfx/acerto.wav    resposta certa
  sfx/erro.wav      resposta errada
  sfx/tarefa.wav    tarefa concluída
  sfx/fase.wav      fase concluída
  sfx/apagao.wav    a luz da escola cai (Task 8)
  sfx/energia.wav   a luz volta
  musica/escola.wav    trilha principal (exploração), 100 bpm, 16 compassos
  musica/historia.wav  historinha do começo, 80 bpm, 8 compassos
  musica/escuro.wav    escola sem luz, 64 bpm, 8 compassos

Só usa a biblioteca padrão do Python.
"""
import math
import os
import random
import struct
import wave

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SAIDA = os.path.join(RAIZ, "assets", "audio")
SR = 22050
random.seed(7)  # ruído sempre igual: rodar de novo gera arquivos idênticos

NOTAS = {"C": 0, "C#": 1, "D": 2, "D#": 3, "E": 4, "F": 5, "F#": 6, "G": 7, "G#": 8, "A": 9, "A#": 10, "B": 11}


def freq(nota):
    """'A4' -> 440.0"""
    nome, oitava = nota[:-1], int(nota[-1])
    midi = 12 * (oitava + 1) + NOTAS[nome]
    return 440.0 * 2 ** ((midi - 69) / 12)


# ---------------- ondas ----------------

def quadrada(fase, duty=0.5):
    return 1.0 if (fase % 1.0) < duty else -1.0


def triangular(fase):
    f = fase % 1.0
    return 4 * f - 1 if f < 0.5 else 3 - 4 * f


def seno(fase):
    return math.sin(2 * math.pi * fase)


def sino(fase):
    # seno com harmônicos: lembra caixinha de música
    return seno(fase) + 0.35 * seno(2 * fase) + 0.12 * seno(3 * fase)


def envelope(t, dur, ataque=0.005, release=0.05, decaimento=0.0):
    """Ataque linear, decaimento exponencial opcional e release no fim (sem estalo)."""
    if t < 0 or t >= dur:
        return 0.0
    a = min(1.0, t / ataque) if ataque > 0 else 1.0
    if decaimento > 0:
        a *= math.exp(-t * decaimento)
    if t > dur - release:
        a *= max(0.0, (dur - t) / release)
    return a


# ---------------- mixagem ----------------

class Faixa:
    def __init__(self, segundos):
        self.buf = [0.0] * int(segundos * SR)

    def nota(self, inicio, dur, f, onda, vol, ataque=0.005, release=0.05, decaimento=0.0, vibrato=0.0, glide_para=None):
        i0 = int(inicio * SR)
        n = int(dur * SR)
        fase = 0.0
        for k in range(n):
            i = i0 + k
            if i >= len(self.buf):
                break
            t = k / SR
            fk = f
            if glide_para is not None:
                fk = f + (glide_para - f) * (k / n)
            if vibrato:
                fk *= 1 + vibrato * math.sin(2 * math.pi * 5.5 * t)
            fase += fk / SR
            self.buf[i] += onda(fase) * vol * envelope(t, dur, ataque, release, decaimento)

    def ruido(self, inicio, dur, vol, decaimento=30.0, passa_baixa=0.5):
        i0 = int(inicio * SR)
        y = 0.0
        for k in range(int(dur * SR)):
            i = i0 + k
            if i >= len(self.buf):
                break
            t = k / SR
            y += passa_baixa * (random.uniform(-1, 1) - y)
            self.buf[i] += y * vol * envelope(t, dur, 0.001, 0.01, decaimento)

    def bumbo(self, inicio, vol):
        # seno com o tom caindo rápido
        self.nota(inicio, 0.18, 120, seno, vol, ataque=0.001, release=0.03, decaimento=18, glide_para=45)

    def suavizar(self, alfa):
        """Filtro passa-baixa simples para tirar o 'chiado' das ondas quadradas."""
        y = 0.0
        for i, x in enumerate(self.buf):
            y += alfa * (x - y)
            self.buf[i] = y

    def somar(self, outra):
        for i, x in enumerate(outra.buf[: len(self.buf)]):
            self.buf[i] += x

    def salvar(self, caminho, pico=0.8):
        maior = max(1e-9, max(abs(x) for x in self.buf))
        ganho = pico / maior
        os.makedirs(os.path.dirname(caminho), exist_ok=True)
        with wave.open(caminho, "wb") as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(SR)
            w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, x * ganho)) * 32767)) for x in self.buf))
        print("ok", os.path.relpath(caminho, RAIZ), "%.1fs" % (len(self.buf) / SR))


# ---------------- efeitos ----------------

def sfx(nome, segundos, montar, pico=0.8):
    f = Faixa(segundos)
    montar(f)
    f.salvar(os.path.join(SAIDA, "sfx", nome + ".wav"), pico)


def gerar_efeitos():
    sfx("clique", 0.06, lambda f: f.nota(0, 0.06, 1400, lambda p: quadrada(p, 0.25), 0.5, ataque=0.001, release=0.02, decaimento=60, glide_para=900), 0.55)

    sfx("dialogo", 0.07, lambda f: f.nota(0, 0.07, freq("A5"), triangular, 0.6, ataque=0.002, release=0.03, decaimento=25), 0.45)

    def interagir(f):
        f.nota(0.00, 0.07, freq("E5"), lambda p: quadrada(p, 0.25), 0.4, release=0.02)
        f.nota(0.06, 0.12, freq("B5"), lambda p: quadrada(p, 0.25), 0.4, release=0.06)
        f.suavizar(0.45)
    sfx("interagir", 0.2, interagir, 0.6)

    def porta(f):
        f.ruido(0.0, 0.22, 0.7, decaimento=14, passa_baixa=0.12)  # 'vush' da porta
        f.nota(0.0, 0.16, 90, seno, 0.8, ataque=0.002, decaimento=22, glide_para=60)  # batida
        f.nota(0.12, 0.12, 70, seno, 0.5, ataque=0.002, decaimento=28)
    sfx("porta", 0.3, porta, 0.6)

    def acerto(f):
        for i, n in enumerate(["C5", "E5", "G5"]):
            f.nota(i * 0.08, 0.1, freq(n), lambda p: quadrada(p, 0.5), 0.35, release=0.03)
        f.nota(0.24, 0.4, freq("C6"), lambda p: quadrada(p, 0.5), 0.35, release=0.25, vibrato=0.006)
        f.nota(0.24, 0.4, freq("E5"), triangular, 0.4, release=0.25)
        f.suavizar(0.35)
    sfx("acerto", 0.66, acerto, 0.65)

    def erro(f):
        f.nota(0.00, 0.14, freq("A3"), lambda p: quadrada(p, 0.5), 0.4, release=0.03)
        f.nota(0.14, 0.32, freq("F3"), lambda p: quadrada(p, 0.5), 0.4, release=0.15, glide_para=freq("E3"))
        f.suavizar(0.25)
    sfx("erro", 0.48, erro, 0.6)

    def tarefa(f):
        melodia = [("G4", 0.0, 0.1), ("C5", 0.1, 0.1), ("E5", 0.2, 0.1), ("G5", 0.3, 0.1), ("E5", 0.4, 0.1), ("G5", 0.5, 0.5)]
        for n, t, d in melodia:
            f.nota(t, d, freq(n), lambda p: quadrada(p, 0.25), 0.35, release=min(0.3, d * 0.6), vibrato=0.005 if d > 0.2 else 0)
        f.nota(0.5, 0.5, freq("C4"), triangular, 0.5, release=0.3)
        f.nota(0.5, 0.5, freq("E4"), triangular, 0.35, release=0.3)
        f.suavizar(0.4)
    sfx("tarefa", 1.05, tarefa, 0.7)

    def fase(f):
        partes = [("C5", 0.0, 0.15), ("C5", 0.15, 0.15), ("C5", 0.3, 0.15), ("C5", 0.45, 0.4),
                  ("G#4", 0.85, 0.4), ("A#4", 1.25, 0.4), ("C5", 1.65, 0.2), ("A#4", 1.85, 0.15), ("C5", 2.0, 0.9)]
        for n, t, d in partes:
            f.nota(t, d, freq(n), lambda p: quadrada(p, 0.5), 0.35, release=min(0.3, d * 0.5), vibrato=0.006 if d > 0.3 else 0)
        for n, t, d in [("C3", 0.45, 0.4), ("G#2", 0.85, 0.4), ("A#2", 1.25, 0.75), ("C3", 2.0, 0.9)]:
            f.nota(t, d, freq(n), triangular, 0.55, release=0.2)
        for n in ["E4", "G4"]:
            f.nota(2.0, 0.9, freq(n), triangular, 0.25, release=0.5)
        f.suavizar(0.4)
    sfx("fase", 3.0, fase, 0.75)

    def apagao(f):
        f.nota(0.0, 0.9, 440, lambda p: quadrada(p, 0.5), 0.35, ataque=0.002, release=0.3, glide_para=40)
        f.nota(0.0, 0.9, 220, triangular, 0.4, release=0.3, glide_para=30)
        f.ruido(0.0, 0.25, 0.4, decaimento=20, passa_baixa=0.3)
        f.suavizar(0.3)
    sfx("apagao", 1.0, apagao, 0.7)

    def energia(f):
        f.nota(0.0, 0.6, 60, triangular, 0.5, ataque=0.05, release=0.1, glide_para=300)
        f.nota(0.0, 0.6, 120, lambda p: quadrada(p, 0.5), 0.2, ataque=0.05, release=0.1, glide_para=600)
        f.nota(0.55, 0.3, freq("C6"), seno, 0.35, release=0.2)
        f.suavizar(0.3)
    sfx("energia", 0.9, energia, 0.65)


# ---------------- músicas ----------------

ACORDES = {
    "C": ["C", "E", "G"], "Am": ["A", "C", "E"], "F": ["F", "A", "C"], "G": ["G", "B", "D"],
    "Em": ["E", "G", "B"], "Dm": ["D", "F", "A"], "A#": ["A#", "D", "F"], "Gm": ["G", "A#", "D"],
    "A": ["A", "C#", "E"],
}


def musica_escola():
    """Tema principal: alegre e tranquilo, para andar pela escola."""
    bpm = 100
    batida = 60 / bpm
    compasso = 4 * batida
    progressao = ["C", "Am", "F", "G", "C", "Am", "F", "G", "F", "G", "Em", "Am", "F", "G", "C", "C"]
    # (nota ou None para pausa, duração em batidas) — cada compasso soma 4
    melodia = [
        [("E5", 1), ("G5", 1), ("C6", 1), ("G5", 1)],
        [("A5", 1.5), ("G5", 0.5), ("E5", 2)],
        [("F5", 1), ("A5", 1), ("C6", 1), ("A5", 1)],
        [("G5", 3), (None, 1)],
        [("E5", 0.5), ("F5", 0.5), ("G5", 1), ("E5", 1), ("C5", 1)],
        [("C5", 1), ("E5", 1), ("A5", 2)],
        [("A5", 1), ("G5", 1), ("F5", 1), ("E5", 1)],
        [("D5", 3), (None, 1)],
        [("C5", 1), ("F5", 1), ("A5", 1.5), ("G5", 0.5)],
        [("B4", 1), ("D5", 1), ("G5", 2)],
        [("E5", 1), ("G5", 1), ("B5", 1.5), ("A5", 0.5)],
        [("A5", 3), (None, 1)],
        [("F5", 1), ("A5", 1), ("C6", 1), ("A5", 1)],
        [("B5", 1), ("A5", 1), ("G5", 1), ("D5", 1)],
        [("E5", 1.5), ("D5", 0.5), ("C5", 2)],
        [("C5", 2), (None, 2)],
    ]
    total = len(progressao) * compasso
    mel, harm, base = Faixa(total), Faixa(total), Faixa(total)

    for c, nome in enumerate(progressao):
        t0 = c * compasso
        notas = ACORDES[nome]
        raiz = notas[0]
        # baixo: raiz - raiz - quinta - raiz (semínimas)
        for b, n in enumerate([raiz + "2", raiz + "2", notas[2] + "2", raiz + "2"]):
            f = freq(n)
            if f < freq("E2"):
                f *= 2
            base.nota(t0 + b * batida, batida * 0.9, f, triangular, 0.55, release=0.06)
        # acorde em arpejo (colcheias), pulso fino e baixinho
        arpejo = [notas[0], notas[1], notas[2], notas[1]] * 2
        for k, n in enumerate(arpejo):
            f = freq(n + "4")
            harm.nota(t0 + k * batida / 2, batida / 2 * 0.85, f, lambda p: quadrada(p, 0.125), 0.13, release=0.04)
        # bateria leve
        harm.bumbo(t0, 0.5)
        harm.bumbo(t0 + 2 * batida, 0.4)
        for k in range(8):
            if k % 2 == 1:
                harm.ruido(t0 + k * batida / 2, 0.05, 0.12, decaimento=60, passa_baixa=0.9)
        # melodia (uma oitava abaixo do escrito, fica mais macia)
        t = t0
        for n, d in melodia[c]:
            if n:
                f = freq(n) / 2
                mel.nota(t, d * batida * 0.92, f, lambda p: quadrada(p, 0.5), 0.22, ataque=0.01, release=0.08, vibrato=0.004 if d >= 2 else 0)
            t += d * batida
    mel.suavizar(0.3)
    harm.suavizar(0.5)
    mel.somar(harm)
    mel.somar(base)
    mel.salvar(os.path.join(SAIDA, "musica", "escola.wav"), 0.7)


def musica_historia():
    """Historinha do começo: caixinha de música calma."""
    bpm = 80
    batida = 60 / bpm
    compasso = 4 * batida
    progressao = ["Am", "F", "C", "G", "Am", "F", "G", "G"]
    total = len(progressao) * compasso
    f = Faixa(total)
    topo = ["E5", "C5", "G5", "D5", "A5", "F5", "B4", "D5"]
    for c, nome in enumerate(progressao):
        t0 = c * compasso
        notas = ACORDES[nome]
        # pad: acorde inteiro bem suave
        for n in notas:
            f.nota(t0, compasso, freq(n + "3"), triangular, 0.1, ataque=0.4, release=0.5)
        f.nota(t0, compasso, freq(notas[0] + "2"), seno, 0.35, ataque=0.05, release=0.4)
        # arpejo em colcheias, sobe e desce
        sequencia = [notas[0] + "4", notas[1] + "4", notas[2] + "4", notas[0] + "5", notas[2] + "4", notas[1] + "4", notas[2] + "4", notas[0] + "5"]
        for k, n in enumerate(sequencia):
            f.nota(t0 + k * batida / 2, batida * 1.4, freq(n), sino, 0.16, ataque=0.003, release=0.2, decaimento=3.5)
        # nota de melodia longa no começo de cada compasso
        f.nota(t0, compasso * 0.95, freq(topo[c]), sino, 0.2, ataque=0.003, release=0.4, decaimento=1.2)
    f.salvar(os.path.join(SAIDA, "musica", "historia.wav"), 0.65)


def musica_escuro():
    """Escola sem luz: tensa, mas não assustadora (é um jogo para estudantes)."""
    bpm = 64
    batida = 60 / bpm
    compasso = 4 * batida
    progressao = ["Dm", "A#", "Gm", "A", "Dm", "A#", "Gm", "A"]
    total = len(progressao) * compasso
    f = Faixa(total)
    gotas = {0: ["A5", None, "F5", None], 1: [None, "D5", None, "F5"], 2: ["G5", None, "A#4", None], 3: [None, "C#5", None, "E5"],
             4: ["D5", None, "A5", None], 5: [None, "F5", None, "D5"], 6: ["A#4", None, "G5", None], 7: ["E5", None, "C#5", "A4"]}
    for c, nome in enumerate(progressao):
        t0 = c * compasso
        notas = ACORDES[nome]
        # drone grave com tremolo lento
        f.nota(t0, compasso, freq(notas[0] + "2"), lambda p: triangular(p), 0.35, ataque=0.3, release=0.3)
        f.nota(t0, compasso, freq(notas[0] + "3"), seno, 0.15, ataque=0.6, release=0.4, vibrato=0.003)
        f.nota(t0, compasso, freq(notas[1] + "3"), seno, 0.12, ataque=0.8, release=0.5)
        # "batimento" grave nos tempos 1 e 3
        for b in (0, 2):
            f.nota(t0 + b * batida, 0.25, 55, seno, 0.5, ataque=0.002, decaimento=14, glide_para=40)
            f.nota(t0 + b * batida + 0.22, 0.2, 50, seno, 0.3, ataque=0.002, decaimento=16)
        # gotas agudas espaçadas
        for b, n in enumerate(gotas[c]):
            if n:
                f.nota(t0 + b * batida, batida * 1.8, freq(n), sino, 0.12, ataque=0.003, release=0.3, decaimento=2.2)
    f.salvar(os.path.join(SAIDA, "musica", "escuro.wav"), 0.6)


if __name__ == "__main__":
    gerar_efeitos()
    musica_escola()
    musica_historia()
    musica_escuro()
