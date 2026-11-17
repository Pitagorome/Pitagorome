extends "res://tests/test_base.gd"

# TESTE 5 — Jogada completa da Fase 2 (integração)
# Começa no dia seguinte ao fim da Fase 1 e joga as Tasks 6 a 10 nas cenas reais:
# passa pelas portas, conversa com os NPCs, erra e acerta cada desafio e confere
# tarefa, objetivo, luzes (apagão da Task 8) e HUD a cada passo.

const GABINETE: String = "res://scenes/intro/intro_scene.tscn"
const CORREDOR: String = "res://scenes/school/school_corridor.tscn"
const ALA: String = "res://scenes/school/ala_refeitorio_scene.tscn"
const ARMARIOS: String = "res://scenes/school/sala_armarios_scene.tscn"
const ARTES: String = "res://scenes/school/sala_artes_scene.tscn"
const GERADOR: String = "res://scenes/school/sala_gerador_scene.tscn"
const REFEITORIO: String = "res://scenes/school/refeitorio_scene.tscn"
const BIBLIOTECA: String = "res://scenes/school/biblioteca_scene.tscn"

func _init() -> void:
	suite_name = "Teste 5 — Jogada completa da Fase 2"
	suite_description = "Simula um jogador fazendo as Tasks 6 a 10 nas cenas reais, incluindo respostas erradas, e confere o estado do jogo a cada passo."

func get_cases() -> Array:
	return [
		["T5.1 Começo da Fase 2 no gabinete", _inicio],
		["T5.2 Task 6: bilhete do Zelador e armários (erro e acerto)", _task6],
		["T5.3 Task 7: caixas de figurinhas (erro e acerto) e apagão", _task7],
		["T5.4 Task 8: gerador (pouco, passou de 30 e exato)", _task8],
		["T5.5 Task 9: mesas do refeitório (erro e acerto)", _task9],
		["T5.6 Task 10: cartaz da feira em 2 passos (erro e acerto)", _task10],
		["T5.7 Fim da Fase 2", _fim],
	]

# ---------------- Utilitários (iguais aos do Teste 3) ----------------

func _frames(n: int = 2) -> void:
	for i in n:
		await tree().process_frame

func _physics_frames(n: int) -> void:
	for i in n:
		await tree().physics_frame

func _wait_transition() -> void:
	await _frames(2)
	var guard: int = 0
	while Transition.is_transitioning and guard < 2000:
		guard += 1
		await tree().process_frame
	await _frames(4)

func _go(path: String, spawn: String = "") -> void:
	Transition.change_scene(path, spawn)
	await _wait_transition()

func scene() -> Node:
	return tree().current_scene

func _find(name: String) -> Node:
	return scene().find_child(name, true, false) if scene() else null

func _read_all() -> Array:
	var lines: Array = []
	var box_now: Node = DialogueManager.dialogue_box_instance
	if DialogueManager.is_active and is_instance_valid(box_now):
		lines.append("%s: %s" % [box_now.speaker_label.text, box_now.text_label.text])
	var capture: Callable = func(speaker: String, text: String): lines.append("%s: %s" % [speaker, text])
	DialogueManager.dialogue_line_changed.connect(capture)
	var guard: int = 0
	while DialogueManager.is_active and guard < 200:
		guard += 1
		DialogueManager.advance()
		await _frames(1)
	DialogueManager.dialogue_line_changed.disconnect(capture)
	return lines

func _has(lines: Array, text: String) -> bool:
	return lines.any(func(l): return l.contains(text))

func _hud_text() -> String:
	var hud: Node = _find("HUD")
	return hud.task_label.text + " | " + hud.objective_label.text if hud else ""

func _modal() -> Node:
	return _find("ChallengeModal")

func _dark() -> bool:
	var e: CanvasModulate = _find("Escuridao") as CanvasModulate
	return e != null and e.color.v < 0.7

# ---------------- Casos ----------------

func _inicio() -> void:
	GameManager.jump_to_phase(2)
	GameManager.set_player_info("Bia Teste", "F", 2)
	await _go(GABINETE, "SpawnDesk")
	check_eq(scene().get("location_id"), "gabinete", "Fase 2 começa no gabinete")
	var lines: Array = await _read_all()
	check(_has(lines, "Novo trimestre"), "Diretora comenta o novo dia")
	check(_hud_text().contains("Fase 2 · Tarefa 6: O Troféu Desaparecido"), "HUD mostra 'Fase 2 · Tarefa 6'")
	check(GameManager.current_objective.contains("corredor"), "Objetivo manda ir ao corredor")
	check(not _find("NPCCoordenadora").visible, "A Coordenadora não está no gabinete")

