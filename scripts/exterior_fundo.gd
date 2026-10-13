@tool
class_name ExteriorFundo
extends Node2D

# Fundo de fora das salas: gramado, calçada e parede externa em volta do prédio,
# no lugar do cinza que aparecia quando a câmera mostrava além da sala.
# Mede a sala pelo nó de fundo (MapBackground / RoomBackground), então basta
# colocar a cena exterior_fundo.tscn como filha da raiz de qualquer sala.

const GRAMA: Texture2D = preload("res://assets/tiles/exterior/grama.png")
const CALCADA: Texture2D = preload("res://assets/tiles/exterior/calcada.png")

## Até onde o gramado vai além da sala (em pixels)
@export var alcance_grama: float = 800.0
## Largura da calçada em volta do prédio (0 = sem calçada, ex.: portão)
@export var largura_calcada: float = 24.0
## Espessura da parede externa do prédio (0 = sem parede)
@export var espessura_parede: float = 6.0
@export var cor_parede: Color = Color(0.42, 0.3, 0.24)

func _ready() -> void:
	z_index = -10
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	queue_redraw()

func _draw() -> void:
	var sala: Rect2 = _room_rect()
	if sala.size == Vector2.ZERO:
		return
	draw_texture_rect(GRAMA, sala.grow(alcance_grama), true)
	if largura_calcada > 0.0:
		draw_texture_rect(CALCADA, sala.grow(espessura_parede + largura_calcada), true)
	if espessura_parede > 0.0:
		draw_rect(sala.grow(espessura_parede), cor_parede)

func _room_rect() -> Rect2:
	return room_rect_of(get_parent())

# Retângulo da sala (piso + parede), medido pelo nó de fundo. Usado também por PassagemPorta.
static func room_rect_of(parent: Node) -> Rect2:
	var sala: Rect2 = Rect2()
	if parent == null:
		return sala
	for bg_name in ["MapBackground", "RoomBackground"]:
		var bg: Node2D = parent.get_node_or_null(bg_name) as Node2D
		if bg == null:
			continue
		for control in bg.get_children():
			if control is Control:
				var r: Rect2 = Rect2(bg.position + control.position, control.size)
				sala = r if sala.size == Vector2.ZERO else sala.merge(r)
	return sala
