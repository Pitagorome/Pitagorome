extends "res://tests/test_base.gd"

# TESTE 3 — Jogada completa da Fase 1 (integração)
# Simula um jogador do começo ao fim usando as cenas reais: anda, passa por portas,
# conversa com NPCs, erra e acerta cada desafio. Verifica tarefa, objetivo e HUD em cada passo.

const GABINETE: String = "res://scenes/intro/intro_scene.tscn"
const CORREDOR: String = "res://scenes/school/school_corridor.tscn"
const MATEMATICA: String = "res://scenes/school/math_classroom.tscn"
const ALMOX: String = "res://scenes/school/almoxarifado_scene.tscn"
const PORTAO: String = "res://scenes/school/portao_scene.tscn"

func _init() -> void:
	suite_name = "Teste 3 — Jogada completa da Fase 1"
	suite_description = "Simula um jogador fazendo as Tasks 1 a 5 nas cenas reais, incluindo respostas erradas, e confere o estado do jogo a cada passo."

func get_cases() -> Array:
	return [
		["T3.1 Início: diálogo da Coordenadora e criação do personagem", _inicio],
		["T3.2 Movimento do jogador e porta para o corredor", _movimento_e_porta],
		["T3.3 Task 1: tour (Zelador e Professor) leva de volta ao gabinete", _task1_tour],
		["T3.4 Task 2: grade de horários (erro e acerto)", _task2_grade],
		["T3.5 Task 3: cofre do almoxarifado (erro e acerto)", _task3_cofre],
		["T3.6 Task 4: depoimentos e acusação (erro e acerto)", _task4_suspeitos],
		["T3.7 Task 5: calendário e vans (erro e acerto)", _task5_vans],
		["T3.8 Fim da Fase 1", _fim_fase],
	]

# ---------------- Utilitários de simulação ----------------

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
	await _frames(4) # on_room_ready é chamado com call_deferred

func _go(path: String, spawn: String = "") -> void:
	Transition.change_scene(path, spawn)
	await _wait_transition()

func scene() -> Node:
	return tree().current_scene

func _find(name: String) -> Node:
	return scene().find_child(name, true, false) if scene() else null

# Lê todas as falas até o diálogo acabar (inclui diálogos encadeados pelos callbacks).
func _read_all(on_name_prompt: Callable = Callable()) -> Array:
	var lines: Array = []
	# A fala que já está na tela foi emitida antes de começarmos a escutar
	var box_now: Node = DialogueManager.dialogue_box_instance
	if DialogueManager.is_active and is_instance_valid(box_now):
		lines.append("%s: %s" % [box_now.speaker_label.text, box_now.text_label.text])
	var capture: Callable = func(speaker: String, text: String): lines.append("%s: %s" % [speaker, text])
	DialogueManager.dialogue_line_changed.connect(capture)
	var guard: int = 0
	while DialogueManager.is_active and guard < 200:
		guard += 1
		var box: Node = DialogueManager.dialogue_box_instance
		if is_instance_valid(box) and box.waiting_for_name:
			on_name_prompt.call(box)
		else:
			DialogueManager.advance()
		await _frames(1)
	DialogueManager.dialogue_line_changed.disconnect(capture)
	return lines

func _hud_text() -> String:
	var hud: Node = _find("HUD")
	return hud.task_label.text + " | " + hud.objective_label.text if hud else ""

func _modal() -> Node:
	return _find("ChallengeModal")

# ---------------- Casos ----------------

func _inicio() -> void:
	GameManager.reset_progress()
	await _go(GABINETE)
	check(scene() != null and scene().get("location_id") == "gabinete", "Jogo começa no gabinete do diretor")
	check(DialogueManager.is_active, "A Coordenadora começa a falar sozinha (introdução)")

	var preview: Dictionary = {}
	var lines: Array = await _read_all(func(box):
		box.name_line_edit.text = "Ana Teste"
		box.female_btn.button_pressed = true
		box.female_btn.pressed.emit()
		preview["antes"] = box.preview_rect.texture
		box.next_btn.pressed.emit() # troca a aparência para o Visual 2
		preview["depois"] = box.preview_rect.texture
		box._save_name_and_continue()
	)
	check(preview.get("antes") != null, "Seletor de visual mostra a prévia do personagem")
	check(preview.get("depois") != null and preview.get("depois") != preview.get("antes"), "A prévia muda quando troca o visual")
	check(lines.size() >= 6, "Introdução tem todas as falas do roteiro (%d)" % lines.size())
	check_eq(GameManager.player_name, "Ana Teste", "Nome digitado é salvo")
	check_eq(GameManager.player_gender, "F", "Gênero escolhido é salvo")
	check_eq(GameManager.player_appearance, 1, "Aparência escolhida é salva")
	check(lines.any(func(l): return l.contains("bem-vinda") and l.contains("Ana Teste")), "Boas-vindas usa o nome e o feminino")
	check(GameManager.intro_dialogue_finished, "Introdução marcada como concluída")
	check(_hud_text().contains("Tarefa 1") and _hud_text().contains("Zelador"), "HUD mostra a Tarefa 1 e o objetivo")
	check_eq(_find("HUD").director_label.text, "Diretora: Ana Teste", "HUD mostra 'Diretora: Ana Teste'")
	var player: Node = _find("Player")
	check(player.animated_sprite.sprite_frames == GameManager.get_appearance_frames(), "Sprite do jogador usa a aparência escolhida")

