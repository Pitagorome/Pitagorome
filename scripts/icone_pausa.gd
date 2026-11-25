class_name IconePausa
extends Control

# Ícone de pausa (||) em pixel art 13x9, do mesmo tamanho do ícone de som (scripts/icone_som.gd)
# e do de pular. Usado pelo botão de pausa (scripts/menu_pausa.gd).
# Cresce em múltiplos inteiros (1x, 2x...) para continuar nítido.

const LARGURA: int = 13
const ALTURA: int = 9
# duas barras de 3 pixels de largura, com 3 de espaço entre elas
const BARRAS: Array[Rect2i] = [Rect2i(2, 0, 3, 9), Rect2i(8, 0, 3, 9)]

@export var cor: Color = Color(0.99, 0.95, 0.85):
	set(valor):
		cor = valor
		queue_redraw()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var escala: int = maxi(1, mini(int(size.x / LARGURA), int(size.y / ALTURA)))
	var origem: Vector2 = ((size - Vector2(LARGURA, ALTURA) * escala) / 2.0).floor()
	for r in BARRAS:
		draw_rect(Rect2(origem + Vector2(r.position) * escala, Vector2(r.size) * escala), cor)
