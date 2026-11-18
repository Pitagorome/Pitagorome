extends Node

# Atalho para testar a Fase 3 sem jogar as Fases 1 e 2.
# No Godot: abra tests/comecar_fase3.tscn e aperte F6 (Executar cena atual).
# O jogo começa no gabinete, no primeiro dia do 3º trimestre, na Tarefa 11 (com o nome "Diretor").

func _ready() -> void:
	GameManager.jump_to_phase(3)
	get_tree().current_scene = null
	Fase3Flow.start_phase.call_deferred(false)
	queue_free()
