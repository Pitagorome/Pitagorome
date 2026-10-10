class_name PuzzleModal
extends CanvasLayer

# Base dos puzzles de "organizar coisas" (Task 2 — grade, Task 5 — vans).
# A cena precisa ter os nós com nome único: %TitleLabel, %RulesLabel,
# %FeedbackLabel, %CheckButton e %CloseButton.
# Cada puzzle implementa _build(), _read_answer() e _validate().

signal solved()
signal closed(was_solved: bool)

const COLOR_OK: Color = Color(0.2, 0.5, 0.2)
const COLOR_ERROR: Color = Color(0.75, 0.25, 0.1)

@onready var title_label: Label = %TitleLabel
@onready var rules_label: Label = %RulesLabel
@onready var feedback_label: Label = %FeedbackLabel
@onready var check_button: Button = %CheckButton
@onready var close_button: Button = %CloseButton

var is_solved: bool = false
var attempts: int = 0

func _ready() -> void:
	DialogueManager.modal_open = true
	check_button.pressed.connect(_on_check_pressed)
	close_button.pressed.connect(close)
	feedback_label.text = ""
	_build()
	_refresh()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not is_solved:
		get_viewport().set_input_as_handled()
		close()

# Usado pelo botão "Verificar" e também pelos testes automatizados.
func check_answer() -> Array[String]:
	attempts += 1
	var errors: Array[String] = _validate()
	if errors.is_empty():
		is_solved = true
		_set_feedback(_success_text(), COLOR_OK)
		check_button.text = "Continuar"
		close_button.visible = false
		_set_inputs_enabled(false)
	else:
		# Mostra no máximo 3 problemas para o painel não estourar a tela
		var shown: Array[String] = errors.slice(0, 3)
		var text: String = "Ainda tem problema:\n• " + "\n• ".join(shown)
		if errors.size() > shown.size():
			text += "\n(+%d outro(s))" % (errors.size() - shown.size())
		_set_feedback(text, COLOR_ERROR)
	return errors

func close() -> void:
	DialogueManager.modal_open = false
	closed.emit(is_solved)
	if is_solved:
		solved.emit()
	queue_free()

func _on_check_pressed() -> void:
	if is_solved:
		close()
	else:
		check_answer()

func _set_feedback(text: String, color: Color) -> void:
	feedback_label.text = text
	feedback_label.add_theme_color_override("font_color", color)

# ---- Para as classes filhas ----

func _build() -> void:
	pass

func _refresh() -> void:
	pass

func _validate() -> Array[String]:
	return []

func _success_text() -> String:
	return "Tudo certo!"

func _set_inputs_enabled(_enabled: bool) -> void:
	pass