func _task6() -> void:
	await _go(CORREDOR, "SpawnFromDirector")
	check(DialogueManager.is_active, "A Coordenadora chega apressada no corredor")
	var lines: Array = await _read_all()
	check(_has(lines, "troféu principal da escola desapareceu"), "Coordenadora: o troféu desapareceu")
	check(_has(lines, "Eu deixei duas pistas"), "Zelador: 'Eu não esqueci. Eu deixei duas pistas.'")
	check(_has(lines, "2x + 6 = 36"), "Bilhete mostra a equação 2x + 6 = 36")
	check(GameManager.current_objective.contains("Armários"), "Objetivo manda ir à Sala dos Armários")
	_find("NPCZelador").interact()
	lines = await _read_all()
	check(_has(lines, "2x + 6 = 36"), "Falar com o Zelador de novo mostra o bilhete")

	# Vai até a Ala do Refeitório andando pela porta nova do corredor (física de verdade)
	await tree().create_timer(0.6).timeout
	var player: Node2D = _find("Player")
	player.global_position = _find("DoorToAla").global_position + Vector2(0, -2)
	await _physics_frames(6)
	await _wait_transition()
	check_eq(scene().get("location_id"), "ala_refeitorio", "A porta '▲ Ala do Refeitório' leva à Ala do Refeitório")

	await _go(ARMARIOS, "SpawnFromAla")
	lines = await _read_all()
	check(_has(lines, "15 armários"), "Coordenadora espera na Sala dos Armários")
	_find("Armario15").interact()
	lines = await _read_all()
	check(_has(lines, "Nada de troféu"), "Armário 15 (errado) não tem o troféu")
	check_eq(GameManager.current_task_id, 6, "Armário errado não avança")
	_find("Armario9").interact()
	await _read_all()
	_find("Armario13").interact()
	lines = await _read_all()
	check(_has(lines, "x = 15"), "Depois de 3 erros a dica mostra x = 15")
	_find("Armario12").interact()
	lines = await _read_all()
	check(_has(lines, "O troféu da escola está lá dentro"), "Armário 12 tem o troféu")
	check(_has(lines, "foi por isso que o diretor anterior desistiu"), "Coordenadora: '...e foi por isso que o diretor anterior desistiu.'")
	check(GameManager.is_task_completed(6), "Task 6 concluída")
	check_eq(GameManager.current_task_id, 7, "Task 7 começa")

func _task7() -> void:
	await _go(ALA, "SpawnFromArmarios")
	await _go(ARTES, "SpawnFromAla")
	var lines: Array = await _read_all()
	check(_has(lines, "misturando as figurinhas"), "Professora explica o problema do mural")
	check(_has(lines, "3 figurinhas douradas, usamos 6"), "Professora diz a regra 3 : 6")
	check(_find("CaixaB").find_child("ExclamationMarker").visible, "Caixas mostram o '!'")
	_find("CaixaC").interact()
	lines = await _read_all()
	check(_has(lines, "6 douradas e 10 normais"), "Examinar a caixa C mostra o conteúdo")

	_find("NPCProfessora").interact()
	await _read_all()
	var modal: Node = _modal()
	check(modal.modal_panel.visible and modal.options_container.visible, "Pergunta das caixas abre")
	modal._on_option_selected(1) # caixa B
	check(not modal.last_answer_correct, "Caixa B está errada")
	check_eq(GameManager.current_task_id, 7, "Errar não avança")
	modal._on_feedback_closed()
	modal._on_option_selected(0) # caixa A
	check(modal.last_answer_correct, "Caixa A está certa")
	modal._on_feedback_closed()
	lines = await _read_all()
	check(_has(lines, "quase fingindo que não era da turma"), "Aluno: 'E eu já estava quase fingindo que não era da turma.'")
	check(_has(lines, "não entre em pânico"), "A escola fica escura: 'não entre em pânico'")
	check(GameManager.lights_out, "Apagão ligado")
	check_eq(GameManager.current_task_id, 8, "Task 8 começa")
	await _wait_transition()
	check_eq(scene().get("location_id"), "sala_gerador", "Todos vão até a sala do gerador")
	check(_dark(), "A sala do gerador está escura")

