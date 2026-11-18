extends Control

# Minimapa circular (canto superior direito, embaixo do nome do diretor).
# Mostra a ESCOLA INTEIRA de forma esquemática (cada sala é um retângulo, ligado às
# vizinhas pelas portas), para o jogador saber para onde ir:
#   • ponto BRANCO  = onde você está (a posição dentro da sala também conta)
#   • ponto AMARELO = onde está a missão atual (pisca)
# Embaixo do círculo aparece "Você: <sala>" e "Missão: <sala>".
# Fica dentro do HUD (scenes/ui/hud.tscn), então aparece em todas as salas.
#
# Para mudar o desenho do mapa, edite SALAS (x, y, largura, altura, em unidades do mapa)
# e LIGACOES. O mapa inteiro é centralizado e escalado sozinho para caber no círculo.
# As chaves de SALAS são os location_id das cenas (school_room.gd).

const DIAMETRO: float = 104.0
const COR_BORDA := Color(0.95, 0.91, 0.82)      # amarelo pastel / creme das caixas de diálogo
const COR_CONTORNO := Color(0.29, 0.4, 0.25)     # verde escuro da interface
const COR_FUNDO := Color(0.13, 0.19, 0.12, 0.88)
const COR_SALA := Color(0.42, 0.52, 0.36, 1.0)
const COR_SALA_ATUAL := Color(0.95, 0.91, 0.82, 0.95)
const COR_LIGACAO := Color(0.73, 0.81, 0.6, 0.8)
const COR_MISSAO := Color(1.0, 0.84, 0.25)
const COR_VOCE := Color(1, 1, 1)

const SALAS: Dictionary = {
	"sala_artes":     {"rect": Rect2(-66, -62, 28, 22), "nome": "Sala de Artes"},
	"sala_armarios":  {"rect": Rect2(-34, -62, 28, 22), "nome": "Sala dos Armários"},
	"sala_gerador":   {"rect": Rect2(-104, -34, 30, 20), "nome": "Sala do Gerador"},
	"ala_refeitorio": {"rect": Rect2(-70, -32, 60, 16), "nome": "Ala do Refeitório"},
	"refeitorio":     {"rect": Rect2(-4, -40, 38, 24), "nome": "Refeitório"},
	"biblioteca":     {"rect": Rect2(-12, -8, 34, 22), "nome": "Biblioteca"},
	"coordenacao":    {"rect": Rect2(-98, 18, 32, 20), "nome": "Coordenação"},
	"corredor":       {"rect": Rect2(-62, 20, 124, 16), "nome": "Corredor"},
	"matematica":     {"rect": Rect2(66, 16, 32, 24), "nome": "Sala de Matemática"},
	"almoxarifado":   {"rect": Rect2(-54, 42, 28, 20), "nome": "Almoxarifado"},
	"gabinete":       {"rect": Rect2(-14, 42, 28, 22), "nome": "Gabinete"},
	"portao":         {"rect": Rect2(26, 42, 30, 20), "nome": "Portão"},
}
# Salas ligadas por porta: [sala A, sala B, ponto da porta (unidades do mapa)]
const LIGACOES: Array = [
	["corredor", "ala_refeitorio", Vector2(-48, 0)],
	["corredor", "biblioteca", Vector2(5, 17)],
	["corredor", "coordenacao", Vector2(-64, 28)],
	["corredor", "matematica", Vector2(64, 28)],
	["corredor", "almoxarifado", Vector2(-40, 39)],
	["corredor", "gabinete", Vector2(0, 39)],
	["corredor", "portao", Vector2(41, 39)],
	["ala_refeitorio", "sala_artes", Vector2(-52, -36)],
	["ala_refeitorio", "sala_armarios", Vector2(-24, -36)],
	["ala_refeitorio", "sala_gerador", Vector2(-72, -24)],
	["ala_refeitorio", "refeitorio", Vector2(-7, -24)],
]

var fonte: Font
var escala: float = 1.0
var centro_mapa := Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	fonte = load("res://assets/fonts/Montserrat-Bold.ttf")
	# encaixa o mapa inteiro dentro do círculo
	var limites := Rect2()
	var primeiro := true
	for id in SALAS:
		var r: Rect2 = SALAS[id]["rect"]
		limites = r if primeiro else limites.merge(r)
		primeiro = false
	centro_mapa = limites.get_center()
	var raio_mapa: float = 0.0
	for id in SALAS:
		var r: Rect2 = SALAS[id]["rect"]
		for canto in [r.position, r.end, Vector2(r.position.x, r.end.y), Vector2(r.end.x, r.position.y)]:
			raio_mapa = maxf(raio_mapa, (canto - centro_mapa).length())
	escala = (DIAMETRO / 2.0 - 7.0) / raio_mapa

func _process(_delta: float) -> void:
	var player: Node = get_tree().get_first_node_in_group("player")
	visible = player != null and sala_atual() != ""
	if visible:
		queue_redraw()

