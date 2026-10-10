extends Node2D

# Script da raiz de cada sala da escola.
# Avisa ao Fase1Flow em qual lugar o jogador entrou, para disparar os eventos da história.

@export var location_id: String = ""

func _ready() -> void:
	Fase1Flow.on_room_ready.call_deferred(location_id)
