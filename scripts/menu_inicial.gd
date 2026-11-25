extends Node2D

# Menu inicial (cena principal: scenes/ui/menu_inicial.tscn). Pedido de 24/11, refeito no mesmo dia
# ("tá muito feio"): inspirado no site do grupo (github.com/Pitagorome/Pitagorome-Site) e no menu
# do Aeromática.
#   - fundo: a ilustração da Escola Pitagórica do site (assets/ui/menu_fundo.jpg);
#   - título: o logo oficial sem a faixa (assets/ui/logo.png = Pitagorome-Site/Site/src/assets/logo.png);
#   - fonte pixelada Pixelify Sans, a mesma do site (assets/fonts/PixelifySans.ttf, licença OFL ao lado);
#   - os 4 botões com o mesmo tamanho (LARGURA_BOTAO x ALTURA_BOTAO);
#   - botões amarelos com borda verde e sombra "pixel", iguais ao botão "game" do site;
#   - o diretor (Adam) passa andando pela calçada, como no topo do site.
# Botões:
#   Jogar    -> historinha do começo (scenes/intro/historia_inicio.tscn)
#   Volume   -> janelinha com Geral, Música e Interações (as mesmas barrinhas do botão do canto,
#               ControleVolume.criar_linhas, tudo sincronizado)
#   Créditos -> equipe e ferramentas
#   Sair     -> fecha o jogo (só no executável; no navegador não aparece)
# Enter/Espaço apertam Jogar; Esc fecha a janelinha aberta.

const CENA_HISTORIA: String = "res://scenes/intro/historia_inicio.tscn"
const FUNDO: Texture2D = preload("res://assets/ui/menu_fundo.jpg")
const LOGO: Texture2D = preload("res://assets/ui/logo.png")
const FRAMES_DIRETOR: SpriteFrames = preload("res://assets/character_frames/adam_frames.tres")
const FONTE_PIXEL: FontFile = preload("res://assets/fonts/PixelifySans.ttf") # fonte variável (peso 400 a 700)
const LARGURA_BOTAO: int = 150
const ALTURA_BOTAO: int = 26
const TAMANHO_FONTE_BOTAO: int = 13

var FONTE_BOLD: FontVariation
var FONTE_REG: FontVariation

# Cores do site (src/styles.css, convertidas de oklch)
const COR_AMARELO := Color(0.956, 0.836, 0.463)       # --accent (botões)
const COR_AMARELO_HOVER := Color(1.0, 0.9, 0.6)
const COR_TEXTO_BOTAO := Color(0.096, 0.21, 0.102)    # --accent-foreground
const COR_BORDA := Color(0.177, 0.293, 0.181)         # --panel-border
const COR_SOMBRA := Color(0.065, 0.142, 0.094, 0.45)  # --pixel-shadow
const COR_HUD := Color(0.065, 0.142, 0.094, 0.88)     # --ink (janelinhas e dica)
const COR_CREME := Color(0.965, 0.934, 0.848)         # --ink-foreground
const COR_LARANJA := Color(0.99, 0.75, 0.35)

const EQUIPE: Array[String] = [
	"Ana Julia Cardoso Moser",
	"Eduardo de Lazzari Oliveira",
	"Guilherme Pereira de Oliveira",
	"João Paulo Queiroz Costa",
]

var botao_jogar: Button
var botao_volume: Button
var botao_creditos: Button
var botao_sair: Button
var janela_volume: PanelContainer
var caixa_volume: VBoxContainer
var janela_creditos: PanelContainer
var veu: ColorRect # escurece o menu atrás da janelinha aberta; clicar nele fecha
var diretor: AnimatedSprite2D
var saindo: bool = false

# Mesma fonte com outro peso (Pixelify Sans é variável: eixo "wght")
func _peso(base: FontFile, peso: int) -> FontVariation:
	var f := FontVariation.new()
	f.base_font = base
	f.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): peso}
	return f

func _ready() -> void:
	# letra pixelada tem que ficar sem suavização, senão borra quando a tela aumenta
	var pixel: FontFile = FONTE_PIXEL.duplicate()
	pixel.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	pixel.hinting = TextServer.HINTING_NONE
	pixel.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	FONTE_BOLD = _peso(pixel, 700)
	FONTE_REG = _peso(pixel, 500)
	_montar_interface()
	botao_jogar.grab_focus.call_deferred() # Enter/Espaço já começa o jogo