# ----------------------------------------------------------------
# Onde é a missão (sala) de acordo com a tarefa e o que já aconteceu
# ----------------------------------------------------------------
static func local_da_missao() -> String:
	var t: int = GameManager.current_task_id
	if t <= 0 or GameManager.is_task_completed(t):
		return ""
	match t:
		1:
			return "matematica" if GameManager.tour_talked_zelador else "corredor"
		2:
			return "gabinete"
		3:
			return "almoxarifado"
		4:
			return "corredor"
		5:
			return "portao" if GameManager.current_objective.contains("Portão") else "gabinete"
		6:
			return "sala_armarios" if GameManager.seen_events.has("t6_briefing") else "corredor"
		7:
			return "sala_artes"
		8:
			return "sala_gerador"
		9:
			return "refeitorio"
		10:
			return "biblioteca"
	return ""

func sala_atual() -> String:
	var cena: Node = get_tree().current_scene
	if cena == null:
		return ""
	var id: String = str(cena.get("location_id")) if cena.get("location_id") != null else ""
	return id if SALAS.has(id) else ""

func _para_tela(p: Vector2) -> Vector2:
	return size / 2.0 - Vector2(0, (size.y - DIAMETRO) / 2.0) + (p - centro_mapa) * escala

func _rect_tela(r: Rect2) -> Rect2:
	return Rect2(_para_tela(r.position), r.size * escala)

# Posição do jogador dentro da sala, convertida para o retângulo da sala no mapa
func _posicao_jogador(sala: String) -> Vector2:
	var r: Rect2 = _rect_tela(SALAS[sala]["rect"])
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	var piso: Control = get_tree().current_scene.find_child("Floor", true, false) as Control
	if player == null or piso == null:
		return r.get_center()
	var area: Rect2 = piso.get_global_rect()
	var rel: Vector2 = ((player.global_position - area.position) / area.size).clamp(Vector2(0.1, 0.12), Vector2(0.9, 0.88))
	return r.position + rel * r.size

func _draw() -> void:
	var c := Vector2(size.x / 2.0, DIAMETRO / 2.0)
	var raio: float = DIAMETRO / 2.0
	var atual: String = sala_atual()
	var missao: String = local_da_missao()

	draw_circle(c, raio, COR_FUNDO)
	# ligações (portas)
	for lig in LIGACOES:
		var a: Vector2 = _rect_tela(SALAS[lig[0]]["rect"]).get_center()
		var b: Vector2 = _rect_tela(SALAS[lig[1]]["rect"]).get_center()
		var porta: Vector2 = _para_tela(lig[2])
		draw_line(a, porta, COR_LIGACAO, 1.0)
		draw_line(porta, b, COR_LIGACAO, 1.0)
	# salas (a atual fica clara)
	for id in SALAS:
		var r: Rect2 = _rect_tela(SALAS[id]["rect"])
		draw_rect(r, COR_SALA_ATUAL if id == atual else COR_SALA)
		draw_rect(r, COR_CONTORNO, false, 1.0)
	if missao != "":
		draw_rect(_rect_tela(SALAS[missao]["rect"]).grow(0.5), COR_MISSAO, false, 1.0)
	# borda amarelo pastel
	draw_arc(c, raio - 2.0, 0, TAU, 64, COR_BORDA, 4.0, true)
	draw_arc(c, raio, 0, TAU, 64, COR_CONTORNO, 1.0, true)
	draw_arc(c, raio - 4.0, 0, TAU, 64, COR_CONTORNO, 0.6, true)

	# ponto amarelo da missão (pisca) e ponto branco do jogador
	if missao != "":
		var pm: Vector2 = _rect_tela(SALAS[missao]["rect"]).get_center()
		var pulso: float = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 180.0)
		draw_circle(pm, 3.2 + pulso * 1.6, Color(COR_MISSAO, 0.35))
		draw_circle(pm, 2.6, COR_CONTORNO)
		draw_circle(pm, 2.0, COR_MISSAO)
	if atual != "":
		var pj: Vector2 = _posicao_jogador(atual)
		draw_circle(pj, 2.4, COR_CONTORNO)
		draw_circle(pj, 1.7, COR_VOCE)

	# legenda embaixo do círculo
	var y: float = DIAMETRO + 9.0
	_legenda(y, COR_VOCE, "Você: " + (SALAS[atual]["nome"] if atual != "" else "-"))
	if missao != "":
		_legenda(y + 9.0, COR_MISSAO, "Missão: " + SALAS[missao]["nome"])

func _legenda(y: float, cor: Color, texto: String) -> void:
	var largura: float = fonte.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 6).x + 8.0
	var x: float = size.x - largura
	draw_circle(Vector2(x + 2.0, y - 2.0), 2.0, COR_CONTORNO)
	draw_circle(Vector2(x + 2.0, y - 2.0), 1.4, cor)
	draw_string_outline(fonte, Vector2(x + 6.0, y), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 6, 2, Color(0, 0, 0, 0.75))
	draw_string(fonte, Vector2(x + 6.0, y), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color(0.98, 0.96, 0.88))
