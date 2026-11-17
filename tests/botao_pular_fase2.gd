extends CanvasLayer

# =====================================================================
# TEMP-PULAR-FASE2  [TEMPORÁRIO - SÓ PARA TESTE] Botão "Pular para a Fase 2"
# ---------------------------------------------------------------------
# Botão no canto superior direito que pula direto para o começo da Fase 2
# (Tarefa 6, no gabinete). Aparece só enquanto o jogo está na Fase 1.
#
# PARA TIRAR antes da entrega (procure por "TEMP-PULAR-FASE2" no projeto):
#   1. Apague a linha "BotaoPularFase2=..." em project.godot
#      (ou desmarque em Projeto > Configurações > Globais/Autoload)
#   2. Apague este arquivo (tests/botao_pular_fase2.gd e o .uid)
# Nenhum outro arquivo depende dele.
# =====================================================================

var botao: Button

func _ready() -> void:
	layer = 120 # por cima do HUD, dos desafios e da transição
	botao = Button.new()
	botao.text = "⏭ Pular p/ Fase 2 (TESTE)"
	botao.focus_mode = Control.FOCUS_NONE # não "rouba" o Espaço/Enter dos diálogos
	# Canto superior direito, embaixo do nome do(a) diretor(a) (não cobre a caixa de diálogo)
	botao.anchor_left = 1.0
	botao.anchor_right = 1.0
	botao.offset_left = -300
	botao.offset_top = 84
	botao.offset_right = -24
	botao.offset_bottom = 120
	botao.add_theme_font_size_override("font_size", 18)
	botao.modulate = Color(1, 0.8, 0.8, 0.85)
	botao.tooltip_text = "Botão temporário de teste: vai direto para a Fase 2."
	botao.pressed.connect(_pular)
	add_child(botao)

func _process(_delta: float) -> void:
	botao.visible = GameManager.current_phase < 2 and not Transition.is_transitioning

func _pular() -> void:
	if Transition.is_transitioning:
		return
	print("[TESTE] Pulando para a Fase 2 pelo botão temporário")
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
	GameManager.jump_to_phase(2)
	if tinha_nome:
		GameManager.set_player_info(nome, genero, visual)
	Fase2Flow.start_phase(false)
