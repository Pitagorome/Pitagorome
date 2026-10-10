extends "res://scripts/npc.gd"

# NPC Professor de Matemática
# Apresentado no tour (Task 1) e presente na confusão do corredor (Task 4).

func _ready() -> void:
	super._ready()
	npc_name = "Professor de Matemática"

func interact() -> void:
	super.interact()
	Fase1Flow.on_professor_interact()
