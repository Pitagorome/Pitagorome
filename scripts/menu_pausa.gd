extends CanvasLayer

# Autoload: MenuPausa. Pedido de 25/11: "tem que ter um menu pra conseguir voltar pra tela
# inicial ou resumir (despausar)".
#   - Abre com Esc ou com o botão de pausa (ícone ||) no canto de cima, à esquerda do volume.
#   - Pausa o jogo inteiro (get_tree().paused); este nó, o ControleVolume e o Audio continuam rodando.
#   - Continuar (ou Esc de novo) volta ao jogo.
#   - Volume: as mesmas barrinhas do botão do canto (ControleVolume.criar_linhas).
#   - Menu inicial: pede confirmação (o progresso da partida se perde) e volta para a tela inicial.
# Só funciona dentro da escola (cenas com location_id). No menu inicial, na historinha e durante
# troca de cena não aparece. Com um desafio aberto o Esc fecha o desafio (ele trata o Esc antes),
# mas o botão de pausa continua funcionando.
# Visual igual ao do menu inicial: scripts/estilo_menu.gd.

const CENA_MENU: String = "res://scenes/ui/menu_inicial.tscn"
const TAMANHO_BOTAO := Vector2(26, 16) # igual ao botão de volume e ao de pular
const DIREITA_BOTAO: float = -42.0     # o de volume fica em -38..-12
const TOPO_BOTAO: float = 10.0

var botao: Button
var veu: ColorRect
var janela: PanelContainer
var caixa_principal: VBoxContainer
var caixa_confirmar: VBoxContainer
var caixa_volume: VBoxContainer
var botao_continuar: Button
var botao_volume: Button
var botao_menu: Button
var botao_sim: Button
var botao_nao: Button
var aberto: bool = false

func _ready() -> void:
	layer = 62 # acima do HUD, do diálogo e do painel de volume (61)
	process_mode = Node.PROCESS_MODE_ALWAYS
	_montar()
	_fechar_visual()

func _process(_delta: float) -> void:
	botao.visible = pode_pausar() or aberto

# Dentro da escola e sem troca de cena acontecendo
func pode_pausar() -> bool:
	var cena: Node = get_tree().current_scene
	return cena != null and cena.get("location_id") != null and str(cena.get("location_id")) != "" \
		and not Transition.is_transitioning

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if aberto:
		get_viewport().set_input_as_handled()
		if caixa_confirmar.visible or caixa_volume.visible:
			_mostrar_principal()
		else:
			continuar()
	elif pode_pausar() and not DialogueManager.modal_open:
		get_viewport().set_input_as_handled()
		abrir()

func abrir() -> void:
	if aberto or not pode_pausar():
		return
	aberto = true
	get_tree().paused = true
	ControleVolume.fechar()
	veu.visible = true
	janela.visible = true
	_mostrar_principal()

func continuar() -> void:
	if not aberto:
		return
	_fechar_visual()
	get_tree().paused = false

# Volta para a tela inicial (o menu de lá começa um jogo novo)
func voltar_ao_menu() -> void:
	_fechar_visual()
	get_tree().paused = false
	# fecha diálogo/desafio sem rodar o que viria depois deles
	DialogueManager.current_on_complete = Callable()
	if DialogueManager.is_active:
		DialogueManager.end_dialogue()
	DialogueManager.modal_open = false
	GameManager.reset_progress()
	Transition.change_scene(CENA_MENU)

func _fechar_visual() -> void:
	aberto = false
	veu.visible = false
	janela.visible = false

func _mostrar_principal() -> void:
	caixa_principal.visible = true
	caixa_volume.visible = false
	caixa_confirmar.visible = false
	botao_continuar.grab_focus.call_deferred()

func _alternar_volume() -> void:
	caixa_volume.visible = not caixa_volume.visible

func _pedir_confirmacao() -> void:
	caixa_principal.visible = false
	caixa_volume.visible = false
	caixa_confirmar.visible = true
	botao_nao.grab_focus.call_deferred()

# ---------------- montagem ----------------

