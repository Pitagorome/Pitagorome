extends "res://scripts/npc.gd"

# NPC Zelador
# Apresentado no tour (Task 1) e dono das pistas do cadeado (Task 3).

func _ready() -> void:
	super._ready()
	npc_name = "Zelador"

func interact() -> void:
	super.interact()
	Fase1Flow.on_zelador_interact()
