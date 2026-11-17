extends PuzzleModal

# Task 8 — O Gerador de Emergência
# 5 alavancas com valores escritos em potência/raiz (√36, √25, 3², 2², √49).
# O jogador liga as alavancas até a carga (que começa em 8) chegar EXATAMENTE a 30.
# Se passar de 30 e apertar Verificar, o gerador "reinicia": todas as alavancas voltam a desligar.

@onready var lever_box: HBoxContainer = %LeverBox
@onready var charge_label: Label = %ChargeLabel
@onready var charge_bar: ProgressBar = %ChargeBar

var levers: Array[Button] = []

func _build() -> void:
	title_label.text = "Tarefa 8: O Gerador de Emergência"
	rules_label.text = "Para reiniciar, atinja exatamente %d unidades de carga. Carga atual: %d. Cada alavanca ligada soma o valor escrito nela." % [Fase2Puzzles.GERADOR_ALVO, Fase2Puzzles.GERADOR_INICIAL]
	charge_bar.max_value = Fase2Puzzles.GERADOR_ALVO + 10
	for a in Fase2Puzzles.ALAVANCAS:
		var lever: Button = Button.new()
		lever.toggle_mode = true
		lever.text = a["rotulo"]
		lever.custom_minimum_size = Vector2(52, 44)
		lever.add_theme_font_size_override("font_size", 14)
		lever.toggled.connect(func(_on): _refresh())
		lever_box.add_child(lever)
		levers.append(lever)

func get_levers() -> Array:
	return levers.map(func(l): return l.button_pressed)

# Usado pelos testes para simular o jogador puxando as alavancas
func set_levers(ligadas: Array) -> void:
	for i in levers.size():
		levers[i].set_pressed_no_signal(i < ligadas.size() and ligadas[i])
	_refresh()

func _refresh() -> void:
	var carga: int = Fase2Puzzles.gerador_carga(get_levers())
	charge_label.text = "Carga: %s   (meta: %d)" % [Fase2Puzzles.gerador_descricao(get_levers()), Fase2Puzzles.GERADOR_ALVO]
	charge_bar.value = carga
	var cor: Color = COLOR_OK if carga == Fase2Puzzles.GERADOR_ALVO else (COLOR_ERROR if carga > Fase2Puzzles.GERADOR_ALVO else Color(0.25, 0.25, 0.25))
	charge_label.add_theme_color_override("font_color", cor)
	for i in levers.size():
		levers[i].text = Fase2Puzzles.ALAVANCAS[i]["rotulo"] + ("\nON" if levers[i].button_pressed else "\noff")
		# Alavanca ligada fica verde, para dar para ver de longe quais estão puxadas
		levers[i].modulate = Color(0.6, 1.0, 0.6) if levers[i].button_pressed else Color(1, 1, 1)

func _validate() -> Array[String]:
	var errors: Array[String] = Fase2Puzzles.validate_gerador(get_levers())
	if Fase2Puzzles.gerador_carga(get_levers()) > Fase2Puzzles.GERADOR_ALVO:
		set_levers([]) # passou de 30: o gerador reinicia
	return errors

func _success_text() -> String:
	return "Gerador religado! %s. Lembre: √36 = 6, √25 = 5, 3² = 9, 2² = 4, √49 = 7." % Fase2Puzzles.gerador_descricao(get_levers())

func _set_inputs_enabled(enabled: bool) -> void:
	for l in levers:
		l.disabled = not enabled
