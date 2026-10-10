class_name InteractableObject
extends StaticBody2D

# Objeto Interativo no Cenário (UML: Objeto)
# Exibe indicador [E] e aciona diálogos, exames de pistas ou desafios matemáticos.

@export var object_name: String = "Objeto"
@export var hint_text: String = "[E] Examinar"
@export_multiline var examine_text: String = ""
# Se preenchido, quem decide o que acontece é o Fase1Flow (ex: "cofre", "calendario")
@export var flow_event: String = ""

# Se estiver vinculado a um desafio
@export var is_challenge_trigger: bool = false
@export var challenge_task_id: int = 0
@export var challenge_type: String = "choice" # "choice" ou "code"
@export var challenge_title: String = ""
@export_multiline var challenge_context: String = ""
@export_multiline var challenge_question: String = ""
@export var challenge_options: Array[String] = []
@export var challenge_correct_index: int = 0
@export var challenge_correct_code: String = ""
@export_multiline var challenge_success_feedback: String = ""

@onready var interaction_area: Area2D = $InteractionArea
@onready var hint_label: Label = $HintLabel

var player_in_range: bool = false
var challenge_modal_ref: Node = null

func _ready() -> void:
	if hint_label:
		hint_label.text = hint_text
		hint_label.visible = false
	
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if not player_in_range or DialogueManager.is_busy():
		return
	
	if event.is_action_pressed("abrir_licoes") or event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and (event.keycode == KEY_E or event.physical_keycode == KEY_E or event.keycode == KEY_SPACE or event.keycode == KEY_ENTER)):
		get_viewport().set_input_as_handled()
		interact()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player" or body.name == "director":
		player_in_range = true
		if hint_label:
			hint_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player" or body.name == "director":
		player_in_range = false
		if hint_label:
			hint_label.visible = false

func interact() -> void:
	if hint_label:
		hint_label.visible = false
	
	if flow_event != "":
		Fase1Flow.on_object_event(flow_event, self)
	# Desafio só abre se for a tarefa atual; fora dela o objeto só é examinado
	elif is_challenge_trigger and GameManager.current_task_id == challenge_task_id:
		_trigger_challenge()
	elif examine_text != "":
		DialogueManager.start_dialogue([
			{
				"speaker": object_name,
				"text": examine_text
			}
		])
	else:
		print("[InteractableObject] Interagiu com: ", object_name)

func _trigger_challenge() -> void:
	var modal = get_tree().root.find_child("ChallengeModal", true, false)
	if not modal:
		# Procura na cena atual
		modal = get_parent().find_child("ChallengeModal", true, false)
	
	if modal:
		if challenge_type == "choice":
			modal.show_multiple_choice_challenge(
				challenge_task_id,
				challenge_title,
				challenge_context,
				challenge_question,
				challenge_options,
				challenge_correct_index,
				challenge_success_feedback
			)
		elif challenge_type == "code":
			modal.show_code_challenge(
				challenge_task_id,
				challenge_title,
				challenge_context,
				challenge_question,
				challenge_correct_code,
				challenge_success_feedback
			)
	else:
		DialogueManager.start_dialogue([
			{
				"speaker": object_name,
				"text": examine_text if examine_text != "" else challenge_context
			}
		])
