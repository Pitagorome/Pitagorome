extends "res://scripts/interactable_object.gd"

# Armário numerado da Sala dos Armários (Task 6 — O Troféu Desaparecido).
# Na cena é só trocar o "numero" no Inspetor: a plaquinha muda sozinha.
# Ao abrir, quem decide o que tem dentro é o Fase2Flow (flow_event = "armario_numerado").

@export var numero: int = 1

func _ready() -> void:
	flow_event = "armario_numerado"
	flow_value = str(numero)
	hint_text = "[E] Abrir armário %d" % numero
	object_name = "Armário %d" % numero
	var placa: Label = get_node_or_null("Numero") as Label
	if placa:
		placa.text = str(numero)
	super._ready()