func _montar() -> void:
	# Botão de pausa no canto, do mesmo jeito do botão de volume
	botao = Button.new()
	botao.name = "BotaoPausa"
	botao.tooltip_text = "Pausar (Esc)"
	botao.focus_mode = Control.FOCUS_NONE
	botao.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	botao.anchor_left = 1.0
	botao.anchor_right = 1.0
	botao.offset_right = DIREITA_BOTAO
	botao.offset_left = DIREITA_BOTAO - TAMANHO_BOTAO.x
	botao.offset_top = TOPO_BOTAO
	botao.offset_bottom = TOPO_BOTAO + TAMANHO_BOTAO.y
	var normal: StyleBoxFlat = ControleVolume._estilo_pular()
	var hover: StyleBoxFlat = normal.duplicate()
	hover.border_color = ControleVolume.COR_PULAR_HOVER
	botao.add_theme_stylebox_override("normal", normal)
	botao.add_theme_stylebox_override("hover", hover)
	botao.add_theme_stylebox_override("pressed", hover)
	botao.add_theme_stylebox_override("focus", normal)
	botao.pressed.connect(func():
		if aberto:
			continuar()
		else:
			abrir())
	var icone := IconePausa.new()
	icone.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icone.offset_left = 6
	icone.offset_right = -6
	icone.offset_top = 3
	icone.offset_bottom = -3
	botao.add_child(icone)
	botao.mouse_entered.connect(func(): icone.cor = ControleVolume.COR_PULAR_HOVER)
	botao.mouse_exited.connect(func(): icone.cor = ControleVolume.COR_PULAR_ICONE)
	add_child(botao)

	veu = ColorRect.new()
	veu.name = "Veu"
	veu.color = Color(0, 0, 0, 0.55)
	veu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veu.mouse_filter = Control.MOUSE_FILTER_STOP # o clique não passa para o jogo
	add_child(veu)

	janela = PanelContainer.new()
	janela.name = "JanelaPausa"
	janela.add_theme_stylebox_override("panel", EstiloMenu.estilo_hud(14, true))
	janela.anchor_left = 0.5
	janela.anchor_right = 0.5
	janela.anchor_top = 0.5
	janela.anchor_bottom = 0.5
	janela.offset_left = -115
	janela.offset_right = 115
	janela.offset_top = -100
	janela.offset_bottom = -100
	janela.grow_horizontal = Control.GROW_DIRECTION_BOTH
	add_child(janela)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	janela.add_child(vbox)
	var titulo := EstiloMenu.label("Jogo pausado", EstiloMenu.fonte_bold(), 16, EstiloMenu.COR_AMARELO)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(titulo)

	caixa_principal = VBoxContainer.new()
	caixa_principal.add_theme_constant_override("separation", 8)
	vbox.add_child(caixa_principal)
	botao_continuar = EstiloMenu.botao("Continuar")
	botao_continuar.pressed.connect(continuar)
	caixa_principal.add_child(botao_continuar)
	botao_volume = EstiloMenu.botao("Volume")
	botao_volume.pressed.connect(_alternar_volume)
	caixa_principal.add_child(botao_volume)
	caixa_volume = VBoxContainer.new()
	caixa_volume.add_theme_constant_override("separation", 3)
	ControleVolume.criar_linhas(caixa_volume, 10, 120.0)
	for l in caixa_volume.find_children("*", "Label", true, false):
		(l as Label).add_theme_font_override("font", EstiloMenu.fonte_reg())
	caixa_principal.add_child(caixa_volume)
	botao_menu = EstiloMenu.botao("Menu inicial")
	botao_menu.pressed.connect(_pedir_confirmacao)
	caixa_principal.add_child(botao_menu)
	var dica := EstiloMenu.label("Esc também continua o jogo", EstiloMenu.fonte_reg(), 9, Color(EstiloMenu.COR_CREME, 0.7))
	dica.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caixa_principal.add_child(dica)

	caixa_confirmar = VBoxContainer.new()
	caixa_confirmar.add_theme_constant_override("separation", 8)
	vbox.add_child(caixa_confirmar)
	var aviso := EstiloMenu.label("Voltar ao menu inicial?\nO progresso desta partida será perdido.", EstiloMenu.fonte_reg(), 10, EstiloMenu.COR_CREME)
	aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caixa_confirmar.add_child(aviso)
	botao_sim = EstiloMenu.botao("Sim, voltar")
	botao_sim.pressed.connect(voltar_ao_menu)
	caixa_confirmar.add_child(botao_sim)
	botao_nao = EstiloMenu.botao("Cancelar")
	botao_nao.pressed.connect(_mostrar_principal)
	caixa_confirmar.add_child(botao_nao)
