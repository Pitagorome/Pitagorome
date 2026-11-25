extends Node2D

# Menu inicial (cena principal: scenes/ui/menu_inicial.tscn), pedido de 24/11.
#   Jogar  -> historinha do começo (scenes/intro/historia_inicio.tscn)
#   Volume -> abre/fecha as barrinhas de Geral, Música e Interações (as mesmas do botão do canto,
#             montadas por ControleVolume.criar_linhas, então tudo fica sincronizado)
#   Sair   -> fecha o jogo (só no executável; no navegador não aparece)
# Fundo: o portão da escola de verdade, carregado sem o script da sala (igual à historinha),
# escurecido. Toca a música da escola.
# Bônus na versão web: o clique em "Jogar" já libera o som do navegador antes da historinha.

const CENA_HISTORIA: String = "res://scenes/intro/historia_inicio.tscn"
const CENA_FUNDO: String = "res://scenes/school/portao_scene.tscn"
const FONTE_BOLD: FontFile = preload("res://assets/fonts/Montserrat-Bold.ttf")
const FONTE_REG: FontFile = preload("res://assets/fonts/Montserrat-Regular.ttf")
const COR_CREME := Color(0.98, 0.96, 0.88)
const COR_AMARELO := Color(0.99, 0.75, 0.35)
const COR_VERDE := Color(0.18, 0.25, 0.16, 0.92)
const COR_VERDE_HOVER := Color(0.26, 0.35, 0.22, 0.95)
const COR_BORDA := Color(0.95, 0.91, 0.82, 0.9)
# Nós das salas que não entram no fundo (mesma ideia da historinha)
const NOS_REMOVIDOS: Array[String] = ["HUD", "DialogueBox", "ChallengeModal", "Excursao", "Vans"]

@onready var palco: Node2D = $Palco
@onready var camera: Camera2D = $Camera2D

var botao_jogar: Button
var botao_volume: Button
var botao_sair: Button
var caixa_volume: VBoxContainer
var saindo: bool = false

func _ready() -> void:
	_montar_fundo()
	camera.position = Vector2(0, -10)
	camera.make_current()
	_montar_interface()
	botao_jogar.grab_focus.call_deferred() # Enter/Espaço já começa o jogo

func _montar_fundo() -> void:
	var sala: Node2D = (load(CENA_FUNDO) as PackedScene).instantiate() as Node2D
	sala.set_script(null) # sem school_room.gd: não dispara falas nem tarefas
	var remover: Array[Node] = []
	for nome in NOS_REMOVIDOS:
		var n: Node = sala.get_node_or_null(nome)
		if n:
			remover.append(n)
	for n in sala.find_children("*", "", true, false):
		if n is CharacterBody2D or n.name in ["ExclamationMarker", "DoorLabel"] or n.name.begins_with("Marca"):
			remover.append(n)
	for n in remover:
		if is_instance_valid(n) and n.get_parent():
			n.get_parent().remove_child(n)
			n.queue_free()
	for area in sala.find_children("*", "Area2D", true, false):
		(area as Area2D).monitoring = false
	palco.add_child(sala)

func _montar_interface() -> void:
	var ui := CanvasLayer.new()
	ui.name = "UI"
	ui.layer = 5
	add_child(ui)

	var escuro := ColorRect.new()
	escuro.color = Color(0.04, 0.07, 0.05, 0.55)
	escuro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	escuro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(escuro)

	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(centro)

	var quadro := PanelContainer.new()
	quadro.name = "Quadro"
	quadro.add_theme_stylebox_override("panel", _estilo(COR_VERDE, 16))
	quadro.custom_minimum_size = Vector2(240, 0)
	centro.add_child(quadro)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	quadro.add_child(vbox)

	var titulo := _label("Pitagorome", FONTE_BOLD, 28, COR_AMARELO)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	titulo.add_theme_constant_override("shadow_offset_x", 2)
	titulo.add_theme_constant_override("shadow_offset_y", 2)
	vbox.add_child(titulo)

	var sub := _label("Você é o novo diretor da Escola Pitagórica", FONTE_REG, 9, COR_CREME)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sub)

	var espaco := Control.new()
	espaco.custom_minimum_size = Vector2(0, 4)
	vbox.add_child(espaco)

	botao_jogar = _botao("Jogar", 14)
	botao_jogar.pressed.connect(jogar)
	vbox.add_child(botao_jogar)

	botao_volume = _botao("Volume", 11)
	botao_volume.pressed.connect(alternar_volume)
	vbox.add_child(botao_volume)

	caixa_volume = VBoxContainer.new()
	caixa_volume.name = "CaixaVolume"
	caixa_volume.add_theme_constant_override("separation", 4)
	caixa_volume.visible = false
	vbox.add_child(caixa_volume)
	ControleVolume.criar_linhas(caixa_volume, 9, 120.0)

	botao_sair = _botao("Sair", 11)
	botao_sair.pressed.connect(func(): get_tree().quit())
	botao_sair.visible = not OS.has_feature("web") # no navegador é só fechar a aba
	vbox.add_child(botao_sair)

	var dica := _label("WASD ou setas para andar  ·  E para interagir  ·  Tab abre a tarefa", FONTE_REG, 8, Color(COR_CREME, 0.85))
	dica.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dica.anchor_left = 0.0
	dica.anchor_right = 1.0
	dica.anchor_top = 1.0
	dica.anchor_bottom = 1.0
	dica.offset_top = -22
	dica.offset_bottom = -8
	ui.add_child(dica)

func jogar() -> void:
	if saindo or Transition.is_transitioning:
		return
	saindo = true
	GameManager.reset_progress()
	Transition.change_scene(CENA_HISTORIA)

func alternar_volume() -> void:
	caixa_volume.visible = not caixa_volume.visible
	botao_volume.text = "Fechar volume" if caixa_volume.visible else "Volume"

# ---------------- visual ----------------

func _estilo(cor: Color, margem: int) -> StyleBoxFlat:
	var e := StyleBoxFlat.new()
	e.bg_color = cor
	e.border_color = COR_BORDA
	e.set_border_width_all(1)
	e.set_corner_radius_all(8)
	e.content_margin_left = margem
	e.content_margin_right = margem
	e.content_margin_top = margem * 0.75
	e.content_margin_bottom = margem * 0.75
	return e

func _label(texto: String, fonte: FontFile, tamanho: int, cor: Color) -> Label:
	var l := Label.new()
	l.text = texto
	l.add_theme_font_override("font", fonte)
	l.add_theme_font_size_override("font_size", tamanho)
	l.add_theme_color_override("font_color", cor)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _botao(texto: String, tamanho: int) -> Button:
	var b := Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(0, 26 if tamanho >= 14 else 22)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_font_override("font", FONTE_BOLD)
	b.add_theme_font_size_override("font_size", tamanho)
	b.add_theme_color_override("font_color", COR_CREME)
	b.add_theme_color_override("font_hover_color", COR_AMARELO)
	b.add_theme_color_override("font_focus_color", COR_AMARELO)
	b.add_theme_color_override("font_pressed_color", COR_AMARELO)
	var normal := _estilo(Color(0.12, 0.17, 0.11, 0.9), 6)
	var hover := _estilo(COR_VERDE_HOVER, 6)
	hover.border_color = COR_AMARELO
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	b.add_theme_stylebox_override("focus", hover)
	return b
