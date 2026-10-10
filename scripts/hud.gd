extends CanvasLayer

# HUD: tarefa atual + objetivo (o que fazer agora) + nome do(a) diretor(a)

@onready var task_label: Label = $Control/MarginContainer/HBoxContainer/PanelTask/Margin/VBox/LabelTask
@onready var objective_label: Label = $Control/MarginContainer/HBoxContainer/PanelTask/Margin/VBox/LabelObjective
@onready var director_label: Label = $Control/MarginContainer/HBoxContainer/PanelDirector/Margin/LabelDirector

func _ready() -> void:
	GameManager.task_updated.connect(_on_task_updated)
	GameManager.objective_updated.connect(_on_objective_updated)
	GameManager.player_info_updated.connect(_on_player_info_updated)
	_update_display()

func _update_display() -> void:
	if task_label:
		if GameManager.current_task_id > 0:
			task_label.text = "Fase %d · Tarefa %d: %s" % [GameManager.current_phase, GameManager.current_task_id, GameManager.current_task_name]
		else:
			task_label.text = GameManager.current_task_name
	if objective_label:
		objective_label.text = "► " + DialogueManager.format_text(GameManager.current_objective)
		objective_label.visible = GameManager.current_objective != ""
	if director_label:
		director_label.text = GameManager.get_director_title() + ": " + GameManager.player_name

func _on_task_updated(_id: int, _name: String) -> void:
	_update_display()

func _on_objective_updated(_text: String) -> void:
	_update_display()

func _on_player_info_updated(_name: String, _gender: String) -> void:
	_update_display()
