extends Node

# Autoload: DialogueManager
# Responsável por gerenciar caixas de diálogo, fluxo de texto e eventos narrativos.

signal dialogue_started()
signal dialogue_line_changed(speaker: String, text: String)
signal dialogue_ended()
signal dialogue_event_triggered(event_name: String)

var is_active: bool = false
# true enquanto um desafio/puzzle está aberto na tela (trava o jogador sem ser diálogo)
var modal_open: bool = false
var dialogue_queue: Array = []
var current_line_index: int = 0
var current_on_complete: Callable = Callable()

var dialogue_box_instance: Node = null

var _gender_regex: RegEx = RegEx.create_from_string("\\{([^{}|]*)\\|([^{}|]*)\\}")

func _ready() -> void:
	print("[DialogueManager] Inicializado.")

func register_dialogue_box(box: Node) -> void:
	dialogue_box_instance = box

# O jogador não deve andar nem interagir enquanto isso for true.
func is_busy() -> bool:
	return is_active or modal_open or Transition.is_transitioning

func start_dialogue(lines: Array, on_complete: Callable = Callable()) -> void:
	if lines.is_empty():
		if on_complete.is_valid():
			on_complete.call()
		return

	dialogue_queue = lines.duplicate(true)
	current_line_index = 0
	current_on_complete = on_complete
	is_active = true
	dialogue_started.emit()

	_show_current_line()

# Troca os marcadores pelo nome/gênero do jogador.
func format_text(raw_text: String) -> String:
	var text: String = raw_text.replace("{player_name}", GameManager.player_name)
	text = text.replace("{player_title}", GameManager.get_director_formal_title())
	text = text.replace("{diretor}", GameManager.get_director_title())
	var pick: int = 2 if GameManager.player_gender == "F" else 1
	for m in _gender_regex.search_all(text):
		text = text.replace(m.get_string(0), m.get_string(pick))
	return text

func _show_current_line() -> void:
	if current_line_index >= dialogue_queue.size():
		end_dialogue()
		return

	var line_data: Dictionary = dialogue_queue[current_line_index]
	var speaker: String = format_text(line_data.get("speaker", ""))
	var text: String = format_text(line_data.get("text", ""))

	dialogue_line_changed.emit(speaker, text)

	if line_data.has("event"):
		dialogue_event_triggered.emit(line_data["event"])

func advance() -> void:
	if not is_active:
		return

	current_line_index += 1
	_show_current_line()

func end_dialogue() -> void:
	is_active = false
	dialogue_queue.clear()
	current_line_index = 0
	dialogue_ended.emit()

	# Limpa antes de chamar: o callback pode iniciar outro diálogo com o próprio callback.
	var callback: Callable = current_on_complete
	current_on_complete = Callable()
	if callback.is_valid():
		callback.call()
