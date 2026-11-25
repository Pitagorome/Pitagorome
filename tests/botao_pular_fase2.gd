extends CanvasLayer

# =====================================================================
# TEMP-PULAR-FASE2  [TEMPORÁRIO - SÓ PARA TESTE] Botão "Pular para a Fase 2"
# ---------------------------------------------------------------------
# Botões no canto superior direito que pulam direto para o começo da Fase 2
# (Tarefa 6) ou da Fase 3 (Tarefa 11), no gabinete. Cada um some quando o jogo já
# passou daquela fase.
#
# Nas builds exportadas pelo preset FINAL estes botões não aparecem (Versao.eh_teste()).
# Para tirar de vez do projeto (procure por "TEMP-PULAR-FASE2" no projeto):
#   1. Apague a linha "BotaoPularFase2=..." em project.godot
#      (ou desmarque em Projeto > Configurações > Globais/Autoload)
#   2. Apague este arquivo (tests/botao_pular_fase2.gd e o .uid)
# Nenhum outro arquivo depende dele.
# =====================================================================

# ícone desenhado (o caractere ⏭ não existe na fonte e vira quadradinho na versão web)
const ICONE: Texture2D = preload("res://assets/ui/icone_pular.png")

var botao: Button
var botao3: Button

func _ready() -> void:
	# Só existe nas builds de TESTE (e rodando pelo editor). Na build FINAL some
	# sozinho, então não tem como entregar com estes botões. Ver scripts/versao.gd.
	if not Versao.eh_teste():
		set_process(false)
		queue_free()
		return
	layer = 9 # por cima do HUD (5), mas embaixo do diálogo (10) e dos desafios (12)
	botao3 = _criar_botao("Pular p/ Fase 3 (TESTE)", 196)
	botao3.pressed.connect(_pular.bind(3))
	botao = Button.new()
	botao.text = "Pular p/ Fase 2 (TESTE)"
	botao.icon = ICONE
	botao.focus_mode = Control.FOCUS_NONE # não "rouba" o Espaço/Enter dos diálogos
	# Canto superior direito, embaixo do minimapa (não cobre a caixa de diálogo)
	botao.anchor_left = 1.0
	botao.anchor_right = 1.0
	botao.offset_left = -170
	botao.offset_top = 172
	botao.offset_right = -12
	botao.offset_bottom = 192
	botao.add_theme_font_size_override("font_size", 10)
	botao.modulate = Color(1, 0.8, 0.8, 0.85)
	botao.tooltip_text = "Botão temporário de teste: vai direto para a Fase 2."
	botao.pressed.connect(_pular.bind(2))
	add_child(botao)

func _criar_botao(texto: String, topo: int) -> Button:
	var b := Button.new()
	b.text = texto
	b.icon = ICONE
	b.focus_mode = Control.FOCUS_NONE
	b.anchor_left = 1.0
	b.anchor_right = 1.0
	b.offset_left = -170
	b.offset_top = topo
	b.offset_right = -12
	b.offset_bottom = topo + 20
	b.add_theme_font_size_override("font_size", 10)
	b.modulate = Color(1, 0.8, 0.8, 0.85)
	b.tooltip_text = "Botão temporário de teste: vai direto para a Fase 3."
	add_child(b)
	return b

func _process(_delta: float) -> void:
	# no menu inicial não aparecem (só depois de clicar em Jogar)
	var no_menu: bool = get_tree().current_scene != null and get_tree().current_scene.name == "MenuInicial"
	botao.visible = GameManager.current_phase < 2 and not Transition.is_transitioning and not no_menu
	botao3.visible = GameManager.current_phase < 3 and not Transition.is_transitioning and not no_menu
	# quando só sobra o da Fase 3, ele sobe para o lugar do outro
	botao3.offset_top = 196 if botao.visible else 172
	botao3.offset_bottom = botao3.offset_top + 20

func _pular(fase: int = 2) -> void:
	if Transition.is_transitioning:
		return
	print("[TESTE] Pulando para a Fase %d pelo botão temporário" % fase)
	# Fecha diálogo aberto sem rodar o que viria depois dele
	DialogueManager.current_on_complete = Callable()
	if DialogueManager.is_active:
		DialogueManager.end_dialogue()
	DialogueManager.modal_open = false
	# Mantém o nome/visual se o jogador já tiver criado o personagem
	var nome: String = GameManager.player_name
	var genero: String = GameManager.player_gender
	var visual: int = GameManager.player_appearance
	var tinha_nome: bool = GameManager.player_named
	GameManager.jump_to_phase(fase)
	if tinha_nome:
		GameManager.set_player_info(nome, genero, visual)
	if fase == 3:
		Fase3Flow.start_phase(false)
	else:
		Fase2Flow.start_phase(false)
