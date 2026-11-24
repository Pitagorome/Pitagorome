class_name IconeSom
extends Control

# Ícone de alto-falante desenhado na hora (o caractere 🔊 não existe na fonte
# Montserrat e vira quadradinho na versão web). Com "mudo" ligado mostra um X.
# Usado pelo botão de volume (scripts/controle_volume.gd).

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

func _draw() -> void:
	var s: float = minf(size.x, size.y)
	var o: Vector2 = (size - Vector2(s, s)) / 2.0
	var p := func(x: float, y: float) -> Vector2: return o + Vector2(x, y) * s
	# corpo do alto-falante (caixinha + cone)
	draw_colored_polygon(PackedVector2Array([
		p.call(0.10, 0.38), p.call(0.28, 0.38), p.call(0.52, 0.16),
		p.call(0.52, 0.84), p.call(0.28, 0.62), p.call(0.10, 0.62),
	]), cor)
	var largura: float = maxf(1.0, s * 0.08)
	if mudo:
		draw_line(p.call(0.64, 0.36), p.call(0.92, 0.64), cor, largura, true)
		draw_line(p.call(0.92, 0.36), p.call(0.64, 0.64), cor, largura, true)
		return
	# ondas de som: 1 a 3 conforme o volume
	var centro: Vector2 = p.call(0.50, 0.50)
	var ondas: int = 0 if nivel <= 0.0 else (1 if nivel < 0.34 else (2 if nivel < 0.67 else 3))
	for i in ondas:
		var raio: float = s * (0.16 + 0.13 * i)
		draw_arc(centro, raio, -PI / 3.2, PI / 3.2, 10, cor, largura, true)
