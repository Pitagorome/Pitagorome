@tool
extends Node2D

# Corredor escuro atrás de uma porta, para a porta não parecer uma parede
# quando dá para o lado de fora do prédio.
# Fica como filho da porta (Area2D com door.gd). Descobre sozinho em qual lado
# da sala a porta está e desenha a passagem saindo da sala para fora.

## Quanto a passagem avança para fora da sala (em pixels)
@export var profundidade: float = 260.0
@export var cor_entrada: Color = Color(0.3, 0.24, 0.2)
@export var cor_fundo: Color = Color(0.06, 0.05, 0.05)
@export var cor_batente: Color = Color(0.5, 0.36, 0.26)

const FAIXAS: int = 8 # quantas faixas no degradê (do claro na entrada ao escuro no fundo)
## Que parte do comprimento tem o degradê; o resto é escuro até o fim
@export_range(0.05, 1.0) var parte_degrade: float = 0.25

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var door: Node2D = get_parent() as Node2D
	if door == null:
		return
	var shape_node: CollisionShape2D = door.get_node_or_null("CollisionShape2D") as CollisionShape2D
	var sala: Rect2 = ExteriorFundo.room_rect_of(door.get_parent())
	if shape_node == null or shape_node.shape == null or sala.size == Vector2.ZERO:
		return

	var centro: Vector2 = door.position + shape_node.position
	var tamanho: Vector2 = shape_node.shape.get_rect().size
	var largura: float = maxf(maxf(tamanho.x, tamanho.y), 32.0)

	# Lado da sala mais perto da porta -> direção para fora
	var distancias: Dictionary = {
		Vector2.UP: absf(centro.y - sala.position.y),
		Vector2.DOWN: absf(sala.end.y - centro.y),
		Vector2.LEFT: absf(centro.x - sala.position.x),
		Vector2.RIGHT: absf(sala.end.x - centro.x),
	}
	var fora: Vector2 = Vector2.DOWN
	for dir in distancias:
		if distancias[dir] < distancias[fora]:
			fora = dir

	# Começa no centro da porta (ou na borda da sala, o que estiver mais para dentro)
	var borda: float = sala.end.y if fora == Vector2.DOWN else (sala.position.y if fora == Vector2.UP else (sala.end.x if fora == Vector2.RIGHT else sala.position.x))
	var ao_longo: float = centro.y if fora.y != 0.0 else centro.x
	var inicio: float = minf(ao_longo * _sinal(fora), borda * _sinal(fora)) * _sinal(fora)
	if fora == Vector2.UP:
		# Em cima a parede fica dentro da sala: a passagem começa na base dela (borda de dentro da porta)
		inicio = centro.y + tamanho.y / 2.0
	var fim: float = borda + profundidade * _sinal(fora)

	# Degradê na entrada (claro -> escuro) e depois escuro até o fim, para parecer um corredor que continua
	var fim_degrade: float = lerpf(inicio, fim, parte_degrade)
	for i in FAIXAS:
		var t0: float = float(i) / FAIXAS
		var t1: float = float(i + 1) / FAIXAS
		var cor: Color = cor_entrada.lerp(cor_fundo, t0)
		draw_rect(_faixa(fora, centro, largura, lerpf(inicio, fim_degrade, t0), lerpf(inicio, fim_degrade, t1)), cor)
	draw_rect(_faixa(fora, centro, largura, fim_degrade, fim), cor_fundo)
	# Batentes (laterais da passagem)
	var lado: float = largura / 2.0
	for s in [-1.0, 1.0]:
		var r: Rect2 = _faixa(fora, centro, 3.0, inicio, fim)
		if fora.y != 0.0:
			r.position.x = centro.x - door.position.x + s * lado - (1.5 if s > 0 else 1.5)
		else:
			r.position.y = centro.y - door.position.y + s * lado - 1.5
		draw_rect(r, cor_batente)

# Retângulo (no espaço local da porta) entre as posições a e b ao longo da direção "fora"
func _faixa(fora: Vector2, centro: Vector2, largura: float, a: float, b: float) -> Rect2:
	var door: Node2D = get_parent() as Node2D
	var de: float = minf(a, b)
	var ate: float = maxf(a, b)
	var r: Rect2
	if fora.y != 0.0:
		r = Rect2(centro.x - largura / 2.0, de, largura, ate - de)
	else:
		r = Rect2(de, centro.y - largura / 2.0, ate - de, largura)
	r.position -= door.position
	return r

func _sinal(fora: Vector2) -> float:
	return 1.0 if (fora == Vector2.DOWN or fora == Vector2.RIGHT) else -1.0