func _movimento_e_porta() -> void:
	var player: CharacterBody2D = _find("Player")
	var start_x: float = player.global_position.x
	Input.action_press("ui_left")
	await _physics_frames(20)
	Input.action_release("ui_left")
	check(player.global_position.x < start_x - 5.0, "Seta para a esquerda move o jogador (%.1f -> %.1f)" % [start_x, player.global_position.x])

	DialogueManager.start_dialogue([{"speaker": "Teste", "text": "..."}])
	var x_before: float = player.global_position.x
	Input.action_press("ui_right")
	await _physics_frames(15)
	Input.action_release("ui_right")
	check(absf(player.global_position.x - x_before) < 0.5, "Jogador fica parado durante um diálogo")
	await _read_all()

	# Leva o jogador até a porta do sul e deixa a física disparar a troca de sala
	await tree().create_timer(0.6).timeout # cooldown da porta
	var door: Node2D = _find("DoorToCorridor")
	player.global_position = door.global_position + Vector2(0, -12)
	await _physics_frames(6)
	await _wait_transition()
	check_eq(scene().get("location_id"), "corredor", "Entrar na porta leva ao corredor")
	var spawn: Node2D = _find("SpawnFromDirector")
	check(_find("Player").global_position.distance_to(spawn.global_position) < 2.0, "Jogador aparece no ponto de spawn certo")

func _task1_tour() -> void:
	var zelador: Node = _find("NPCZelador")
	zelador.interact()
	var lines: Array = await _read_all()
	check(lines.any(func(l): return l.contains("essa é a nova diretora")), "Coordenadora apresenta 'a nova diretora' ao Zelador")
	check(GameManager.tour_talked_zelador, "Conversa com o Zelador registrada")
	check(GameManager.current_objective.contains("Matemática"), "Objetivo muda para a Sala de Matemática")
	check_eq(GameManager.current_task_id, 1, "Tour ainda não acabou só com o Zelador")

	await _go(MATEMATICA, "SpawnFromCorridor")
	_find("NPCProfessor").interact()
	await _read_all()
	await _wait_transition()
	check(GameManager.is_task_completed(1), "Task 1 concluída depois de conhecer o Professor")
	check_eq(scene().get("location_id"), "gabinete", "A tela escurece e o jogo volta ao gabinete")
	check_eq(GameManager.current_task_id, 2, "Task 2 começa")

func _task2_grade() -> void:
	check(DialogueManager.is_active, "A Coordenadora aparece e explica o problema da grade")
	await _read_all()
	var puzzle: Node = _find("SchedulePuzzle")
	if not check(puzzle != null, "Puzzle da grade abre depois da explicação"):
		return
	check(DialogueManager.is_busy(), "Jogador fica travado enquanto o puzzle está aberto")
	var errors: Array[String] = puzzle.check_answer()
	check(errors.size() > 0 and puzzle.feedback_label.text.contains("problema"), "Verificar a grade inicial mostra os conflitos")
	check_eq(GameManager.current_task_id, 2, "Errar não avança a tarefa")

	puzzle.set_assignment({"mat_2b": 3})
	errors = puzzle.check_answer()
	check(errors.is_empty() and puzzle.is_solved, "Grade corrigida é aceita")
	puzzle.close()
	await _frames(2)
	check_eq(GameManager.current_task_id, 3, "Task 3 começa")
	var lines: Array = await _read_all()
	check(lines.any(func(l): return l.contains("almoxarifado")), "Coordenadora fala da encomenda no almoxarifado")
	check(not DialogueManager.is_busy(), "Jogador volta a poder andar")

func _task3_cofre() -> void:
	await _go(CORREDOR, "SpawnFromDirector")
	await _go(ALMOX, "SpawnFromCorridor")
	check_eq(scene().get("location_id"), "almoxarifado", "Chegou ao almoxarifado")
	var lines: Array = await _read_all()
	check(lines.any(func(l): return l.begins_with("Zelador") and l.contains("12")), "Zelador dá as pistas do cadeado")
	var marker: Node = _find("ExclamationMarker")
	check(marker.visible, "Armário mostra o '!'")

	_find("LockedCabinet").interact()
	var modal: Node = _modal()
	check(modal.modal_panel.visible and modal.code_container.visible, "Desafio do cadeado abre")
	modal.code_input.text = "2 3 7"
	modal._on_code_submitted()
	check(modal.feedback_panel.visible and not modal.last_answer_correct, "Senha errada mostra 'tente novamente'")
	check_eq(GameManager.current_task_id, 3, "Senha errada não avança")
	modal._on_feedback_closed()
	check(modal.modal_panel.visible, "Depois do erro o cadeado aparece de novo")

	modal.code_input.text = "2 4 6"
	modal._on_code_submitted()
	check(modal.last_answer_correct, "Senha 2 4 6 abre o cadeado")
	modal._on_feedback_closed()
	lines = await _read_all()
	check(lines.any(func(l): return l.contains("Ugh")), "Zelador: 'Ugh. Eu sabia que a senha era essa.'")
	check_eq(GameManager.current_task_id, 4, "Task 4 começa")
	await _frames(2)
	check(not marker.visible, "O '!' some depois de abrir")

