extends CanvasLayer

# Interface Modal de Desafios Matemáticos e Lógicos (UML: Resposta)
# Apresenta enunciados contextualizados, valida respostas e dá feedback educativo imediato.

signal challenge_completed(task_id: int)

@onready var modal_panel: PanelContainer = $Control/ModalPanel
@onready var title_label: Label = $Control/ModalPanel/MarginContainer/VBoxContainer/TitleLabel
@onready var context_label: Label = $Control/ModalPanel/MarginContainer/VBoxContainer/ContextLabel
@onready var question_label: Label = $Control/ModalPanel/MarginContainer/VBoxContainer/QuestionLabel

# Opções de múltipla escolha
@onready var options_container: VBoxContainer = $Control/ModalPanel/MarginContainer/VBoxContainer/OptionsContainer
@onready var option_btn_1: Button = $Control/ModalPanel/MarginContainer/VBoxContainer/OptionsContainer/Option1
@onready var option_btn_2: Button = $Control/ModalPanel/MarginContainer/VBoxContainer/OptionsContainer/Option2
@onready var option_btn_3: Button = $Control/ModalPanel/MarginContainer/VBoxContainer/OptionsContainer/Option3

# Input de código/senha (ex: Cofre)
@onready var code_container: HBoxContainer = $Control/ModalPanel/MarginContainer/VBoxContainer/CodeContainer
@onready var code_input: LineEdit = $Control/ModalPanel/MarginContainer/VBoxContainer/CodeContainer/CodeInput
@onready var code_submit_btn: Button = $Control/ModalPanel/MarginContainer/VBoxContainer/CodeContainer/SubmitCodeButton

# Feedback
@onready var feedback_panel: PanelContainer = $Control/FeedbackPanel
@onready var feedback_title: Label = $Control/FeedbackPanel/MarginContainer/VBoxContainer/FeedbackTitle
@onready var feedback_text: Label = $Control/FeedbackPanel/MarginContainer/VBoxContainer/FeedbackText
@onready var feedback_close_btn: Button = $Control/FeedbackPanel/MarginContainer/VBoxContainer/CloseButton

var current_task_id: int = 0
var current_correct_index: int = 0
var current_correct_code: String = ""
var current_feedback_success: String = ""
var current_feedback_error: String = ""
var current_on_success: Callable = Callable()
var last_answer_correct: bool = false

func _ready() -> void:
	modal_panel.visible = false
	feedback_panel.visible = false
	
	option_btn_1.pressed.connect(func(): _on_option_selected(0))
	option_btn_2.pressed.connect(func(): _on_option_selected(1))
	option_btn_3.pressed.connect(func(): _on_option_selected(2))
	
	code_submit_btn.pressed.connect(_on_code_submitted)
	if code_input:
		code_input.text_submitted.connect(func(_t): _on_code_submitted())
	
	feedback_close_btn.pressed.connect(_on_feedback_closed)

func show_multiple_choice_challenge(task_id: int, title: String, context: String, question: String, options: Array[String], correct_index: int, success_feedback: String, error_feedback: String = "", on_success: Callable = Callable()) -> void:
	current_task_id = task_id
	current_correct_index = correct_index
	current_feedback_success = success_feedback
	current_feedback_error = error_feedback if error_feedback != "" else "Essa resposta não atende a todas as condições do problema. Analise de novo e tente outra vez!"
	current_on_success = on_success
	current_correct_code = ""
	
	title_label.text = title
	context_label.text = context
	question_label.text = question
	
	option_btn_1.text = options[0] if options.size() > 0 else ""
	option_btn_2.text = options[1] if options.size() > 1 else ""
	option_btn_3.text = options[2] if options.size() > 2 else ""
	
	options_container.visible = true
	code_container.visible = false
	
	modal_panel.visible = true
	feedback_panel.visible = false
	DialogueManager.modal_open = true

func show_code_challenge(task_id: int, title: String, context: String, question: String, correct_code: String, success_feedback: String, error_feedback: String = "", on_success: Callable = Callable()) -> void:
	current_task_id = task_id
	current_correct_code = correct_code.replace(" ", "").strip_edges()
	current_feedback_success = success_feedback
	current_feedback_error = error_feedback if error_feedback != "" else "Código incorreto! Releia as pistas e tente novamente."
	current_on_success = on_success
	
	title_label.text = title
	context_label.text = context
	question_label.text = question
	
	options_container.visible = false
	code_container.visible = true
	code_input.text = ""
	
	modal_panel.visible = true
	feedback_panel.visible = false
	DialogueManager.modal_open = true
	code_input.grab_focus()

func _on_option_selected(index: int) -> void:
	if index == current_correct_index:
		_show_success_feedback()
	else:
		_show_error_feedback(current_feedback_error)

func _on_code_submitted() -> void:
	var typed = code_input.text.replace(" ", "").strip_edges()
	if typed == current_correct_code:
		_show_success_feedback()
	else:
		_show_error_feedback(current_feedback_error)

func _show_success_feedback() -> void:
	last_answer_correct = true
	modal_panel.visible = false
	feedback_title.text = "Desafio concluído com sucesso!"
	feedback_title.add_theme_color_override("font_color", Color(0.2, 0.6, 0.2))
	feedback_text.text = current_feedback_success
	feedback_panel.visible = true
	
	GameManager.complete_task(current_task_id)
	challenge_completed.emit(current_task_id)

func _show_error_feedback(msg: String) -> void:
	last_answer_correct = false
	modal_panel.visible = false
	feedback_title.text = "Tente novamente"
	feedback_title.add_theme_color_override("font_color", Color(0.8, 0.3, 0.1))
	feedback_text.text = msg
	feedback_panel.visible = true

func _on_feedback_closed() -> void:
	feedback_panel.visible = false
	if last_answer_correct:
		DialogueManager.modal_open = false
		last_answer_correct = false
		var callback: Callable = current_on_success
		current_on_success = Callable()
		if callback.is_valid():
			callback.call()
	else:
		# Errou: volta para a mesma pergunta para tentar de novo
		modal_panel.visible = true
		if code_container.visible:
			code_input.text = ""
			code_input.grab_focus()

# Fecha o desafio sem responder (botão Fechar / tecla Esc)
func cancel() -> void:
	modal_panel.visible = false
	feedback_panel.visible = false
	DialogueManager.modal_open = false

func _unhandled_input(event: InputEvent) -> void:
	if modal_panel.visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		cancel()
