extends Node

# Autoload: Fase1Flow
# Roteiro jogável da Fase 1 — Lógica e Organização (Tasks 1 a 5).
# Cada sala avisa onde o jogador está (scripts/school_room.gd) e os NPCs/objetos
# chamam as funções daqui. Assim a história inteira da fase fica num lugar só.
# Falas: data/dialogues/fase1_dialogues.gd | Desafios: data/puzzles/fase1_puzzles.gd

signal puzzle_opened(puzzle: Node)
signal phase_finished()

const SCENE_GABINETE: String = "res://scenes/intro/intro_scene.tscn"
const SCHEDULE_PUZZLE: PackedScene = preload("res://scenes/ui/schedule_puzzle.tscn")
const VAN_PUZZLE: PackedScene = preload("res://scenes/ui/van_puzzle.tscn")
const CHALLENGE_MODAL: PackedScene = preload("res://scenes/ui/challenge_modal.tscn")

var current_location: String = ""

# ------------------------------------------------------------------
# Entrada nas salas (eventos automáticos)
# ------------------------------------------------------------------

func on_room_ready(location: String) -> void:
	current_location = location
	if Transition.is_transitioning:
		await Transition.transition_finished
	if current_location != location or DialogueManager.is_busy():
		return

	var task: int = GameManager.current_task_id
	if location == "portao" and task != 5:
		_remove_vans() # as vans só aparecem no dia da excursão
	match location:
		"gabinete":
			if task == 1 and not GameManager.intro_dialogue_finished:
				_start_intro()
			elif task == 2 and GameManager.mark_event("t2_briefing"):
				DialogueManager.start_dialogue(Fase1Dialogues.task2_briefing(), open_schedule_puzzle)
		"almoxarifado":
			if task == 3 and GameManager.mark_event("t3_arrival"):
				DialogueManager.start_dialogue(Fase1Dialogues.task3_arrival())
		"corredor":
			if task == 4 and GameManager.mark_event("t4_briefing"):
				DialogueManager.start_dialogue(Fase1Dialogues.task4_briefing())
		"portao":
			if task == 5 and GameManager.mark_event("t5_briefing"):
				GameManager.mark_event("t5_calendar")
				DialogueManager.start_dialogue(Fase1Dialogues.task5_briefing(), open_van_puzzle)

func _start_intro() -> void:
	DialogueManager.start_dialogue(IntroDialogues.get_intro_sequence(), func():
		GameManager.intro_dialogue_finished = true
		GameManager.set_objective("Saia pela porta ao sul do gabinete e encontre o Zelador no corredor.")
	)

# ------------------------------------------------------------------
# NPCs
# ------------------------------------------------------------------

func on_coordenadora_interact() -> void:
	var task: int = GameManager.current_task_id
	match task:
		1:
			if current_location == "gabinete":
				_say("Coordenadora", "Saia pela porta ao sul para começarmos o tour pelo corredor da escola!")
				return
		2:
			if current_location == "gabinete":
				DialogueManager.start_dialogue(Fase1Dialogues.task2_reminder(), open_schedule_puzzle)
				return
		3:
			if current_location == "almoxarifado":
				DialogueManager.start_dialogue(Fase1Dialogues.task3_arrival())
				return
		4:
			if current_location == "corredor":
				var heard: int = GameManager.testimonies_heard.size()
				if heard < Fase1Puzzles.SUSPECTS.size():
					DialogueManager.start_dialogue(Fase1Dialogues.task4_need_testimonies(heard))
				else:
					DialogueManager.start_dialogue(Fase1Dialogues.task4_ready(), open_accusation)
				return
		5:
			if current_location == "portao":
				DialogueManager.start_dialogue(Fase1Dialogues.task5_reminder(), open_van_puzzle)
				return
		0:
			_say("Coordenadora", "Excelente trabalho na administração da escola até aqui, {diretor} {player_name}!")
			return
	_say("Coordenadora", Fase1Dialogues.hint_for_task(task))

