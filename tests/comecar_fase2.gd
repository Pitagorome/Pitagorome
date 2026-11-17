extends Node

# Atalho para testar a Fase 2 sem jogar a Fase 1 inteira.
# No Godot: abra tests/comecar_fase2.tscn e aperte F6 (Executar cena atual).
# O jogo começa no gabinete, no dia seguinte, na Tarefa 6 (com o nome "Diretor").

func _ready() -> void:
	GameManager.jump_to_phase(2)
	get_tree().current_scene = null
	Fase2Flow.start_phase.call_deferred()
	queue_free()
