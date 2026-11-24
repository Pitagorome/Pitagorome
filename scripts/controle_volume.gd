extends CanvasLayer

# Autoload: ControleVolume
# Botão de alto-falante no canto superior direito (na historinha, ao lado do botão de
# pular). Clicando nele abre um
# painel com 3 controles de volume, cada um com botão de mudo:
#   Geral       -> bus Master (o jogo todo)
#   Música      -> bus Musica (trilhas)
#   Interações  -> bus Efeitos (cliques, portas, falas, acertos, erros...)
# Quem guarda e aplica os volumes é o Audio (scripts/audio_manager.gd), que salva em
# user://audio.cfg, então o volume escolhido continua na próxima vez que abrir o jogo.
# Fecha clicando fora do painel ou no botão de novo. A tecla M continua mutando a música.

const FONTE: FontFile = preload("res://assets/fonts/Montserrat-Bold.ttf")
const COR_TEXTO := Color(0.98, 0.96, 0.88)
const COR_DESTAQUE := Color(1, 0.9, 0.55)
const COR_FUNDO := Color(0.13, 0.19, 0.12, 0.92)
const COR_BORDA := Color(0.95, 0.91, 0.82, 0.9) # amarelo pastel, igual ao minimapa

const LINHAS: Array = [
	["Master", "Geral", "Volume do jogo todo"],
	["Musica", "Música", "Música de fundo (tecla M liga/desliga)"],
	["Efeitos", "Interações", "Cliques, portas, falas, acertos e erros"],
]

var botao: Button
var icone_botao: IconeSom
var painel: PanelContainer
var aberto: bool = false
var _sliders: Dictionary = {}    # bus -> HSlider
var _icones: Dictionary = {}     # bus -> IconeSom
var _porcentos: Dictionary = {}  # bus -> Label
var _atualizando: bool = false
var _cena_posicao: Node = null
var _botao_pular: Control = null
var _com_pular: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # funciona com o jogo pausado
	layer = 61 # por cima de tudo do jogo, até da tela preta (50) e do botão de pular da historinha (60)
	_criar_botao()
	_criar_painel()
	Audio.volume_mudou.connect(_atualizar)
	_atualizar()
	fechar()

func _criar_botao() -> void:
	botao = Button.new()
	botao.focus_mode = Control.FOCUS_NONE # não rouba Espaço/Enter dos diálogos
	botao.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	botao.tooltip_text = "Volume"
	# Posição de verdade em _posicionar() (canto superior direito)
	botao.anchor_left = 1.0
	botao.anchor_right = 1.0
	botao.offset_left = -34
	botao.offset_right = -12
	botao.offset_top = 166
	botao.offset_bottom = 188
	for estado in ["normal", "hover", "pressed", "focus"]:
		botao.add_theme_stylebox_override(estado, _estilo(estado == "hover" or estado == "pressed"))
	botao.pressed.connect(alternar)
	botao.mouse_entered.connect(func(): icone_botao.cor = COR_DESTAQUE)
	botao.mouse_exited.connect(func(): icone_botao.cor = COR_TEXTO)
	add_child(botao)
	icone_botao = IconeSom.new()
	icone_botao.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icone_botao.offset_left = 4
	icone_botao.offset_top = 4
	icone_botao.offset_right = -4
	icone_botao.offset_bottom = -4
	botao.add_child(icone_botao)

func _criar_painel() -> void:
	painel = PanelContainer.new()
	painel.add_theme_stylebox_override("panel", _estilo(false, 8))
	# Abre à esquerda do botão, alinhado pelo topo
	painel.anchor_left = 1.0
	painel.anchor_right = 1.0
	painel.offset_right = -40
	painel.offset_left = -40 - 190
	painel.offset_top = 166
	painel.offset_bottom = 166
	painel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	painel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(painel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	painel.add_child(vbox)

	var titulo := _label("Volume", 11)
	vbox.add_child(titulo)

	for linha in LINHAS:
		var bus: String = linha[0]
		var nome := _label(linha[1], 9)
		nome.tooltip_text = linha[2]
		nome.mouse_filter = Control.MOUSE_FILTER_PASS
		vbox.add_child(nome)

		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 6)
		vbox.add_child(hbox)

		var mudo := Button.new()
		mudo.custom_minimum_size = Vector2(18, 18)
		mudo.focus_mode = Control.FOCUS_NONE
		mudo.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		mudo.tooltip_text = "Ligar/desligar: " + String(linha[1])
		for estado in ["normal", "hover", "pressed", "focus"]:
			mudo.add_theme_stylebox_override(estado, StyleBoxEmpty.new())
		mudo.pressed.connect(_on_mudo.bind(bus))
		var ic := IconeSom.new()
		ic.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		mudo.add_child(ic)
		mudo.mouse_entered.connect(func(): ic.cor = COR_DESTAQUE)
		mudo.mouse_exited.connect(func(): ic.cor = COR_TEXTO)
		hbox.add_child(mudo)
		_icones[bus] = ic

		var slider := HSlider.new()
		slider.min_value = 0
		slider.max_value = 100
		slider.step = 5
		slider.custom_minimum_size = Vector2(110, 18)
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		slider.focus_mode = Control.FOCUS_NONE # setas do teclado continuam andando com o personagem
		slider.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		slider.tooltip_text = linha[2]
		_estilizar_slider(slider)
		slider.value_changed.connect(func(v: float): _on_slider(bus, v))
		hbox.add_child(slider)
		_sliders[bus] = slider

		var pct := _label("100%", 9)
		pct.custom_minimum_size = Vector2(30, 0)
		pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		hbox.add_child(pct)
		_porcentos[bus] = pct