func on_zelador_interact() -> void:
	if GameManager.current_task_id == 1 and not GameManager.tour_talked_zelador:
		_tour_talk(IntroDialogues.get_zelador_sequence(), "zelador")
	elif GameManager.current_task_id == 3 and current_location == "almoxarifado":
		DialogueManager.start_dialogue(Fase1Dialogues.task3_arrival().slice(1, 4))
	else:
		DialogueManager.start_dialogue(Fase1Dialogues.zelador_idle())

func on_professor_interact() -> void:
	if GameManager.current_task_id == 1 and not GameManager.tour_talked_professor:
		_tour_talk(IntroDialogues.get_professor_matematica_sequence(), "professor")
	elif GameManager.current_task_id == 4 and current_location == "corredor":
		_say("Professor de Matemática", "Só UM deles está mentindo. Teste cada hipótese, {diretor}.")
	else:
		DialogueManager.start_dialogue(Fase1Dialogues.professor_idle())

func _tour_talk(lines: Array, who: String) -> void:
	DialogueManager.start_dialogue(lines, func():
		if who == "zelador":
			GameManager.tour_talked_zelador = true
		else:
			GameManager.tour_talked_professor = true
		if GameManager.check_tour_progress():
			DialogueManager.start_dialogue(Fase1Dialogues.tour_complete(), func():
				Transition.change_scene(SCENE_GABINETE, "SpawnDesk", "Mais tarde, no gabinete...")
			)
	)

func hear_testimony(suspect_id: String, speaker: String) -> void:
	var fala: String = ""
	for s in Fase1Puzzles.SUSPECTS:
		if s["id"] == suspect_id:
			fala = s["fala"]
	DialogueManager.start_dialogue([{"speaker": speaker, "text": fala}], func():
		GameManager.testimonies_heard[suspect_id] = true
		var heard: int = GameManager.testimonies_heard.size()
		if heard >= Fase1Puzzles.SUSPECTS.size():
			GameManager.set_objective("Você ouviu todos. Fale com a Coordenadora e diga quem mentiu.")
		else:
			GameManager.set_objective("Ouça João, Pedro e Lucas (%d/3) e depois fale com a Coordenadora." % heard)
	)

# ------------------------------------------------------------------
# Objetos do cenário (interactable_object.gd com flow_event)
# ------------------------------------------------------------------

func on_object_event(event_id: String, _source: Node = null) -> void:
	match event_id:
		"cofre":
			if GameManager.current_task_id == 3:
				open_cofre()
			elif GameManager.is_task_completed(3):
				_say("Armário", "O armário está aberto. Os materiais novos já foram distribuídos.")
			else:
				_say("Armário", "Um armário trancado com cadeado de 3 dígitos.")
		"calendario":
			if GameManager.current_task_id == 5 and GameManager.mark_event("t5_calendar"):
				DialogueManager.start_dialogue(Fase1Dialogues.task5_calendar(), func():
					GameManager.set_objective("Vá até o Portão da escola (corredor, porta de baixo à direita).")
				)
			else:
				_say("Calendário", "Calendário escolar do trimestre. Os dias passam rápido por aqui...")

# ------------------------------------------------------------------
# Desafios
# ------------------------------------------------------------------

func open_schedule_puzzle() -> Node:
	var puzzle: Node = _open_puzzle(SCHEDULE_PUZZLE)
	puzzle.solved.connect(_on_schedule_solved)
	return puzzle

func _on_schedule_solved() -> void:
	GameManager.complete_task(2)
	DialogueManager.start_dialogue(Fase1Dialogues.task2_done())

