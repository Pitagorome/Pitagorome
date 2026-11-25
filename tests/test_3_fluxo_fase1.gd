extends "res://tests/test_base.gd"

# TESTE 3 — Jogada completa da Fase 1 (integração)
# Simula um jogador do começo ao fim usando as cenas reais: anda, passa por portas,
# conversa com NPCs, erra e acerta cada desafio. Verifica tarefa, objetivo e HUD em cada passo.

const GABINETE: String = "res://scenes/intro/intro_scene.tscn"
const CORREDOR: String = "res://scenes/school/school_corridor.tscn"
const MATEMATICA: String = "res://scenes/school/math_classroom.tscn"
const ALMOX: String = "res://scenes/school/almoxarifado_scene.tscn"
const PORTAO: String = "res://scenes/school/portao_scene.tscn"
const HISTORIA: String = "res://scenes/intro/historia_inicio.tscn"
const MENU: String = "res://scenes/ui/menu_inicial.tscn"

func _init() -> void:
	suite_name = "Teste 3 — Jogada completa da Fase 1"
	suite_description = "Simula um jogador fazendo as Tasks 1 a 5 nas cenas reais, incluindo respostas erradas, e confere o estado do jogo a cada passo."

func get_cases() -> Array:
	return [
		["T3.0 Historinha do começo (demissão, jornal, chegada) e botão de pular", _historia],
		["T3.0b Menu inicial: Jogar leva à historinha e Volume mostra Geral, Música e Interações", _menu],
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

# Roda a historinha do começo até chegar no gabinete. Avança cada fala assim que aparece.
# Devolve as falas vistas. (A cutscene usa tempo de verdade: leva uns 20 s.)
func _assistir_historia(pular_depois_de: int = -1) -> Array:
	var lines: Array = []
	var capture: Callable = func(speaker: String, text: String): lines.append("%s: %s" % [speaker, text])
	DialogueManager.dialogue_line_changed.connect(capture)
	Transition.change_scene(HISTORIA)
	await _wait_transition()
	var inicio: int = Time.get_ticks_msec()
	while Time.get_ticks_msec() - inicio < 90000:
		await _frames(1)
		var cena: Node = scene()
		if cena and cena.get("location_id") == "gabinete" and not Transition.is_transitioning:
			break
		if pular_depois_de >= 0 and lines.size() >= pular_depois_de and cena and cena.has_method("pular"):
			cena.pular()
			pular_depois_de = -1
		if DialogueManager.is_active and not Transition.is_transitioning and cena and cena.name == "HistoriaInicio":
			DialogueManager.advance()
	DialogueManager.dialogue_line_changed.disconnect(capture)
	await _frames(4)
	return lines

# Pedido de 24/11: menu inicial com Jogar e ajuste de volume
func _menu() -> void:
	GameManager.reset_progress()
	Transition.change_scene(MENU)
	await _wait_transition()
	await _frames(5)
	var menu: Node = scene()
	if not check(menu != null and menu.name == "MenuInicial", "Menu inicial abre"):
		return
	check(menu.botao_jogar.visible and menu.botao_jogar.text == "Jogar", "Tem o botão Jogar")
	check(not menu.caixa_volume.visible, "Barrinhas de volume começam escondidas")
	menu.botao_volume.pressed.emit()
	check(menu.caixa_volume.visible, "Botão Volume mostra as barrinhas")
	var sliders: Array = menu.caixa_volume.find_children("*", "HSlider", true, false)
	check_eq(sliders.size(), 3, "3 barrinhas (Geral, Música, Interações)")
	if sliders.size() == 3:
		Audio.salvar_config_ativo = false
		var antes: float = Audio.get_volume("Musica")
		(sliders[1] as HSlider).value = 40
		check(absf(Audio.get_volume("Musica") - 0.4) < 0.01, "Barrinha de Música do menu muda o volume da música")
		check(absf(ControleVolume._sliders["Musica"].value - 40.0) < 0.01, "Painel do canto acompanha o menu")
		Audio.set_volume("Musica", antes)
		Audio.salvar_config_ativo = true
	check(not menu.botao_sair.visible or not OS.has_feature("web"), "Sair não aparece no navegador")
	check(menu.botao_creditos.visible and not menu.janela_creditos.visible, "Tem o botão Créditos e a janela começa fechada")
	menu.botao_creditos.pressed.emit()
	check(menu.janela_creditos.visible and not menu.caixa_volume.visible, "Créditos abre e fecha o Volume (uma janela por vez)")
	menu.alternar_creditos()
	menu.botao_jogar.pressed.emit()
	var inicio: int = Time.get_ticks_msec()
	while Time.get_ticks_msec() - inicio < 10000:
		await _frames(1)
		if scene() and scene().name == "HistoriaInicio" and not Transition.is_transitioning:
			break
	check(scene() != null and scene().name == "HistoriaInicio", "Jogar leva à historinha")
	# deixa a historinha pronta para o próximo caso (que abre a historinha de novo do zero)
	if scene() and scene().has_method("pular"):
		scene().pular()
	inicio = Time.get_ticks_msec()
	while Time.get_ticks_msec() - inicio < 15000:
		await _frames(1)
		if scene() and scene().get("location_id") == "gabinete" and not Transition.is_transitioning:
			break
	DialogueManager.end_dialogue()

func _historia() -> void:
	GameManager.reset_progress()
	check_eq(ProjectSettings.get_setting("application/run/main_scene"), MENU, "O jogo abre no menu inicial (Jogar leva à historinha)")
	var lines: Array = await _assistir_historia()
	check(lines.any(func(l): return l.begins_with("Coordenadora:") and l.contains("demitido")), "Cena 1: a Coordenadora conta ao Diretor Otávio que ele foi demitido")
	check(lines.any(func(l): return l.begins_with("Diretor Otávio:")), "O Diretor Otávio fala")
	check(lines.any(func(l): return l.begins_with("???:") and l.contains("preenchida")), "Cena 2: o novo diretor procura emprego no jornal")
	check(lines.any(func(l): return l.contains("Procura-se diretor(a) para a Escola Pitagórica")), "Ele acha o anúncio da escola")
	check(lines.any(func(l): return l.begins_with("???:") and l.contains("é aqui")), "Cena 3: chega no portão da escola")
	check(not lines.any(func(l): return l.contains("Pular") or l.contains("{")), "Nenhuma fala com marcador sobrando")
	check(scene() != null and scene().get("location_id") == "gabinete", "Depois da história vai para o gabinete")
	var player: Node = _find("Player")
	var spawn: Node = _find("SpawnFromCorridor")
	check(player != null and spawn != null and player.global_position.distance_to(spawn.global_position) < 2.0, "O jogador entra pela porta do gabinete")
	await _frames(10)
	check(DialogueManager.is_active and DialogueManager.dialogue_box_instance.text_label.text.contains("Ah, você chegou!"), "A Coordenadora recebe: 'Ah, você chegou!'")
	check(not GameManager.player_named, "O nome ainda não foi escolhido (a Coordenadora pergunta depois)")
	DialogueManager.end_dialogue()
	# Pular: Esc / botão no canto leva direto ao gabinete
	GameManager.reset_progress()
	lines = await _assistir_historia(1)
	check(lines.size() <= 2, "Pular corta a história no meio (%d falas vistas)" % lines.size())
	check(scene() != null and scene().get("location_id") == "gabinete", "Pular leva ao gabinete")
	await _frames(10)
	check(DialogueManager.is_active and DialogueManager.dialogue_box_instance.text_label.text.contains("Ah, você chegou!"), "Depois de pular, a introdução da Coordenadora começa normalmente")
	DialogueManager.end_dialogue()

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
		preview["crachá_antes"] = _find("HUD").director_panel.visible
		box.next_btn.pressed.emit() # troca a aparência para o Visual 2
		preview["depois"] = box.preview_rect.texture
		box._save_name_and_continue()
	)
	check(preview.get("antes") != null, "Seletor de visual mostra a prévia do personagem")
	check(preview.get("crachá_antes") == false, "Antes de confirmar o nome, o HUD não mostra o crachá do diretor")
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
	# Apontamento do grupo (18/11): no lugar da caixa verde grande, uma prancheta que abre ao clicar/Tab
	var hud: Node = _find("HUD")
	check(hud.botao_prancheta.visible and hud.botao_prancheta.text.contains("Tarefa"), "HUD mostra a prancheta 'Tarefa N' no canto")
	hud.espiando = false
	hud._atualizar_painel()
	check(not hud.painel_visivel(), "A caixa da tarefa fica fechada (não atrapalha a visão)")
	hud.botao_prancheta.pressed.emit()
	check(hud.painel_visivel() and hud.objective_label.text != "", "Clicar na prancheta mostra a tarefa e o objetivo")
	var tab := InputEventKey.new()
	tab.keycode = KEY_TAB
	tab.pressed = true
	Input.parse_input_event(tab)
	await _frames(2)
	check(not hud.painel_visivel(), "Tab fecha a prancheta")
	var objetivo_antes: String = GameManager.current_objective
	GameManager.set_objective("Objetivo de teste")
	check(hud.painel_visivel() and hud.aviso_label.visible, "Objetivo novo: a prancheta abre sozinha e mostra '!'")
	hud._espiada_id += 1 # não espera os 4 s
	hud.espiando = false
	hud._atualizar_painel()
	check(not hud.painel_visivel() and hud.aviso_label.visible, "Depois fecha sozinha, mas o '!' fica até o jogador abrir")
	hud.alternar_prancheta()
	check(not hud.aviso_label.visible, "Abrir a prancheta apaga o '!'")
	hud.alternar_prancheta()
	GameManager.set_objective(objetivo_antes)
	hud._espiada_id += 1
	hud.espiando = false
	hud.aviso_label.visible = false
	hud._atualizar_painel()
	var player: CharacterBody2D = _find("Player")
	var start_x: float = player.global_position.x
	await _segurar_tecla(KEY_LEFT, 20)
	check(player.global_position.x < start_x - 5.0, "Seta para a esquerda move o jogador (%.1f -> %.1f)" % [start_x, player.global_position.x])
	var x_wasd: float = player.global_position.x
	await _segurar_tecla(KEY_D, 20)
	check(player.global_position.x > x_wasd + 5.0, "Tecla D (WASD) move o jogador para a direita (%.1f -> %.1f)" % [x_wasd, player.global_position.x])
	var y_wasd: float = player.global_position.y
	await _segurar_tecla(KEY_W, 10)
	check(player.global_position.y < y_wasd - 2.0, "Tecla W (WASD) move o jogador para cima (%.1f -> %.1f)" % [y_wasd, player.global_position.y])
	await _segurar_tecla(KEY_S, 10) # volta para onde estava

	DialogueManager.start_dialogue([{"speaker": "Teste", "text": "..."}])
	var x_before: float = player.global_position.x
	await _segurar_tecla(KEY_RIGHT, 15)
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

	# Bug de 18/11: entrar numa sala e voltar LOGO para a porta não trocava de sala (a porta
	# ignorava quem encostava nela nos primeiros 0,5 s e depois não percebia mais) e o jogador
	# andava pela passagem escura até a parte vazia do mapa.
	if DialogueManager.is_busy():
		await _read_all()
	var volta: Node2D = _find("DoorToDirectorOffice")
	_find("Player").global_position = volta.global_position + Vector2(0, -12)
	await _physics_frames(6)
	await _wait_transition()
	check_eq(scene().get("location_id"), "gabinete", "Voltar logo para a porta de onde veio troca de sala (não fica preso na passagem)")
	await _go(CORREDOR, "SpawnFromDirector")
	if DialogueManager.is_busy():
		await _read_all()

