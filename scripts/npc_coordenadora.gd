extends "res://scripts/npc.gd"

# NPC Coordenadora
# Guia o jogador: o que ela fala depende da tarefa atual e da sala (ver Fase1Flow).

func _ready() -> void:
	super._ready()
	npc_name = "Coordenadora"

func interact() -> void:
	super.interact()
	Fase1Flow.on_coordenadora_interact()
