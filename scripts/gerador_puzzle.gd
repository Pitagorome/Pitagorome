extends PuzzleModal

# Task 8 — O Gerador de Emergência
# 5 alavancas com valores escritos em potência/raiz (√36, √25, 3², 2², √49).
# O jogador liga as alavancas até a carga (que começa em 8) chegar EXATAMENTE a 30.
#
# Mudança de 18/11 (apontamento do grupo: ligando tudo na tentativa e erro saía rápido):
#   - no máximo 3 alavancas ligadas ao mesmo tempo (Fase2Puzzles.GERADOR_MAX_ALAVANCAS);
#   - a carga NÃO aparece enquanto puxa: só depois de "Verificar" (tem que fazer a conta);
#   - a cada 3 erros o gerador trava alguns segundos para esfriar e as alavancas desligam.

@onready var lever_box: HBoxContainer = %LeverBox
@onready var charge_label: Label = %ChargeLabel
@onready var charge_bar: ProgressBar = %ChargeBar

var levers: Array[Button] = []
var erros_seguidos: int = 0
var travado_ate: float = 0.0 # Time em segundos; 0 = não está travado
var ultima_carga: int = -1   # carga medida no último "Verificar" (-1 = ainda não mediu)

func _build() -> void:
	title_label.text = "Tarefa 8: O Gerador de Emergência"
	rules_label.text = "Para reiniciar, atinja exatamente %d unidades de carga. Carga atual: %d. Cada alavanca ligada soma o valor escrito nela.\nNo máximo %d alavancas ligadas. A carga só é medida ao Verificar e, depois de %d erros, o gerador trava para esfriar." % [Fase2Puzzles.GERADOR_ALVO, Fase2Puzzles.GERADOR_INICIAL, Fase2Puzzles.GERADOR_MAX_ALAVANCAS, Fase2Puzzles.GERADOR_TENTATIVAS]
	charge_bar.max_value = Fase2Puzzles.GERADOR_ALVO + 10
	for i in Fase2Puzzles.ALAVANCAS.size():
		var a: Dictionary = Fase2Puzzles.ALAVANCAS[i]
		var lever: Button = Button.new()
		lever.toggle_mode = true
		lever.text = a["rotulo"]
		lever.custom_minimum_size = Vector2(52, 44)
		lever.add_theme_font_size_override("font_size", 14)
		lever.toggled.connect(_on_lever_toggled.bind(i))
		lever_box.add_child(lever)
		levers.append(lever)

func _on_lever_toggled(ligada: bool, i: int) -> void:
	if ligada and ligadas_count() > Fase2Puzzles.GERADOR_MAX_ALAVANCAS:
		levers[i].set_pressed_no_signal(false)
		_set_feedback("O painel só aguenta %d alavancas ligadas. Desligue uma antes de puxar outra." % Fase2Puzzles.GERADOR_MAX_ALAVANCAS, COLOR_ERROR)
	ultima_carga = -1 # mudou as alavancas: a medição antiga não vale mais
	_refresh()

func ligadas_count() -> int:
	return get_levers().count(true)

func get_levers() -> Array:
	return levers.map(func(l): return l.button_pressed)

# Usado pelos testes para simular o jogador puxando as alavancas
func set_levers(ligadas: Array) -> void:
	for i in levers.size():
		levers[i].set_pressed_no_signal(i < ligadas.size() and ligadas[i])
	ultima_carga = -1
	_refresh()

func esta_travado() -> bool:
	return travado_ate > 0.0 and Time.get_ticks_msec() / 1000.0 < travado_ate

func _process(_delta: float) -> void:
	if travado_ate <= 0.0:
		return
	if esta_travado():
		check_button.text = "Esfriando... %ds" % ceili(travado_ate - Time.get_ticks_msec() / 1000.0)
	else:
		destravar()

# Fim da espera (também usado pelos testes para não esperar os segundos de verdade)
func destravar() -> void:
	travado_ate = 0.0
	erros_seguidos = 0
	check_button.text = "Verificar"
	check_button.disabled = false
	_set_inputs_enabled(true)
	_set_feedback("O gerador esfriou. Pode tentar de novo.", Color(0.25, 0.25, 0.25))

func _refresh() -> void:
	var ligadas: Array = get_levers()
	var nomes: PackedStringArray = []
	for i in levers.size():
		if ligadas[i]:
			nomes.append(Fase2Puzzles.ALAVANCAS[i]["rotulo"])
	var texto: String = "Alavancas ligadas (%d/%d): %s" % [nomes.size(), Fase2Puzzles.GERADOR_MAX_ALAVANCAS, " + ".join(nomes) if not nomes.is_empty() else "nenhuma"]
	if ultima_carga >= 0:
		texto += "\nCarga medida: %d   (meta: %d)" % [ultima_carga, Fase2Puzzles.GERADOR_ALVO]
	else:
		texto += "\nCarga: ?   (aperte Verificar para medir — meta: %d)" % Fase2Puzzles.GERADOR_ALVO
	charge_label.text = texto
	charge_bar.value = ultima_carga if ultima_carga >= 0 else 0
	var cor: Color = Color(0.25, 0.25, 0.25)
	if ultima_carga >= 0:
		cor = COLOR_OK if ultima_carga == Fase2Puzzles.GERADOR_ALVO else COLOR_ERROR
	charge_label.add_theme_color_override("font_color", cor)
	for i in levers.size():
		levers[i].text = Fase2Puzzles.ALAVANCAS[i]["rotulo"] + ("\nON" if levers[i].button_pressed else "\noff")
		# Alavanca ligada fica verde, para dar para ver de longe quais estão puxadas
		levers[i].modulate = Color(0.6, 1.0, 0.6) if levers[i].button_pressed else Color(1, 1, 1)

func _validate() -> Array[String]:
	var ligadas: Array = get_levers()
	var errors: Array[String] = Fase2Puzzles.validate_gerador(ligadas)
	if ligadas.count(true) <= Fase2Puzzles.GERADOR_MAX_ALAVANCAS:
		ultima_carga = Fase2Puzzles.gerador_carga(ligadas)
	if errors.is_empty():
		_refresh()
		return errors
	erros_seguidos += 1
	if Fase2Puzzles.gerador_carga(ligadas) > Fase2Puzzles.GERADOR_ALVO:
		set_levers([]) # passou de 30: o gerador reinicia
	if erros_seguidos >= Fase2Puzzles.GERADOR_TENTATIVAS:
		errors.append("%d erros seguidos: o gerador travou para esfriar! As alavancas desligaram. Aproveite para fazer as contas." % erros_seguidos)
		set_levers([])
		travado_ate = Time.get_ticks_msec() / 1000.0 + Fase2Puzzles.GERADOR_ESPERA
		_set_inputs_enabled(false)
		check_button.disabled = true
	else:
		errors.append("Tentativas antes de travar: %d." % (Fase2Puzzles.GERADOR_TENTATIVAS - erros_seguidos))
	_refresh()
	return errors

func check_answer() -> Array[String]:
	if esta_travado():
		return ["O gerador ainda está esfriando."]
	return super.check_answer()

func _success_text() -> String:
	return "Gerador religado! %s. Lembre: √36 = 6, √25 = 5, 3² = 9, 2² = 4, √49 = 7." % Fase2Puzzles.gerador_descricao(get_levers())

func _set_inputs_enabled(enabled: bool) -> void:
	for l in levers:
		l.disabled = not enabled
