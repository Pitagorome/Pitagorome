extends CanvasLayer

# HUD: prancheta da tarefa (canto superior esquerdo) + nome do(a) diretor(a) + minimapa.
#
# Apontamento do grupo (18/11): a caixa verde grande com a tarefa ficava sempre aberta e
# atrapalhava a visão. Agora no canto fica só uma PRANCHETA pequena ("Tarefa N").
# Clicando nela (ou apertando Tab) abre/fecha o painel com a tarefa, o objetivo e o bilhete.
# Quando o objetivo muda, aparece um "!" na prancheta e o painel abre sozinho por alguns
# segundos (para o jogador não perder a novidade) e depois fecha.

const ESPIADA_SEGUNDOS: float = 4.0

@onready var botao_prancheta: Button = $Control/MarginContainer/HBoxContainer/BotaoPrancheta
@onready var aviso_label: Label = $Control/MarginContainer/HBoxContainer/BotaoPrancheta/Aviso
@onready var task_panel: PanelContainer = $Control/MarginContainer/HBoxContainer/PanelTask
@onready var task_label: Label = $Control/MarginContainer/HBoxContainer/PanelTask/Margin/VBox/LabelTask
@onready var objective_label: Label = $Control/MarginContainer/HBoxContainer/PanelTask/Margin/VBox/LabelObjective
@onready var director_panel: PanelContainer = $Control/MarginContainer/HBoxContainer/PanelDirector
@onready var director_label: Label = $Control/MarginContainer/HBoxContainer/PanelDirector/Margin/LabelDirector

# Lembrete fixo (GameManager.current_note), criado aqui copiando o estilo da linha do objetivo
var note_label: Label = null

var aberta: bool = false        # o jogador abriu a prancheta
var espiando: bool = false      # aberta sozinha por alguns segundos (objetivo novo)
var _espiada_id: int = 0
var _ultimo_objetivo: String = ""

func _ready() -> void:
	GameManager.task_updated.connect(_on_task_updated)
	GameManager.objective_updated.connect(_on_objective_updated)
	GameManager.player_info_updated.connect(_on_player_info_updated)
	note_label = objective_label.duplicate() as Label
	note_label.name = "LabelNote"
	note_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	objective_label.get_parent().add_child(note_label)
	GameManager.note_updated.connect(func(_t): _update_display())
	botao_prancheta.pressed.connect(alternar_prancheta)
	_ultimo_objetivo = GameManager.current_objective
	_update_display()
	_atualizar_painel()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_TAB:
		get_viewport().set_input_as_handled()
		alternar_prancheta()

func alternar_prancheta() -> void:
	aberta = not (aberta or espiando)
	espiando = false
	aviso_label.visible = false
	_atualizar_painel()

# Abre sozinha por alguns segundos (objetivo novo) e fecha, a não ser que o jogador abra de vez
func espiar() -> void:
	if aberta:
		return
	espiando = true
	_espiada_id += 1
	var id: int = _espiada_id
	_atualizar_painel()
	await get_tree().create_timer(ESPIADA_SEGUNDOS).timeout
	if id == _espiada_id and espiando:
		espiando = false
		_atualizar_painel()

func painel_visivel() -> bool:
	return task_panel.visible

func _atualizar_painel() -> void:
	# Abrindo sozinha não fica por cima de um desafio (só se o jogador abrir de propósito)
	var espiada_ok: bool = espiando and not DialogueManager.modal_open
	task_panel.visible = (aberta or espiada_ok) and GameManager.current_task_id >= 0

func _process(_delta: float) -> void:
	if espiando:
		_atualizar_painel()

func _update_display() -> void:
	if task_label:
		if GameManager.current_task_id > 0:
			task_label.text = "Fase %d · Tarefa %d: %s" % [GameManager.current_phase, GameManager.current_task_id, GameManager.current_task_name]
		else:
			task_label.text = GameManager.current_task_name
	if objective_label:
		objective_label.text = "▶ " + DialogueManager.format_text(GameManager.current_objective)
		objective_label.visible = GameManager.current_objective != ""
	if note_label:
		note_label.text = "• " + GameManager.current_note
		note_label.visible = GameManager.current_note != ""
	if botao_prancheta:
		var titulo: String = "Tarefa %d" % GameManager.current_task_id if GameManager.current_task_id > 0 else "Tarefas"
		if GameManager.current_note != "":
			titulo += "  •"
		botao_prancheta.text = titulo
	if director_label:
		director_label.text = GameManager.get_director_title() + ": " + GameManager.player_name
		# Só mostra depois que o nome foi confirmado (antes aparecia "Diretora: Diretor")
		director_panel.visible = GameManager.player_named

func _on_task_updated(_id: int, _name: String) -> void:
	_update_display()

func _on_objective_updated(_text: String) -> void:
	_update_display()
	if GameManager.current_objective != _ultimo_objetivo and GameManager.current_objective != "":
		_ultimo_objetivo = GameManager.current_objective
		if not aberta:
			aviso_label.visible = true
			espiar()

func _on_player_info_updated(_name: String, _gender: String) -> void:
	_update_display()