# Botão de mudo da linha. Se o volume estava no zero, "desmutar" volta para 50%.
func _on_mudo(bus: String) -> void:
	if Audio.get_volume(bus) <= 0.0:
		Audio.set_volume(bus, 0.5)
	else:
		Audio.set_mudo(bus, not Audio.esta_mudo(bus))

func _on_slider(bus: String, valor: float) -> void:
	if _atualizando:
		return
	Audio.set_volume(bus, valor / 100.0)

func _atualizar() -> void:
	_atualizando = true
	for linha in LINHAS:
		var bus: String = linha[0]
		var v: float = Audio.get_volume(bus)
		var mudo: bool = Audio.esta_mudo(bus)
		_sliders[bus].value = round(v * 100.0)
		_sliders[bus].modulate.a = 0.45 if mudo else 1.0
		_porcentos[bus].text = "mudo" if mudo else "%d%%" % int(round(v * 100.0))
		_icones[bus].mudo = mudo
		_icones[bus].nivel = v
	_atualizando = false
	icone_botao.mudo = Audio.esta_mudo("Master")
	icone_botao.nivel = Audio.get_volume("Master")

func alternar() -> void:
	if aberto:
		fechar()
	else:
		abrir()

func abrir() -> void:
	aberto = true
	painel.visible = true

func fechar() -> void:
	aberto = false
	painel.visible = false

func _input(event: InputEvent) -> void:
	# Clique fora do painel (e fora do botão) fecha
	if not aberto:
		return
	if event is InputEventMouseButton and event.pressed:
		var pos: Vector2 = (event as InputEventMouseButton).position
		if not painel.get_global_rect().has_point(pos) and not botao.get_global_rect().has_point(pos):
			fechar()

func _process(_delta: float) -> void:
	_posicionar()
	# Some durante a troca de sala (tela preta), mas na historinha fica junto do botão de
	# pular, que continua aparecendo nas telas pretas com texto
	botao.visible = _com_pular or not Transition.is_transitioning
	if not botao.visible and aberto:
		fechar()

# O botão fica SEMPRE no canto superior direito:
#   - na escola: no canto (o painel com o nome do diretor no HUD abre espaço para ele);
#   - na historinha: logo à esquerda do botão de pular (que fica em x -32..-6, y 6..22).
# O painel de volume abre logo abaixo do botão, alinhado pela direita.
func _posicionar() -> void:
	var cena: Node = get_tree().current_scene
	if cena != _cena_posicao:
		_cena_posicao = cena
		_botao_pular = cena.find_child("BotaoPular", true, false) as Control if cena else null
	var com_pular: bool = is_instance_valid(_botao_pular) and _botao_pular.is_visible_in_tree()
	_com_pular = com_pular
	var topo: float = 6.0 if com_pular else 10.0
	var lado: float = 16.0 if com_pular else 22.0
	var direita: float = -38.0 if com_pular else -12.0
	if botao.offset_top == topo and botao.offset_right == direita:
		return
	botao.offset_top = topo
	botao.offset_bottom = topo + lado
	botao.offset_right = direita
	botao.offset_left = direita - lado - (2.0 if com_pular else 0.0)
	var margem: float = 2.0 if com_pular else 3.0
	icone_botao.offset_left = margem
	icone_botao.offset_top = margem
	icone_botao.offset_right = -margem
	icone_botao.offset_bottom = -margem
	painel.offset_right = direita
	painel.offset_left = direita - 190.0
	painel.offset_top = topo + lado + 4.0
	painel.offset_bottom = painel.offset_top

# ---------------- visual ----------------

func _estilo(destaque: bool, margem: int = 0) -> StyleBoxFlat:
	var e := StyleBoxFlat.new()
	e.bg_color = COR_FUNDO if not destaque else Color(0.22, 0.3, 0.19, 0.95)
	e.border_color = COR_BORDA
	e.set_border_width_all(1)
	e.set_corner_radius_all(6)
	e.content_margin_left = margem
	e.content_margin_right = margem
	e.content_margin_top = margem
	e.content_margin_bottom = margem
	return e

func _label(texto: String, tamanho: int) -> Label:
	var l := Label.new()
	l.text = texto
	l.add_theme_font_override("font", FONTE)
	l.add_theme_font_size_override("font_size", tamanho)
	l.add_theme_color_override("font_color", COR_TEXTO)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _estilizar_slider(slider: HSlider) -> void:
	var trilho := StyleBoxFlat.new()
	trilho.bg_color = Color(0.29, 0.4, 0.25)
	trilho.set_corner_radius_all(3)
	trilho.content_margin_top = 3
	trilho.content_margin_bottom = 3
	var cheio := StyleBoxFlat.new()
	cheio.bg_color = COR_BORDA
	cheio.set_corner_radius_all(3)
	cheio.content_margin_top = 3
	cheio.content_margin_bottom = 3
	slider.add_theme_stylebox_override("slider", trilho)
	slider.add_theme_stylebox_override("grabber_area", cheio)
	slider.add_theme_stylebox_override("grabber_area_highlight", cheio)
	slider.add_theme_icon_override("grabber", _bolinha(COR_TEXTO))
	slider.add_theme_icon_override("grabber_highlight", _bolinha(COR_DESTAQUE))

func _bolinha(cor: Color) -> ImageTexture:
	var img := Image.create(10, 10, false, Image.FORMAT_RGBA8)
	for y in 10:
		for x in 10:
			var d: float = Vector2(x + 0.5, y + 0.5).distance_to(Vector2(5, 5))
			if d <= 4.5:
				img.set_pixel(x, y, cor if d <= 3.5 else Color(0.18, 0.25, 0.16))
	return ImageTexture.create_from_image(img)
