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
#   Escolher tarefa (canto de baixo, "godmode" para a apresentação) -> lista das 15 tarefas;
#               clicar numa começa direto nela, como se as anteriores já tivessem sido feitas
#               (GameManager.jump_to_task). Existe também na versão final.
# Enter/Espaço apertam Jogar; Esc fecha a janelinha aberta.

const CENA_HISTORIA: String = "res://scenes/intro/historia_inicio.tscn"
const CENA_GABINETE: String = "res://scenes/intro/intro_scene.tscn"
const CENA_GERADOR: String = "res://scenes/school/sala_gerador_scene.tscn"
const FUNDO: Texture2D = preload("res://assets/ui/menu_fundo.jpg")
const LOGO: Texture2D = preload("res://assets/ui/logo.png")
const FRAMES_DIRETOR: SpriteFrames = preload("res://assets/character_frames/adam_frames.tres")
# Visual (fonte pixelada, cores e botões do site): scripts/estilo_menu.gd
const LARGURA_BOTAO: int = EstiloMenu.LARGURA_BOTAO
const COR_AMARELO := EstiloMenu.COR_AMARELO
const COR_CREME := EstiloMenu.COR_CREME
const COR_LARANJA := EstiloMenu.COR_LARANJA

var FONTE_BOLD: FontVariation
var FONTE_REG: FontVariation

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
var janela_tarefas: PanelContainer
var botao_tarefas: Button
var botoes_tarefa: Dictionary = {} # id da tarefa -> Button
var veu: ColorRect # escurece o menu atrás da janelinha aberta; clicar nele fecha
var diretor: AnimatedSprite2D
var saindo: bool = false

func _ready() -> void:
	FONTE_BOLD = EstiloMenu.fonte_bold()
	FONTE_REG = EstiloMenu.fonte_reg()
	_montar_interface()
	botao_jogar.grab_focus.call_deferred() # Enter/Espaço já começa o jogo

func _process(delta: float) -> void:
	# o diretor atravessa a calçada e volta a entrar pela esquerda
	if diretor:
		diretor.position.x += 38.0 * delta
		if diretor.position.x > 680.0:
			diretor.position.x = -40.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and (janela_volume.visible or janela_creditos.visible or janela_tarefas.visible):
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

	# Godmode da apresentação: botão discreto no canto + janela com as tarefas por fase
	botao_tarefas = _botao("Escolher tarefa", 10, 20)
	botao_tarefas.name = "BotaoEscolherTarefa"
	botao_tarefas.tooltip_text = "Modo apresentação: comece direto em qualquer tarefa"
	botao_tarefas.anchor_left = 1.0
	botao_tarefas.anchor_right = 1.0
	botao_tarefas.anchor_top = 1.0
	botao_tarefas.anchor_bottom = 1.0
	botao_tarefas.offset_left = -112
	botao_tarefas.offset_right = -12
	botao_tarefas.offset_top = -32
	botao_tarefas.offset_bottom = -12
	botao_tarefas.focus_mode = Control.FOCUS_NONE
	botao_tarefas.pressed.connect(alternar_tarefas)
	ui.add_child(botao_tarefas)

	janela_tarefas = _janela("Escolher tarefa", 560, -150)
	var conteudo: VBoxContainer = janela_tarefas.get_meta("conteudo")
	conteudo.add_child(_label("Modo apresentação: começa direto na tarefa, como se as anteriores já estivessem feitas.", FONTE_REG, 9, COR_CREME))
	var colunas := HBoxContainer.new()
	colunas.add_theme_constant_override("separation", 8)
	conteudo.add_child(colunas)
	for fase in [1, 2, 3]:
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 4)
		col.custom_minimum_size.x = 172
		colunas.add_child(col)
		col.add_child(_label("Fase %d" % fase, FONTE_BOLD, 11, COR_LARANJA))
		var tarefas: Array = GameManager.TASK_PHASE.keys().filter(func(t): return GameManager.TASK_PHASE[t] == fase)
		tarefas.sort()
		for t in tarefas:
			var b := _botao("%d. %s" % [t, GameManager.TASK_NAMES[t]], 9, 20)
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			b.focus_mode = Control.FOCUS_NONE
			for estado in ["normal", "hover", "focus", "pressed"]:
				var e: StyleBoxFlat = b.get_theme_stylebox(estado).duplicate()
				e.content_margin_left = 6
				b.add_theme_stylebox_override(estado, e)
			b.pressed.connect(ir_para_tarefa.bind(t))
			col.add_child(b)
			botoes_tarefa[t] = b
	ui.add_child(janela_tarefas)
	_fechar_janelas()

func jogar() -> void:
	if saindo or Transition.is_transitioning:
		return
	saindo = true
	GameManager.reset_progress()
	Transition.change_scene(CENA_HISTORIA)

# Godmode: começa direto na tarefa escolhida
func ir_para_tarefa(tarefa: int) -> void:
	if saindo or Transition.is_transitioning:
		return
	saindo = true
	GameManager.jump_to_task(tarefa)
	if tarefa <= 1:
		Transition.change_scene(CENA_GABINETE, "SpawnFromCorridor") # igual ao fim da historinha
		return
	var fase: int = GameManager.TASK_PHASE[tarefa]
	var cena: String = CENA_GERADOR if tarefa == 8 else CENA_GABINETE
	var spawn: String = "SpawnFromAla" if tarefa == 8 else "SpawnDesk"
	Transition.change_scene_with_cards(cena, spawn, [
		["Fase %d" % fase, GameManager.PHASE_NAMES[fase], 2.0],
		["Tarefa %d" % tarefa, GameManager.TASK_NAMES[tarefa], 1.8],
	])

func alternar_tarefas() -> void:
	var abrir: bool = not janela_tarefas.visible
	_fechar_janelas()
	janela_tarefas.visible = abrir
	veu.visible = abrir

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
	if janela_tarefas:
		janela_tarefas.visible = false
	veu.visible = false
	if is_inside_tree() and botao_jogar.is_inside_tree():
		botao_jogar.grab_focus.call_deferred()

# ---------------- visual ----------------

# Janelinha centralizada embaixo dos botões, com título e "Fechar"
func _janela(titulo: String, largura: int = 250, topo: int = -95) -> PanelContainer:
	var j := PanelContainer.new()
	j.name = "Janela" + titulo.replace("é", "e").replace(" ", "")
	j.add_theme_stylebox_override("panel", _estilo_hud(12, true))
	j.anchor_left = 0.5
	j.anchor_right = 0.5
	j.anchor_top = 0.5
	j.anchor_bottom = 0.5
	j.offset_left = -largura / 2.0
	j.offset_right = largura / 2.0
	j.offset_top = topo
	j.offset_bottom = topo
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
	return EstiloMenu.estilo_hud(margem, opaco)

func _label(texto: String, fonte: Font, tamanho: int, cor: Color) -> Label:
	return EstiloMenu.label(texto, fonte, tamanho, cor)

func _botao(texto: String, tamanho: int = EstiloMenu.TAMANHO_FONTE_BOTAO, altura: int = EstiloMenu.ALTURA_BOTAO) -> Button:
	return EstiloMenu.botao(texto, tamanho, altura)
