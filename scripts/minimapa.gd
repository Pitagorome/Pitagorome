extends Control

# Minimapa circular (canto superior direito, embaixo do nome do diretor).
# Como funciona: um SubViewport "olha" para o MESMO mundo 2D da sala atual com uma
# câmera mais afastada que segue o jogador. A imagem dele é recortada em círculo por
# um shader, que também desenha a borda amarelo pastel (a mesma cor creme das caixas
# de diálogo). O jogador aparece como um ponto no centro.
# Fica dentro do HUD (scenes/ui/hud.tscn), então aparece em todas as salas.

const DIAMETRO: int = 72               # tamanho na interface (resolução base 640x360)
const RESOLUCAO: int = 144             # pixels reais do mapa (a tela é 1280x720, o dobro)
const ZOOM: float = 0.5                # quanto da sala aparece (menor = mais longe)
const COR_BORDA := Color(0.95, 0.91, 0.82)   # amarelo pastel / creme do diálogo
const COR_CONTORNO := Color(0.29, 0.4, 0.25)  # verde escuro da interface
const COR_JOGADOR := Color(0.99, 0.75, 0.35)  # dourado do crachá "Diretor(a)"

const SHADER := """
shader_type canvas_item;
uniform vec4 borda : source_color;
uniform vec4 contorno : source_color;
uniform float largura_borda = 0.07;
uniform float largura_contorno = 0.025;
void fragment() {
	float r = length(UV - vec2(0.5)) * 2.0;
	vec4 mapa = texture(TEXTURE, UV);
	float aa = fwidth(r);
	vec4 cor = mapa;
	cor = mix(cor, borda, smoothstep(1.0 - largura_borda - largura_contorno - aa, 1.0 - largura_borda - largura_contorno, r));
	cor = mix(cor, contorno, smoothstep(1.0 - largura_contorno - aa, 1.0 - largura_contorno, r));
	// fio escuro também por dentro da borda, para separar do mapa
	float fio = smoothstep(1.0 - largura_borda - largura_contorno - 0.02, 1.0 - largura_borda - largura_contorno - 0.01, r)
		* (1.0 - smoothstep(1.0 - largura_borda - largura_contorno - 0.01 + aa, 1.0 - largura_borda - largura_contorno + aa, r));
	cor = mix(cor, contorno, fio * 0.8);
	cor.a *= 1.0 - smoothstep(1.0 - aa, 1.0, r);
	COLOR = cor;
}
"""

var viewport: SubViewport
var camera: Camera2D
var tela: TextureRect
var ponto: Control

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(DIAMETRO, DIAMETRO)
	size = Vector2(DIAMETRO, DIAMETRO)

	viewport = SubViewport.new()
	viewport.size = Vector2i(RESOLUCAO, RESOLUCAO)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	add_child(viewport)
	camera = Camera2D.new()
	camera.zoom = Vector2(ZOOM, ZOOM)
	viewport.add_child(camera)

	tela = TextureRect.new()
	tela.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tela.texture = viewport.get_texture()
	tela.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tela.stretch_mode = TextureRect.STRETCH_SCALE
	tela.size = Vector2(DIAMETRO, DIAMETRO)
	var mat := ShaderMaterial.new()
	mat.shader = Shader.new()
	mat.shader.code = SHADER
	mat.set_shader_parameter("borda", COR_BORDA)
	mat.set_shader_parameter("contorno", COR_CONTORNO)
	tela.material = mat
	add_child(tela)

	ponto = Control.new()
	ponto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ponto.size = Vector2(DIAMETRO, DIAMETRO)
	ponto.draw.connect(_desenhar_jogador)
	add_child(ponto)

	# usa o mesmo mundo 2D da cena principal (a sala atual)
	viewport.world_2d = get_viewport().world_2d

func _process(_delta: float) -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	visible = player != null
	if player == null:
		return
	camera.global_position = player.global_position
	ponto.queue_redraw()

func _desenhar_jogador() -> void:
	var c := Vector2(DIAMETRO, DIAMETRO) / 2.0
	var pulso: float = 1.0 + 0.15 * sin(Time.get_ticks_msec() / 200.0)
	ponto.draw_circle(c, 3.5 * pulso, Color(COR_JOGADOR, 0.35))
	ponto.draw_circle(c, 2.4, COR_CONTORNO)
	ponto.draw_circle(c, 1.7, COR_JOGADOR)