func _task1_tour() -> void:
	var coord: Node2D = _find("NPCCoordenadora")
	var player: Node2D = _find("Player")
	# Bug de 17/11: a Coordenadora ficava parada na porta e "falava de longe" com o Zelador
	# A Coordenadora fica parada no meio do caminho (ex.: o jogador andou rápido) e o jogador vai até o Zelador
	coord.global_position = Vector2(35, 45)
	player.global_position = Vector2(-60, 20)
	await _physics_frames(2)
	check(coord.global_position.distance_to(player.global_position) > 60.0, "(preparação) jogador longe de onde a Coordenadora começou")
	var zelador: Node = _find("NPCZelador")
	zelador.interact()
	await _frames(2)
	check(coord.global_position.distance_to(player.global_position) < 40.0, "A Coordenadora está ao lado do jogador quando apresenta o Zelador (%.0f px)" % coord.global_position.distance_to(player.global_position))
	var lines: Array = await _read_all()
	check(lines.any(func(l): return l.contains("essa é a nova diretora")), "Coordenadora apresenta 'a nova diretora' ao Zelador")
	check(GameManager.tour_talked_zelador, "Conversa com o Zelador registrada")
	check(GameManager.current_objective.contains("Matemática"), "Objetivo muda para a Sala de Matemática")
	check_eq(GameManager.current_task_id, 1, "Tour ainda não acabou só com o Zelador")

	# Andando, a Coordenadora vai atrás do jogador
	player = _find("Player")
	coord = _find("NPCCoordenadora")
	var antes: Vector2 = coord.global_position
	await _segurar_tecla(KEY_LEFT, 50)
	await _physics_frames(30)
	check(coord.global_position.x < antes.x - 40.0 and coord.global_position.distance_to(player.global_position) < 60.0, "A Coordenadora acompanha o jogador pelo corredor")

	await _go(MATEMATICA, "SpawnFromCorridor")
	await _physics_frames(2)
	var coord_mat: Node2D = _find("NPCCoordenadora")
	check(coord_mat.global_position.distance_to(_find("Player").global_position) < 40.0, "Na Sala de Matemática a Coordenadora entra junto com o jogador")
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

	# Bug do print: a grade não ficava vermelha quando a mesma turma tinha duas aulas no mesmo horário
	var vermelho := Color(0.75, 0.2, 0.1)
	var dupla: Dictionary = Fase1Puzzles.SCHEDULE_SOLUTION.duplicate()
	dupla["cie_1a"] = 6 # Ciências do 1º A no 2º horário, junto com Matemática do 1º A
	puzzle.set_assignment(dupla)
	check(puzzle.board_cells[4].get_theme_color("font_color") == vermelho and puzzle.board_cells[6].get_theme_color("font_color") == vermelho, "Turma com duas aulas no mesmo horário fica vermelha na grade")
	check(puzzle.rules_label.text.contains("uma turma não pode ter duas aulas"), "Regra da turma aparece no texto do desafio")
	check(puzzle.rules_label.text.contains("Prof. Carlos só chega no 2º horário"), "Horário dos professores aparece no texto do desafio")
	puzzle.set_assignment(Fase1Puzzles.SCHEDULE_SOLUTION)
	check(puzzle.board_cells.values().all(func(c): return c.get_theme_color("font_color") != vermelho), "Grade certa não tem nada vermelho")
	puzzle.set_assignment(Fase1Puzzles.SCHEDULE_INITIAL)
	check(puzzle.board_cells[1].get_theme_color("font_color") == vermelho, "Grade inicial mostra o conflito em vermelho")
	puzzle.set_assignment({"mat_2b": 4})
	check(not puzzle.check_answer().is_empty(), "Mudar só uma aula não resolve mais (Tarefa 2 ficou mais difícil)")

	puzzle.set_assignment(Fase1Puzzles.SCHEDULE_SOLUTION)
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
	errada["pedro"] = 2 # troca Pedro e João de van
	errada["joao"] = 1
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
	# Bug de 17/11: entre os cartões a tela voltava a mostrar o portão (com o HUD já na Fase 2)
	var titulos: Array = []
	var portao_apareceu: bool = false
	guard = 0
	while Transition.is_transitioning and guard < 2000:
		guard += 1
		if Transition.caption_box.visible and not titulos.has(Transition.title_label.text):
			titulos.append(Transition.title_label.text)
		if scene() and scene().get("location_id") == "portao" and Transition.fade_rect.modulate.a < 0.99:
			portao_apareceu = true
		await _frames(1)
	check(not portao_apareceu, "A tela fica preta entre 'Fim da Fase 1' e o dia seguinte (o portão não reaparece)")
	check_eq(titulos, ["Fim da Fase 1", "Fase 2", "No dia seguinte..."], "Cartões da virada de fase em ordem")
	await _wait_transition()
	check_eq(GameManager.completed_tasks.size(), 5, "As 5 tarefas da Fase 1 estão concluídas")
	check_eq(GameManager.current_phase, 2, "Jogo passa para a Fase 2")
	# Depois do cartão "Fase 2" o jogo leva ao gabinete ("No dia seguinte...")
	var guard2: int = 0
	while (Transition.is_transitioning or scene() == null or scene().get("location_id") != "gabinete") and guard2 < 1500:
		guard2 += 1
		await _frames(1)
	await _frames(4)
	check_eq(scene().get("location_id"), "gabinete", "Fase 2 começa no gabinete, no dia seguinte")
	check_eq(GameManager.current_task_id, 6, "Fase 2 começa na Tarefa 6")
	check(_hud_text().contains("Fase 2") and _hud_text().contains("Troféu"), "HUD mostra 'Fase 2 · Tarefa 6: O Troféu Desaparecido'")
	await _read_all()

# Simula o aperto de uma tecla física (passa pelo mapa de ações do project.godot)
func _segurar_tecla(tecla: Key, frames: int) -> void:
	var ev := InputEventKey.new()
	ev.physical_keycode = tecla
	ev.pressed = true
	Input.parse_input_event(ev)
	await _physics_frames(frames)
	var solta := ev.duplicate()
	solta.pressed = false
	Input.parse_input_event(solta)
	await _physics_frames(1)
