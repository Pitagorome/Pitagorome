class_name IconeSom
extends Control

# Ícone de alto-falante em pixel art 13x9 (mesmo tamanho do ícone de pular da historinha,
# assets/ui/icone_pular.png). É desenhado por código porque o caractere 🔊 não existe na
# fonte Montserrat e vira quadradinho na versão web. Com "mudo" ligado mostra um X.
# Cresce em múltiplos inteiros (1x, 2x...) para continuar nítido.
# Usado pelo botão de volume (scripts/controle_volume.gd).

const LARGURA: int = 13
const ALTURA: int = 9

# Corpo do alto-falante (caixinha + cone)
const CORPO: Array[Vector2i] = [
	Vector2i(4, 0),
	Vector2i(3, 1), Vector2i(4, 1),
	Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2),
	Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 3),
	Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4),
	Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5), Vector2i(3, 5), Vector2i(4, 5),
	Vector2i(0, 6), Vector2i(1, 6), Vector2i(2, 6), Vector2i(3, 6), Vector2i(4, 6),
	Vector2i(3, 7), Vector2i(4, 7),
	Vector2i(4, 8),
]
# Ondas de som, da menor para a maior
const ONDAS: Array = [
	[Vector2i(6, 3), Vector2i(7, 4), Vector2i(6, 5)],
	[Vector2i(8, 1), Vector2i(9, 2), Vector2i(9, 3), Vector2i(9, 4), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 7)],
	[Vector2i(11, 0), Vector2i(12, 1), Vector2i(12, 2), Vector2i(12, 3), Vector2i(12, 4), Vector2i(12, 5),
		Vector2i(12, 6), Vector2i(12, 7), Vector2i(11, 8)],
]
const X_MUDO: Array[Vector2i] = [
	Vector2i(7, 2), Vector2i(11, 2), Vector2i(8, 3), Vector2i(10, 3), Vector2i(9, 4),
	Vector2i(8, 5), Vector2i(10, 5), Vector2i(7, 6), Vector2i(11, 6),
]

@export var mudo: bool = false:
	set(valor):
		mudo = valor
		queue_redraw()
@export var nivel: float = 1.0: # 0..1: quantas "ondas" aparecem
	set(valor):
		nivel = valor
		queue_redraw()
@export var cor: Color = Color(0.98, 0.96, 0.88):
	set(valor):
		cor = valor
		queue_redraw()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var escala: int = maxi(1, mini(int(size.x / LARGURA), int(size.y / ALTURA)))
	var origem: Vector2 = ((size - Vector2(LARGURA, ALTURA) * escala) / 2.0).floor()
	var pixels: Array[Vector2i] = CORPO.duplicate()
	if mudo:
		pixels.append_array(X_MUDO)
	else:
		var ondas: int = 0 if nivel <= 0.0 else (1 if nivel < 0.34 else (2 if nivel < 0.67 else 3))
		for i in ondas:
			for p in ONDAS[i]:
				pixels.append(p)
	for p in pixels:
		draw_rect(Rect2(origem + Vector2(p) * escala, Vector2(escala, escala)), cor)