func _task8() -> void:
	var lines: Array = await _read_all()
	check(_has(lines, "exatamente 30 unidades"), "Mensagem do gerador: exatamente 30 unidades")
	check(_has(lines, "Se passar de 30"), "Zelador: 'Se passar de 30, ele reinicia...'")
	var puzzle: Node = _find("GeradorPuzzle")
	if not check(puzzle != null, "Painel do gerador abre"):
		return
	check(DialogueManager.is_busy(), "Jogador fica travado com o painel aberto")
	var errors: Array[String] = puzzle.check_answer()
	check(errors.size() == 1 and errors[0].contains("faltam 22"), "Sem alavancas: 'faltam 22'")
	puzzle.set_levers([true, true, true, true, true])
	check(puzzle.charge_label.text.contains("39"), "Painel mostra a carga 39 com todas ligadas")
	errors = puzzle.check_answer()
	check(errors.size() == 1 and errors[0].contains("passou de 30"), "Passar de 30 dá erro")
	check(puzzle.get_levers().all(func(v): return v == false), "Passou de 30: o gerador reinicia (alavancas desligam)")
	puzzle.set_levers([true, false, true, false, true]) # √36 + 3² + √49
	errors = puzzle.check_answer()
	check(errors.is_empty() and puzzle.is_solved, "√36 + 3² + √49 = 22, com 8 dá 30: aceito")
	puzzle.close()
	await _frames(2)
	lines = await _read_all()
	check(_has(lines, "Até que é bom enxergar de novo"), "Zelador: 'Até que é bom enxergar de novo.'")
	check(not GameManager.lights_out and not _dark(), "As luzes voltam")
	check_eq(GameManager.current_task_id, 9, "Task 9 começa")

	# A outra combinação também funciona (testa num painel novo)
	var outro: Node = Fase2Flow.open_gerador_puzzle()
	outro.set_levers([true, true, false, true, true]) # √36 + √25 + 2² + √49
	check(outro.check_answer().is_empty(), "A outra combinação (√36 + √25 + 2² + √49) também é aceita")
	outro.solved.disconnect(Fase2Flow._on_gerador_solved)
	outro.close()
	await _frames(2)

func _task9() -> void:
	await _go(ALA, "SpawnFromGerador")
	var lines: Array = await _read_all()
	check(_has(lines, "Cantineira discutindo"), "Na Ala dá para ouvir a discussão no refeitório")
	await _go(REFEITORIO, "SpawnFromAla")
	lines = await _read_all()
	check(_has(lines, "56 lugares"), "Coordenadora explica: 56 lugares")
	check(_has(lines, "Quer dizer... quase"), "Cantineira: 'Eu contei tudo direitinho! Quer dizer... quase.'")
	var modal: Node = _modal()
	check(modal.modal_panel.visible and modal.code_container.visible, "Pergunta das cadeiras abre")
	check(not modal.code_input.placeholder_text.contains("12") and not modal.question_label.text.contains("12"), "A resposta não aparece no texto de exemplo nem na pergunta")
	modal.code_input.text = "20"
	modal._on_code_submitted()
	check(not modal.last_answer_correct, "20 cadeiras está errado")
	check_eq(GameManager.current_task_id, 9, "Errar não avança")
	modal._on_feedback_closed()
	modal.code_input.text = "12"
	modal._on_code_submitted()
	check(modal.last_answer_correct, "12 cadeiras está certo")
	modal._on_feedback_closed()
	lines = await _read_all()
	check(_has(lines, "Só não sabia onde"), "Cantineira: 'Sabia que tinha contado certo. Só não sabia onde.'")
	check_eq(GameManager.current_task_id, 10, "Task 10 começa")

func _task10() -> void:
	await _go(ALA, "SpawnFromRefeitorio")
	await _go(CORREDOR, "SpawnFromAla")
	await _go(BIBLIOTECA, "SpawnFromCorridor")
	check(_find("NPCProfessorTask10").visible, "O Professor está na biblioteca")
	var lines: Array = await _read_all()
	check(_has(lines, "tragédia"), "Professor: '{diretor}, tragédia...'")
	check(_has(lines, "Diretora, tragédia"), "Fala usa 'Diretora' (feminino)")
	var modal: Node = _modal()
	check(modal.code_container.visible and modal.title_label.text.contains("1/2"), "Passo 1: pergunta da altura")
	modal.code_input.text = "51"
	modal._on_code_submitted()
	check(not modal.last_answer_correct, "Altura 51 está errada")
	modal._on_feedback_closed()
	modal.code_input.text = "60"
	modal._on_code_submitted()
	check(modal.last_answer_correct, "Altura 60 está certa")
	check_eq(GameManager.current_task_id, 10, "Acertar o passo 1 ainda não conclui a tarefa")
	modal._on_feedback_closed()
	await _read_all()
	check(modal.options_container.visible and modal.title_label.text.contains("2/2"), "Passo 2: escolher o cartaz")
	modal._on_option_selected(0) # cartaz A
	check(not modal.last_answer_correct, "Cartaz A está errado")
	modal._on_feedback_closed()
	modal._on_option_selected(1) # cartaz B (45x60)
	check(modal.last_answer_correct, "Cartaz B (45 x 60) está certo")
	modal._on_feedback_closed()

func _fim() -> void:
	var lines: Array = await _read_all()
	check(_has(lines, "anúncio de estacionamento"), "Professor: '...anúncio de estacionamento.'")
	await _frames(2)
	var guard: int = 0
	while not Transition.caption_box.visible and guard < 300:
		guard += 1
		await _frames(1)
	check_eq(Transition.title_label.text, "Fim da Fase 2", "Cartão 'Fim da Fase 2'")
	await _wait_transition()
	for t in range(6, 11):
		check(GameManager.is_task_completed(t), "Task %d concluída" % t)
	check_eq(GameManager.current_phase, 3, "Jogo passa para a Fase 3")
	check(_hud_text().contains("Fase 2 concluída"), "HUD mostra 'Fase 2 concluída!'")
