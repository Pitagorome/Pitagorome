extends Node2D

# Script da raiz de cada sala da escola.
# Avisa ao Fase1Flow em qual lugar o jogador entrou, para disparar os eventos da história
# (na Fase 2 o Fase1Flow repassa para o Fase2Flow).
# Também escurece a sala quando a escola está sem luz (Task 8 — O Gerador de Emergência)
# ou quando só esta sala está apagada (Task 13 — As Luzes do Corredor).

const COR_NORMAL: Color = Color(1, 1, 1)
const COR_SEM_LUZ: Color = Color(0.32, 0.34, 0.5)

@export var location_id: String = ""

var escuridao: CanvasModulate = null

func _ready() -> void:
	escuridao = CanvasModulate.new()
	escuridao.name = "Escuridao"
	add_child(escuridao)
	_on_lights_changed(GameManager.lights_out)
	GameManager.lights_changed.connect(_on_lights_changed)
	Fase1Flow.on_room_ready.call_deferred(location_id)

func _on_lights_changed(_lights_out: bool) -> void:
	escuridao.color = COR_SEM_LUZ if GameManager.is_room_dark(location_id) else COR_NORMAL
