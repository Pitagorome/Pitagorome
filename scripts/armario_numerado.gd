extends "res://scripts/interactable_object.gd"

# Armário numerado da Sala dos Armários (Task 6 — O Troféu Desaparecido).
# Na cena é só trocar o "numero" no Inspetor: a plaquinha muda sozinha.
# Ao abrir, quem decide o que tem dentro é o Fase2Flow (flow_event = "armario_numerado").
#
# O tileset não tem armário escolar (o sprite antigo era uma porta de elevador e
# confundia), então o armário é desenhado aqui: alto, pintado, com frestas de
# ventilação, maçaneta e plaquinha com o número.

@export var numero: int = 1
@export var cor: Color = Color(0.27, 0.5, 0.74)

const W: float = 18.0   # largura
const TOPO: float = -26.0
const BASE: float = 11.0

func _ready() -> void:
	flow_event = "armario_numerado"
	flow_value = str(numero)
	hint_text = "[E] Abrir armário %d" % numero
	object_name = "Armário %d" % numero
	var placa: Label = get_node_or_null("Numero") as Label
	if placa:
		placa.text = str(numero)
	var sprite: Node = get_node_or_null("Sprite2D")
	if sprite:
		sprite.visible = false
	super._ready()
	queue_redraw()

func _draw() -> void:
	var x0: float = -W / 2.0
	var escuro: Color = cor.darkened(0.45)
	var claro: Color = cor.lightened(0.25)
	# sombra no chão
	draw_rect(Rect2(x0 + 1, BASE - 2, W, 4), Color(0, 0, 0, 0.25))
	# corpo + contorno
	draw_rect(Rect2(x0 - 1, TOPO - 1, W + 2, BASE - TOPO + 1), Color(0.12, 0.14, 0.2))
	draw_rect(Rect2(x0, TOPO, W, BASE - TOPO - 1), cor)
	# topo (dá volume) e pé
	draw_rect(Rect2(x0, TOPO, W, 3), claro)
	draw_rect(Rect2(x0, BASE - 3, W, 2), escuro)
	# porta (moldura interna)
	draw_rect(Rect2(x0 + 2, TOPO + 4, W - 4, BASE - TOPO - 8), escuro, false, 1.0)
	# plaquinha do número
	draw_rect(Rect2(-5, TOPO + 5, 10, 7), Color(0.95, 0.92, 0.8))
	# frestas de ventilação
	for i in 3:
		var y: float = TOPO + 15 + i * 3
		draw_line(Vector2(x0 + 4, y), Vector2(-x0 - 4, y), escuro, 1.0)
	# maçaneta / cadeado
	draw_rect(Rect2(-x0 - 6, -2, 2, 5), Color(0.85, 0.85, 0.88))
	draw_rect(Rect2(-x0 - 6, 3, 2, 2), Color(0.3, 0.3, 0.32))
