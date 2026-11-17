@tool
extends Node2D

# Cavalete de madeira com um papel/tela em cima, desenhado por código.
# Usado em:
#  - Biblioteca (Task 10): cada cartaz da feira, no tamanho proporcional às medidas em cm
#    (assim dá para "ver" que só o B tem o mesmo formato do modelo 18 x 24).
#  - Sala de Artes: pinturas dos alunos (modo "pintura").
# A origem (0, 0) é o chão, onde os pés do cavalete encostam.

@export_enum("cartaz", "pintura") var modo: String = "cartaz"
@export var largura_cm: float = 45.0
@export var altura_cm: float = 60.0
@export var escala: float = 0.42  # pixels por cm
@export var cor: Color = Color(0.3, 0.6, 0.85)
@export var letra: String = ""
@export var mostrar_medida: bool = true

const MADEIRA := Color(0.55, 0.36, 0.2)
const MADEIRA_ESCURA := Color(0.36, 0.22, 0.12)
const CONTORNO := Color(0.15, 0.12, 0.12)

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var w: float = maxf(largura_cm * escala, 6.0)
	var h: float = maxf(altura_cm * escala, 6.0)
	var base_papel: float = -6.0          # onde o papel apoia na trave
	var topo: float = base_papel - h
	# pernas do cavalete (duas na frente abertas + uma atrás)
	draw_line(Vector2(0, topo - 3), Vector2(0, 0), MADEIRA_ESCURA, 2.0)
	draw_line(Vector2(-w * 0.25, base_papel), Vector2(-w * 0.45 - 2, 0), MADEIRA, 2.0)
	draw_line(Vector2(w * 0.25, base_papel), Vector2(w * 0.45 + 2, 0), MADEIRA, 2.0)
	# sombra no chão
	draw_rect(Rect2(-w * 0.5 - 2, -1, w + 4, 3), Color(0, 0, 0, 0.2))
	# papel / tela
	var papel := Rect2(-w / 2.0, topo, w, h)
	draw_rect(papel.grow(1.0), CONTORNO)
	draw_rect(papel, Color(0.97, 0.95, 0.88))
	if modo == "cartaz":
		_desenhar_cartaz(papel)
	else:
		_desenhar_pintura(papel)
	# trave onde o papel apoia
	draw_rect(Rect2(-w / 2.0 - 2, base_papel, w + 4, 2), MADEIRA)
	draw_rect(Rect2(-w / 2.0 - 2, base_papel + 2, w + 4, 1), MADEIRA_ESCURA)

func _desenhar_cartaz(p: Rect2) -> void:
	var font: Font = ThemeDB.fallback_font
	# faixa do título e "conteúdo" do cartaz da feira
	draw_rect(Rect2(p.position, Vector2(p.size.x, p.size.y * 0.28)), cor)
	var meio := p.position + Vector2(p.size.x / 2.0, p.size.y * 0.62)
	var r: float = minf(p.size.x, p.size.y) * 0.22
	draw_circle(meio, r, cor.lightened(0.35))
	draw_rect(Rect2(p.position.x + 2, p.end.y - 3, p.size.x - 4, 1), cor.darkened(0.2))
	if mostrar_medida:
		var txt := "%d x %d" % [int(largura_cm), int(altura_cm)]
		if letra != "":
			txt = letra + ": " + txt
		draw_string(font, Vector2(p.position.x - 10, p.position.y - 2), txt,
			HORIZONTAL_ALIGNMENT_CENTER, p.size.x + 20, 6, Color(1, 0.97, 0.85))

func _desenhar_pintura(p: Rect2) -> void:
	# céu, chão, sol e uma casinha (desenho de aluno)
	draw_rect(Rect2(p.position, Vector2(p.size.x, p.size.y * 0.6)), Color(0.6, 0.82, 0.95))
	draw_rect(Rect2(p.position + Vector2(0, p.size.y * 0.6), Vector2(p.size.x, p.size.y * 0.4)), Color(0.5, 0.78, 0.4))
	draw_circle(p.position + Vector2(p.size.x * 0.78, p.size.y * 0.22), p.size.x * 0.12, Color(1, 0.85, 0.25))
	var cx: float = p.position.x + p.size.x * 0.35
	var chao: float = p.position.y + p.size.y * 0.72
	draw_rect(Rect2(cx - 3, chao - 5, 6, 5), cor)
	draw_colored_polygon(PackedVector2Array([Vector2(cx - 4, chao - 5), Vector2(cx + 4, chao - 5), Vector2(cx, chao - 9)]), cor.darkened(0.3))