func _process(delta: float) -> void:
	# o diretor atravessa a calçada e volta a entrar pela esquerda
	if diretor:
		diretor.position.x += 38.0 * delta
		if diretor.position.x > 680.0:
			diretor.position.x = -40.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and (janela_volume.visible or janela_creditos.visible):
		get_viewport().set_input_as_handled()
		_fechar_janelas()

func _montar_interface() -> void:
	var ui := CanvasLayer.new()
	ui.name = "UI"
	ui.layer = 5
	add_child(ui)

	var fundo := TextureRect.new()
	fundo.texture = FUNDO
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fundo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fundo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	fundo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	fundo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(fundo)

	# Diretor andando na calçada (como no topo do site)
	diretor = AnimatedSprite2D.new()
	diretor.sprite_frames = FRAMES_DIRETOR
	diretor.animation = &"walk_right"
	diretor.scale = Vector2(2, 2)
	diretor.position = Vector2(60, 330)
	diretor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	diretor.play()
	ui.add_child(diretor)

	var logo := TextureRect.new()
	logo.texture = LOGO
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	logo.anchor_left = 0.5
	logo.anchor_right = 0.5
	# 520x84 desenhado em 260x42: na janela padrão (1280x720, 2x) fica pixel por pixel, sem borrar
	logo.offset_left = -130
	logo.offset_right = 130
	logo.offset_top = 44
	logo.offset_bottom = 44 + 42
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(logo)

	var coluna := VBoxContainer.new()
	coluna.name = "Botoes"
	coluna.add_theme_constant_override("separation", 10)
	coluna.anchor_left = 0.5
	coluna.anchor_right = 0.5
	coluna.offset_left = -LARGURA_BOTAO / 2.0
	coluna.offset_right = LARGURA_BOTAO / 2.0
	coluna.offset_top = 112
	ui.add_child(coluna)

	botao_jogar = _botao("Jogar")
	botao_jogar.pressed.connect(jogar)
	coluna.add_child(botao_jogar)

	botao_volume = _botao("Volume")
	botao_volume.pressed.connect(alternar_volume)
	coluna.add_child(botao_volume)

	botao_creditos = _botao("Créditos")
	botao_creditos.pressed.connect(alternar_creditos)
	coluna.add_child(botao_creditos)

	botao_sair = _botao("Sair")
	botao_sair.pressed.connect(func(): get_tree().quit())
	botao_sair.visible = not OS.has_feature("web") # no navegador é só fechar a aba
	coluna.add_child(botao_sair)

	# Dica dos controles, numa "plaquinha" escura como o HUD do jogo/site
	var dica := PanelContainer.new()
	dica.add_theme_stylebox_override("panel", _estilo_hud(5))
	dica.anchor_left = 0.5
	dica.anchor_right = 0.5
	dica.anchor_top = 1.0
	dica.anchor_bottom = 1.0
	dica.offset_left = -150
	dica.offset_right = 150
	dica.offset_top = -50
	dica.offset_bottom = -50
	dica.grow_horizontal = Control.GROW_DIRECTION_BOTH
	dica.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var texto_dica := _label("WASD ou setas para andar  ·  E para interagir  ·  Tab abre a tarefa", FONTE_REG, 9, COR_CREME)
	texto_dica.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dica.add_child(texto_dica)
	ui.add_child(dica)

	veu = ColorRect.new()
	veu.name = "Veu"
	veu.color = Color(0, 0, 0, 0.45)
	veu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veu.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed:
			_fechar_janelas())
	ui.add_child(veu)

	# Janelinha de volume
	janela_volume = _janela("Volume")
	caixa_volume = janela_volume.get_meta("conteudo")
	ControleVolume.criar_linhas(caixa_volume, 10, 130.0)
	for l in caixa_volume.find_children("*", "Label", true, false):
		(l as Label).add_theme_font_override("font", FONTE_REG) # mesma letra pixelada do resto do menu
	ui.add_child(janela_volume)

	# Janelinha de créditos
	janela_creditos = _janela("Créditos")
	var cred: VBoxContainer = janela_creditos.get_meta("conteudo")
	cred.add_child(_label("Equipe", FONTE_BOLD, 10, COR_LARANJA))
	for nome in EQUIPE:
		cred.add_child(_label(nome, FONTE_REG, 9, COR_CREME))
	var espaco := Control.new()
	espaco.custom_minimum_size = Vector2(0, 4)
	cred.add_child(espaco)
	cred.add_child(_label("Feito com", FONTE_BOLD, 10, COR_LARANJA))
	cred.add_child(_label("Godot Engine 4 · GDScript · pixel art", FONTE_REG, 9, COR_CREME))
	cred.add_child(_label("Trabalho de Desenvolvimento de Sistemas · IFSP", FONTE_REG, 9, COR_CREME))
	ui.add_child(janela_creditos)
	_fechar_janelas()

