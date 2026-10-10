extends Node2D

# Indicador "!" que aparece em cima de objetos/NPCs quando eles fazem parte da tarefa atual.

@export var show_in_tasks: Array[int] = []
# Se preenchido, o "!" some depois que esse evento acontecer (GameManager.seen_events)
@export var hide_after_event: String = ""

@onready var label: Label = $Label

func _ready() -> void:
	var tween: Tween = create_tween().set_loops()
	tween.tween_property(label, "position:y", label.position.y - 3.0, 0.45).set_trans(Tween.TRANS_SINE)
	tween.tween_property(label, "position:y", label.position.y, 0.45).set_trans(Tween.TRANS_SINE)
	_refresh()

func _process(_delta: float) -> void:
	_refresh()

func _refresh() -> void:
	var active: bool = show_in_tasks.has(GameManager.current_task_id)
	if hide_after_event != "" and GameManager.seen_events.has(hide_after_event):
		active = false
	visible = active