func open_cofre() -> Node:
	var modal: Node = _get_challenge_modal()
	var context: String = "Pistas do cadeado:\n• " + "\n• ".join(Fase1Puzzles.COFRE_PISTAS)
	modal.show_code_challenge(
		3,
		"Tarefa 3: O Cofre da Escola",
		context,
		"Qual é a senha de 3 dígitos? (ex: 1 2 3)",
		Fase1Puzzles.COFRE_SENHA,
		"Cofre aberto! 2 é par, 2 + 4 + 6 = 12, os dígitos são diferentes, crescentes, todos pares e nenhum é zero.",
		"Essa senha não serve. Confira cada pista: teste os números pares possíveis para o primeiro dígito e veja quais somam 12.",
		func(): DialogueManager.start_dialogue(Fase1Dialogues.task3_done())
	)
	puzzle_opened.emit(modal)
	return modal

func open_accusation() -> Node:
	var modal: Node = _get_challenge_modal()
	var context: String = "Depoimentos (apenas UM aluno está mentindo):\n"
	for s in Fase1Puzzles.SUSPECTS:
		context += "• %s: \"%s\"\n" % [s["nome"], s["fala"]]
	var options: Array[String] = []
	var correct: int = 0
	for i in Fase1Puzzles.SUSPECTS.size():
		options.append("%s está mentindo." % Fase1Puzzles.SUSPECTS[i]["nome"])
		if Fase1Puzzles.SUSPECTS[i]["id"] == Fase1Puzzles.CULPADO:
			correct = i
	modal.show_multiple_choice_challenge(
		4,
		"Tarefa 4: Quem Está Matando Aula?",
		context.strip_edges(),
		"Quem faltou à aula sem autorização?",
		options,
		correct,
		"Isso! Se o João mentisse, o Lucas também estaria mentindo (seriam dois). Se o Lucas mentisse, o João também mentiria. Só sobra o Pedro: ele foi à biblioteca e matou aula.",
		"Suponha que esse aluno é o mentiroso e veja as outras falas. Se aparecer um SEGUNDO mentiroso, a hipótese está errada!",
		func(): DialogueManager.start_dialogue(Fase1Dialogues.task4_done())
	)
	puzzle_opened.emit(modal)
	return modal

func open_van_puzzle() -> Node:
	var puzzle: Node = _open_puzzle(VAN_PUZZLE)
	puzzle.solved.connect(_on_vans_solved)
	return puzzle

func _on_vans_solved() -> void:
	await _drive_vans_away()
	DialogueManager.start_dialogue(Fase1Dialogues.task5_done(), _finish_phase)

func _finish_phase() -> void:
	GameManager.complete_task(5)
	await Transition.show_card("Fim da Fase 1", "Lógica e Organização concluída!\nObrigado por jogar o protótipo do Pitagorome.", 4.0)
	phase_finished.emit()

func _drive_vans_away() -> void:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return
	for npc in get_tree().get_nodes_in_group("excursao"):
		npc.visible = false
		npc.process_mode = Node.PROCESS_MODE_DISABLED
	var vans: Node = scene.find_child("Vans", true, false)
	if vans == null:
		return
	var tween: Tween = create_tween().set_parallel(true)
	for van in vans.get_children():
		tween.tween_property(van, "position:x", van.position.x + 420.0, 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished

func _remove_vans() -> void:
	var scene: Node = get_tree().current_scene
	var vans: Node = scene.find_child("Vans", true, false) if scene else null
	if vans:
		vans.queue_free()

# ------------------------------------------------------------------
# Utilitários
# ------------------------------------------------------------------

func _open_puzzle(packed: PackedScene) -> Node:
	var puzzle: Node = packed.instantiate()
	_ui_parent().add_child(puzzle)
	puzzle_opened.emit(puzzle)
	return puzzle

func _get_challenge_modal() -> Node:
	var parent: Node = _ui_parent()
	var modal: Node = parent.find_child("ChallengeModal", true, false)
	if modal == null:
		modal = CHALLENGE_MODAL.instantiate()
		parent.add_child(modal)
	return modal

func _ui_parent() -> Node:
	var scene: Node = get_tree().current_scene
	return scene if scene != null else get_tree().root

func _say(speaker: String, text: String) -> void:
	DialogueManager.start_dialogue([{"speaker": speaker, "text": text}])
