extends CanvasLayer

# Interface da Caixa de Diálogo (UI)
# Estilo aconchegante com a paleta oficial: #F2E8D0 (fundo), #4A6741 (bordas), #FDA123 (nome), #545454 (texto)

@onready var panel: PanelContainer = $Control/DialoguePanel
@onready var speaker_label: Label = $Control/DialoguePanel/MarginContainer/VBoxContainer/SpeakerLabel
@onready var text_label: Label = $Control/DialoguePanel/MarginContainer/VBoxContainer/TextLabel
@onready var prompt_label: Label = $Control/DialoguePanel/MarginContainer/VBoxContainer/PromptLabel

@onready var name_input_modal: PanelContainer = $Control/NameInputModal
@onready var name_line_edit: LineEdit = $Control/NameInputModal/MarginContainer/VBoxContainer/LineEdit
@onready var confirm_btn: Button = $Control/NameInputModal/MarginContainer/VBoxContainer/ConfirmButton
@onready var male_btn: Button = $Control/NameInputModal/MarginContainer/VBoxContainer/GenderRow/MaleButton
@onready var female_btn: Button = $Control/NameInputModal/MarginContainer/VBoxContainer/GenderRow/FemaleButton
@onready var appearance_label: Label = $Control/NameInputModal/MarginContainer/VBoxContainer/AppearanceRow/AppearanceLabel
@onready var prev_btn: Button = $Control/NameInputModal/MarginContainer/VBoxContainer/AppearanceRow/PrevButton
@onready var next_btn: Button = $Control/NameInputModal/MarginContainer/VBoxContainer/AppearanceRow/NextButton

var waiting_for_name: bool = false

func _ready() -> void:
	DialogueManager.register_dialogue_box(self)
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_line_changed.connect(_on_dialogue_line_changed)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.dialogue_event_triggered.connect(_on_dialogue_event_triggered)
	
	if confirm_btn:
		confirm_btn.pressed.connect(_on_confirm_name_pressed)
	if name_line_edit:
		name_line_edit.text_submitted.connect(_on_name_submitted)
	# Gênero e aparência são aplicados na hora, para o jogador ver o sprite mudando
	male_btn.pressed.connect(func(): GameManager.set_player_info("", "M"))
	female_btn.pressed.connect(func(): GameManager.set_player_info("", "F"))
	prev_btn.pressed.connect(func(): _cycle_appearance(-1))
	next_btn.pressed.connect(func(): _cycle_appearance(1))
	
	panel.visible = false
	name_input_modal.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not DialogueManager.is_active or waiting_for_name:
		return
	
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("abrir_licoes") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		get_viewport().set_input_as_handled()
		DialogueManager.advance()

func _on_dialogue_started() -> void:
	panel.visible = true
	name_input_modal.visible = false

func _on_dialogue_line_changed(speaker: String, text: String) -> void:
	speaker_label.text = speaker
	text_label.text = text
	panel.visible = true

func _on_dialogue_ended() -> void:
	panel.visible = false
	name_input_modal.visible = false

func _on_dialogue_event_triggered(event_name: String) -> void:
	if event_name == "ask_name":
		waiting_for_name = true
		name_input_modal.visible = true
		name_line_edit.text = GameManager.player_name
		male_btn.button_pressed = GameManager.player_gender != "F"
		female_btn.button_pressed = GameManager.player_gender == "F"
		_update_appearance_label()
		name_line_edit.grab_focus()
		name_line_edit.select_all()

func _cycle_appearance(step: int) -> void:
	var total: int = GameManager.APPEARANCES.size()
	GameManager.set_player_info("", "", (GameManager.player_appearance + step + total) % total)
	_update_appearance_label()

func _update_appearance_label() -> void:
	appearance_label.text = "Visual %d" % (GameManager.player_appearance + 1)

func _on_confirm_name_pressed() -> void:
	_save_name_and_continue()

func _on_name_submitted(_new_text: String) -> void:
	_save_name_and_continue()

func _save_name_and_continue() -> void:
	var typed_name: String = name_line_edit.text.strip_edges()
	if typed_name.is_empty():
		typed_name = GameManager.get_director_title()
	GameManager.set_player_info(typed_name, "F" if female_btn.button_pressed else "M")
	waiting_for_name = false
	name_input_modal.visible = false
	DialogueManager.advance()
