extends PuzzleModal

# Task 5 — O Ônibus da Excursão
# O jogador escolhe a van de cada participante; o resumo mostra a lotação de cada van.

@onready var people_grid: GridContainer = %PeopleGrid
@onready var summary_label: Label = %SummaryLabel

var selectors: Dictionary = {} # id do participante -> OptionButton

func _build() -> void:
	title_label.text = "Tarefa 5: O Ônibus da Excursão"
	rules_label.text = "Regras:  " + "  •  ".join(Fase1Puzzles.VAN_RULES)

	for p in Fase1Puzzles.VAN_PARTICIPANTS:
		var label: Label = Label.new()
		label.text = p["nome"]
		label.custom_minimum_size = Vector2(96, 0)
		people_grid.add_child(label)

		var selector: OptionButton = OptionButton.new()
		selector.add_item("Sem van")
		selector.add_item("Van 1")
		selector.add_item("Van 2")
		selector.select(0)
		selector.item_selected.connect(func(_i): _refresh())
		people_grid.add_child(selector)
		selectors[p["id"]] = selector

func _refresh() -> void:
	var lines: PackedStringArray = []
	for van in [1, 2]:
		var names: PackedStringArray = []
		for p in Fase1Puzzles.VAN_PARTICIPANTS:
			if selectors[p["id"]].selected == van:
				names.append(p["nome"])
		lines.append("Van %d (%d/%d): %s" % [van, names.size(), Fase1Puzzles.VAN_CAPACITY, ", ".join(names) if names.size() > 0 else "vazia"])
	summary_label.text = "\n".join(lines)

func get_assignment() -> Dictionary:
	var assignment: Dictionary = {}
	for id in selectors:
		assignment[id] = selectors[id].selected
	return assignment

# Usado pelos testes para simular o jogador escolhendo as opções
func set_assignment(assignment: Dictionary) -> void:
	for id in assignment:
		if selectors.has(id):
			selectors[id].select(assignment[id])
	_refresh()

func _validate() -> Array[String]:
	return Fase1Puzzles.validate_vans(get_assignment())

func _success_text() -> String:
	return "Vans organizadas! Todas as restrições foram respeitadas e cada van tem um monitor."

func _set_inputs_enabled(enabled: bool) -> void:
	for id in selectors:
		selectors[id].disabled = not enabled
