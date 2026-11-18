extends PuzzleModal

# Task 2 — Conflito no Horário
# O jogador escolhe horário/sala de cada aula; a grade ao lado mostra conflitos em vermelho.

@onready var classes_grid: GridContainer = %ClassesGrid
@onready var board_grid: GridContainer = %BoardGrid

var selectors: Dictionary = {} # id da aula -> OptionButton
var board_cells: Dictionary = {} # slot -> Label

func _build() -> void:
	title_label.text = "Tarefa 2: Conflito no Horário"
	rules_label.text = "Regras: um professor não pode estar em duas turmas ao mesmo tempo • uma turma não pode ter duas aulas no mesmo horário • nenhuma turma pode perder aula • cada sala (e o laboratório) comporta só uma turma por horário • Ciências acontece no Laboratório, e o Laboratório é só para Ciências • o Prof. Carlos só chega no 2º horário • a Profa. Rita vai embora depois do 2º horário."

	for class_data in Fase1Puzzles.SCHEDULE_CLASSES:
		var label: Label = Label.new()
		label.text = Fase1Puzzles.get_class_label(class_data)
		classes_grid.add_child(label)

		var selector: OptionButton = OptionButton.new()
		for slot_name in Fase1Puzzles.SCHEDULE_SLOTS:
			selector.add_item(slot_name)
		selector.select(Fase1Puzzles.SCHEDULE_INITIAL.get(class_data["id"], 0))
		selector.item_selected.connect(func(_i): _refresh())
		classes_grid.add_child(selector)
		selectors[class_data["id"]] = selector

	# Grade visual: cabeçalho + 3 horários x (Sala 1, Sala 2, Laboratório)
	board_grid.columns = 1 + Fase1Puzzles.SCHEDULE_SALAS.size()
	board_grid.add_child(_make_cell("", true))
	for sala in Fase1Puzzles.SCHEDULE_SALAS:
		board_grid.add_child(_make_cell(sala, true))
	for horario in range(1, Fase1Puzzles.SCHEDULE_HORARIOS + 1):
		board_grid.add_child(_make_cell("%dº horário" % horario, true))
		for slot in Fase1Puzzles.SLOT_INFO:
			if Fase1Puzzles.SLOT_INFO[slot][0] == horario:
				var cell: Label = _make_cell("", false)
				board_grid.add_child(cell)
				board_cells[slot] = cell

func _make_cell(text: String, is_header: bool) -> Label:
	var cell: Label = Label.new()
	cell.text = text
	cell.custom_minimum_size = Vector2(64, 26 if not is_header else 14)
	cell.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cell.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cell.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if is_header:
		cell.add_theme_color_override("font_color", Color(0.29, 0.4, 0.25))
	return cell

# Mostra na grade quem está em cada horário/sala.
# Fica vermelho: sala com 2 turmas, a mesma turma/professor em duas salas no mesmo horário,
# professor fora do horário em que pode, Ciências fora do Laboratório ou outra aula dentro dele.
func _refresh() -> void:
	var occupants: Dictionary = {}
	var per_hour: Dictionary = {} # "horário|turma" ou "horário|professor" -> quantas aulas
	for class_data in Fase1Puzzles.SCHEDULE_CLASSES:
		var slot: int = selectors[class_data["id"]].selected
		if not occupants.has(slot):
			occupants[slot] = []
		occupants[slot].append(class_data)
		if Fase1Puzzles.SLOT_INFO.has(slot):
			var horario: int = Fase1Puzzles.SLOT_INFO[slot][0]
			for key in ["%d|%s" % [horario, class_data["turma"]], "%d|%s" % [horario, class_data["professor"]]]:
				per_hour[key] = per_hour.get(key, 0) + 1
	for slot in board_cells:
		var classes: Array = occupants.get(slot, [])
		var horario: int = Fase1Puzzles.SLOT_INFO[slot][0]
		var names: Array = []
		var conflict: bool = classes.size() > 1
		for class_data in classes:
			names.append("%s %s" % [class_data["disciplina"].left(3) + ".", class_data["turma"]])
			if per_hour["%d|%s" % [horario, class_data["turma"]]] > 1 or per_hour["%d|%s" % [horario, class_data["professor"]]] > 1:
				conflict = true
			var disponivel: Array = Fase1Puzzles.SCHEDULE_DISPONIVEL.get(class_data["professor"], [horario])
			if not disponivel.has(horario) or class_data["precisa_lab"] != (Fase1Puzzles.SLOT_INFO[slot][1] == Fase1Puzzles.LABORATORIO):
				conflict = true
		var cell: Label = board_cells[slot]
		cell.text = "\n".join(names) if not names.is_empty() else "livre"
		var color: Color = Color(0.75, 0.2, 0.1) if conflict else (Color(0.25, 0.25, 0.25) if names.size() == 1 else Color(0.55, 0.55, 0.55))
		cell.add_theme_color_override("font_color", color)

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
	return Fase1Puzzles.validate_schedule(get_assignment())

func _success_text() -> String:
	return "Grade organizada! Cada turma tem suas três aulas, nenhum professor está em dois lugares nem fora do seu horário, e cada sala recebe uma turma por vez."

func _set_inputs_enabled(enabled: bool) -> void:
	for id in selectors:
		selectors[id].disabled = not enabled
