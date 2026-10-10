extends Area2D

# Transição segura de salas com proteção contra reentrada acidental
@export_file("*.tscn") var target_scene: String = "res://scenes/school/school_corridor.tscn"
@export var target_spawn_id: String = "from_door"

var can_teleport: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Pequeno cooldown de 0.5s ao entrar na cena para evitar reentrada instantânea
	get_tree().create_timer(0.5).timeout.connect(func(): can_teleport = true)

func _on_body_entered(body: Node2D) -> void:
	if not can_teleport or Transition.is_transitioning:
		return
	if body.is_in_group("player") or body.name == "Player" or body.name == "director":
		if target_scene != "":
			can_teleport = false
			GameManager.change_scene(target_scene, target_spawn_id)