func _task4_suspeitos() -> void:
	await _go(CORREDOR, "SpawnFromAlmox")
	check(DialogueManager.is_active, "Ao voltar ao corredor, a Coordenadora chama o diretor")
	await _read_all()
	for nome in ["AlunoJoao", "AlunoPedro", "AlunoLucas"]:
		check(_find(nome).visible, nome + " está no corredor")

	var coord: Node = _find("NPCCoordenadoraTask4")
	coord.interact()
	var lines: Array = await _read_all()
	check(lines.any(func(l): return l.contains("0 de 3")), "Coordenadora pede para ouvir os 3 antes de acusar")
	check(not _modal().modal_panel.visible, "Acusação ainda não abre")

	for nome in ["AlunoJoao", "AlunoPedro", "AlunoLucas"]:
		_find(nome).interact()
		await _read_all()
	check_eq(GameManager.testimonies_heard.size(), 3, "Os 3 depoimentos foram ouvidos")

	coord.interact()
	await _read_all()
	var modal: Node = _modal()
	check(modal.modal_panel.visible and modal.options_container.visible, "Pergunta 'quem faltou à aula?' abre")
	modal._on_option_selected(0) # João
	check(not modal.last_answer_correct, "Acusar o João está errado")
	modal._on_feedback_closed()
	modal._on_option_selected(1) # Pedro
	check(modal.last_answer_correct, "Acusar o Pedro está certo")
	modal._on_feedback_closed()
	lines = await _read_all()
	check(lines.any(func(l): return l.contains("Ele vai se ver comigo na prova")), "Professor: 'Ele vai se ver comigo na prova.'")
	check_eq(GameManager.current_task_id, 5, "Task 5 começa")

func _task5_vans() -> void:
	await _go(GABINETE, "SpawnFromCorridor")
	var marker: Node = _find("ExclamationMarker")
	check(marker.visible, "Calendário mostra o '!'")
	check(_find("NPCCoordenadora").visible == false, "Diretor(a) está sozinho(a) no gabinete")
	_find("Calendar").interact()
	var lines: Array = await _read_all()
	check(lines.any(func(l): return l.contains("excursão")), "Diretor(a) descobre a excursão no calendário")
	await _frames(2)
	check(not marker.visible, "O '!' do calendário some")
	check(GameManager.current_objective.contains("Portão"), "Objetivo manda ir ao portão")

	await _go(CORREDOR, "SpawnFromDirector")
	await _go(PORTAO, "SpawnFromCorridor")
	check(_find("Vans") != null, "As duas vans estão no portão")
	await _read_all()
	var puzzle: Node = _find("VanPuzzle")
	if not check(puzzle != null, "Puzzle das vans abre"):
		return
	var errors: Array[String] = puzzle.check_answer()
	check(errors.any(func(e): return e.contains("não tem van")), "Sem ninguém nas vans aparece erro")

	var errada: Dictionary = Fase1Puzzles.VAN_SOLUTION.duplicate()
	errada["pedro"] = 1
	errada["joao"] = 2
	puzzle.set_assignment(errada)
	errors = puzzle.check_answer()
	check(errors.size() > 0, "Distribuição errada é recusada (%s)" % " / ".join(errors))

	puzzle.set_assignment(Fase1Puzzles.VAN_SOLUTION)
	errors = puzzle.check_answer()
	check(errors.is_empty(), "Distribuição do roteiro é aceita")
	var van1: Node2D = _find("Van1")
	var x_before: float = van1.position.x
	puzzle.close()
	await tree().create_timer(2.3).timeout
	check(van1.position.x > x_before + 300.0, "As vans vão embora")

func _fim_fase() -> void:
	var lines: Array = await _read_all()
	check(lines.any(func(l): return l.contains("Obrigada")), "Diretora responde 'Obrigada' (feminino)")
	await _frames(2)
	check(Transition.is_transitioning, "Tela de 'Fim da Fase 1' aparece")
	var guard: int = 0
	while not Transition.caption_box.visible and guard < 300:
		guard += 1
		await _frames(1)
	check_eq(Transition.title_label.text, "Fim da Fase 1", "Cartão de fim de fase")
	await _wait_transition()
	check_eq(GameManager.completed_tasks.size(), 5, "As 5 tarefas da Fase 1 estão concluídas")
	check_eq(GameManager.current_phase, 2, "Jogo passa para a Fase 2")
	check(_hud_text().contains("Fase 1 concluída"), "HUD mostra 'Fase 1 concluída!'")