func jogar() -> void:
	if saindo or Transition.is_transitioning:
		return
	saindo = true
	GameManager.reset_progress()
	Transition.change_scene(CENA_HISTORIA)

func alternar_volume() -> void:
	var abrir: bool = not janela_volume.visible
	_fechar_janelas()
	janela_volume.visible = abrir
	caixa_volume.visible = abrir
	veu.visible = abrir

func alternar_creditos() -> void:
	var abrir: bool = not janela_creditos.visible
	_fechar_janelas()
	janela_creditos.visible = abrir
	veu.visible = abrir

func _fechar_janelas() -> void:
	janela_volume.visible = false
	caixa_volume.visible = false
	janela_creditos.visible = false
	veu.visible = false
	if is_inside_tree() and botao_jogar.is_inside_tree():
		botao_jogar.grab_focus.call_deferred()

# ---------------- visual ----------------

# Janelinha centralizada embaixo dos botões, com título e "Fechar"
func _janela(titulo: String) -> PanelContainer:
	var j := PanelContainer.new()
	j.name = "Janela" + titulo.replace("é", "e")
	j.add_theme_stylebox_override("panel", _estilo_hud(12, true))
	j.anchor_left = 0.5
	j.anchor_right = 0.5
	j.anchor_top = 0.5
	j.anchor_bottom = 0.5
	j.offset_left = -125
	j.offset_right = 125
	j.offset_top = -95
	j.offset_bottom = -95
	j.grow_horizontal = Control.GROW_DIRECTION_BOTH
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	j.add_child(vbox)
	var cabeca := HBoxContainer.new()
	vbox.add_child(cabeca)
	var t := _label(titulo, FONTE_BOLD, 13, COR_AMARELO)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cabeca.add_child(t)
	var fechar := _botao("Fechar", 10, 18)
	fechar.custom_minimum_size.x = 56
	fechar.pressed.connect(_fechar_janelas)
	cabeca.add_child(fechar)
	var conteudo := VBoxContainer.new()
	conteudo.add_theme_constant_override("separation", 3)
	vbox.add_child(conteudo)
	j.set_meta("conteudo", conteudo)
	return j

func _estilo_hud(margem: int, opaco: bool = false) -> StyleBoxFlat:
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

# Botão "game" do site: amarelo, borda verde de 2px, cantos arredondados e sombra dura embaixo
func _estilo_botao(fundo: Color, sombra: int) -> StyleBoxFlat:
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

func _label(texto: String, fonte: Font, tamanho: int, cor: Color) -> Label:
	var l := Label.new()
	l.text = texto
	l.add_theme_font_override("font", fonte)
	l.add_theme_font_size_override("font_size", tamanho)
	l.add_theme_color_override("font_color", cor)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _botao(texto: String, tamanho: int = TAMANHO_FONTE_BOTAO, altura: int = ALTURA_BOTAO) -> Button:
	var b := Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(0, altura)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_font_override("font", FONTE_BOLD)
	b.add_theme_font_size_override("font_size", tamanho)
	for cor in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color", "font_hover_pressed_color"]:
		b.add_theme_color_override(cor, COR_TEXTO_BOTAO)
	b.add_theme_stylebox_override("normal", _estilo_botao(COR_AMARELO, 3))
	b.add_theme_stylebox_override("hover", _estilo_botao(COR_AMARELO_HOVER, 3))
	b.add_theme_stylebox_override("focus", _estilo_botao(COR_AMARELO_HOVER, 3))
	b.add_theme_stylebox_override("pressed", _estilo_botao(COR_AMARELO_HOVER, 1))
	return b
