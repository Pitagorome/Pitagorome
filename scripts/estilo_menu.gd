class_name EstiloMenu
extends RefCounted

# Visual dos menus (menu inicial e menu de pausa), copiado do site do grupo
# (github.com/Pitagorome/Pitagorome-Site, src/styles.css):
#   - letra pixelada Pixelify Sans (assets/fonts/PixelifySans.ttf, licença OFL ao lado);
#   - botões amarelos com borda verde e sombra dura (o botão "game" do site);
#   - janelinhas escuras (cor --ink do site).
# Usado por scripts/menu_inicial.gd e scripts/menu_pausa.gd.

const FONTE_PIXEL: FontFile = preload("res://assets/fonts/PixelifySans.ttf") # fonte variável (peso 400 a 700)

const LARGURA_BOTAO: int = 150
const ALTURA_BOTAO: int = 26
const TAMANHO_FONTE_BOTAO: int = 13

# Cores do site (src/styles.css, convertidas de oklch)
const COR_AMARELO := Color(0.956, 0.836, 0.463)       # --accent (botões)
const COR_AMARELO_HOVER := Color(1.0, 0.9, 0.6)
const COR_TEXTO_BOTAO := Color(0.096, 0.21, 0.102)    # --accent-foreground
const COR_BORDA := Color(0.177, 0.293, 0.181)         # --panel-border
const COR_SOMBRA := Color(0.065, 0.142, 0.094, 0.45)  # --pixel-shadow
const COR_HUD := Color(0.065, 0.142, 0.094, 0.88)     # --ink (janelinhas e dica)
const COR_CREME := Color(0.965, 0.934, 0.848)         # --ink-foreground
const COR_LARANJA := Color(0.99, 0.75, 0.35)

static var _bold: FontVariation
static var _reg: FontVariation

# Peso 700 (botões e títulos)
static func fonte_bold() -> FontVariation:
	if _bold == null:
		_criar_fontes()
	return _bold

# Peso 500 (textos)
static func fonte_reg() -> FontVariation:
	if _reg == null:
		_criar_fontes()
	return _reg

static func _criar_fontes() -> void:
	# letra pixelada tem que ficar sem suavização, senão borra quando a tela aumenta
	var pixel: FontFile = FONTE_PIXEL.duplicate()
	pixel.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	pixel.hinting = TextServer.HINTING_NONE
	pixel.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	_bold = _peso(pixel, 700)
	_reg = _peso(pixel, 500)

# Mesma fonte com outro peso (Pixelify Sans é variável: eixo "wght")
static func _peso(base: FontFile, peso: int) -> FontVariation:
	var f := FontVariation.new()
	f.base_font = base
	f.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): peso}
	return f

static func label(texto: String, fonte: Font, tamanho: int, cor: Color) -> Label:
	var l := Label.new()
	l.text = texto
	l.add_theme_font_override("font", fonte)
	l.add_theme_font_size_override("font_size", tamanho)
	l.add_theme_color_override("font_color", cor)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

static func botao(texto: String, tamanho: int = TAMANHO_FONTE_BOTAO, altura: int = ALTURA_BOTAO) -> Button:
	var b := Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(0, altura)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_font_override("font", fonte_bold())
	b.add_theme_font_size_override("font_size", tamanho)
	for cor in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color", "font_hover_pressed_color"]:
		b.add_theme_color_override(cor, COR_TEXTO_BOTAO)
	b.add_theme_stylebox_override("normal", estilo_botao(COR_AMARELO, 3))
	b.add_theme_stylebox_override("hover", estilo_botao(COR_AMARELO_HOVER, 3))
	b.add_theme_stylebox_override("focus", estilo_botao(COR_AMARELO_HOVER, 3))
	b.add_theme_stylebox_override("pressed", estilo_botao(COR_AMARELO_HOVER, 1))
	return b

# Botão "game" do site: amarelo, borda verde de 2px, cantos arredondados e sombra dura embaixo
static func estilo_botao(fundo: Color, sombra: int) -> StyleBoxFlat:
	var e := StyleBoxFlat.new()
	e.bg_color = fundo
	e.border_color = COR_BORDA
	e.set_border_width_all(2)
	e.set_corner_radius_all(5)
	e.shadow_color = COR_SOMBRA
	e.shadow_size = 0
	e.shadow_offset = Vector2(sombra, sombra)
	e.content_margin_top = 2
	e.content_margin_bottom = 2
	return e

# Janelinha escura com borda creme
static func estilo_hud(margem: int, opaco: bool = false) -> StyleBoxFlat:
	var e := StyleBoxFlat.new()
	e.bg_color = Color(COR_HUD, 1.0) if opaco else COR_HUD
	e.border_color = Color(COR_CREME, 0.85)
	e.set_border_width_all(1)
	e.set_corner_radius_all(8)
	e.content_margin_left = margem
	e.content_margin_right = margem
	e.content_margin_top = margem * 0.6
	e.content_margin_bottom = margem * 0.6
	return e
