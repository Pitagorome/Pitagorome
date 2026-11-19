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
		["T5.6 Task 10: cartaz da feira, uma pergunta só (erro e acerto)", _task10],
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
	# Apontamento do grupo (18/11): no saguão só o problema; o bilhete é lido na Sala dos Armários
	check(not _has(lines, "2x + 6 = 36"), "No saguão a equação ainda NÃO aparece (só o problema)")
	check(_has(lines, "quadro de avisos da Sala dos Armários"), "Zelador diz onde deixou o bilhete")
	check(GameManager.current_objective.contains("Armários") and GameManager.current_objective.contains("bilhete"), "Objetivo manda ler o bilhete na Sala dos Armários")
	check(not _find("HUD").note_label.visible, "O bilhete ainda não está no HUD (não foi lido)")
	_find("NPCZelador").interact()
	lines = await _read_all()
	check(_has(lines, "quadro de avisos"), "Falar com o Zelador de novo lembra onde está o bilhete")

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
	check(_has(lines, "Leia primeiro"), "Coordenadora pede para ler o bilhete primeiro")
	# image-14 (18/11): o bilhete estava no chão e passava por cima do personagem
	var bilhete: Node2D = _find("Bilhete")
	check(bilhete.global_position.y <= -100.0, "O bilhete fica no quadro de avisos da parede (não no chão)")
	check(bilhete.z_index == 0, "O bilhete não é desenhado por cima de quem passa")
	_find("Armario12").interact()
	lines = await _read_all()
	check(_has(lines, "leia o bilhete"), "Antes de ler o bilhete os armários não abrem (nem o certo)")
	check(not GameManager.is_task_completed(6), "Abrir o armário certo sem ler o bilhete não conclui a tarefa")
	_find("Bilhete").interact()
	lines = await _read_all()
	check(_has(lines, "2x + 6 = 36"), "O bilhete na parede mostra a equação 2x + 6 = 36")
	check(_has(lines, "1º passo") and _has(lines, "2º passo"), "Depois do bilhete a Coordenadora explica passo a passo")
	var hud: Node = _find("HUD")
	check(hud.note_label.visible and hud.note_label.text.contains("2x + 6 = 36"), "Depois de lido, o bilhete fica escrito no HUD")
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
	check(not _find("HUD").note_label.visible, "Achou o troféu: o bilhete sai do HUD")
	check_eq(GameManager.current_task_id, 7, "Task 7 começa")

func _task7() -> void:
	await _go(ALA, "SpawnFromArmarios")
	# Apontamento do grupo (18/11): a fala de quem entra na sala espera um pouco (dá para ver a sala antes)
	Fase1Flow.atraso_entrada = 1.0
	await _go(ARTES, "SpawnFromAla")
	check(not DialogueManager.is_active, "Logo ao entrar na Sala de Artes a caixa de texto ainda não aparece")
	await tree().create_timer(1.2).timeout
	check(DialogueManager.is_active, "Depois de ~1 s a Professora começa a falar")
	Fase1Flow.atraso_entrada = 0.0
	# Apontamento do grupo (18/11): retrato de quem fala no canto do balão
	var box: Node = _find("DialogueBox")
	check(not box.retrato_moldura.visible, "1ª fala é narração: sem retrato")
	DialogueManager.advance()
	await _frames(1)
	check(box.speaker_label.text == "Professora" and box.retrato_moldura.visible and box.retrato.texture != null, "Na fala da Professora o balão mostra o retrato dela")
	var lines: Array = await _read_all()
	check(_has(lines, "misturando as figurinhas"), "Professora explica o problema do mural")
	DialogueManager.start_dialogue([{"speaker": "", "text": "(narração)"}])
	await _frames(1)
	check(not box.retrato_moldura.visible, "Narração fica sem retrato")
	await _read_all()
	DialogueManager.start_dialogue([{"speaker": "{player_name}", "text": "Oi"}])
	await _frames(1)
	check(box.retrato_moldura.visible and box.retrato.texture.atlas == GameManager.get_appearance_frames().get_frame_texture("idle_down", 0).atlas, "Quando o jogador fala aparece o visual escolhido")
	await _read_all()
	check(_has(lines, "3 figurinhas douradas, usamos 6"), "Professora diz a regra 3 : 6")
	check(_find("CaixaB").find_child("ExclamationMarker").visible, "Caixas mostram o '!'")
	_find("CaixaC").interact()
	lines = await _read_all()
	check(_has(lines, "6 douradas e 10 normais"), "Examinar a caixa C mostra o conteúdo")
	check(_has(lines, "Falta olhar: Caixa A e Caixa B"), "Diz quais caixas faltam olhar")

	# Pedido de 17/11: a pergunta não pode dar o conteúdo das caixas de graça
	_find("NPCProfessora").interact()
	lines = await _read_all()
	var modal: Node = _modal()
	check(_has(lines, "examine as caixas A e B"), "Sem olhar todas as caixas, a Professora manda examinar antes")
	check(not modal.modal_panel.visible, "...e a pergunta não abre")
	_find("CaixaA").interact()
	await _read_all()
	_find("CaixaB").interact()
	lines = await _read_all()
	check(_has(lines, "Fale com a Professora"), "Depois das 3 caixas, manda falar com a Professora")

	_find("NPCProfessora").interact()
	await _read_all()
	check(modal.modal_panel.visible and modal.options_container.visible, "Pergunta das caixas abre")
	# image-16 (18/11): passando o mouse na opção o texto sumia (fonte branca no fundo claro)
	var legivel: bool = true
	for btn in modal.options_container.get_children():
		for estado in [["font_color", "normal"], ["font_hover_color", "hover"], ["font_pressed_color", "pressed"], ["font_focus_color", "focus"]]:
			var cor: Color = btn.get_theme_color(estado[0])
			var fundo: StyleBox = btn.get_theme_stylebox(estado[1])
			if fundo is StyleBoxFlat and absf(cor.get_luminance() - (fundo as StyleBoxFlat).bg_color.get_luminance()) < 0.4:
				legivel = false
	check(legivel, "Texto das opções legível em todos os estados (normal, mouse em cima, clicado, foco)")
	var texto_pergunta: String = modal.context_label.text + " " + " ".join(modal.options_container.get_children().map(func(b): return b.text))
	check(not texto_pergunta.contains("8 normais") and not texto_pergunta.contains("4 : 8") and not texto_pergunta.contains("10"), "A pergunta não mostra o que tem em cada caixa")
	modal._on_option_selected(1) # caixa B
	check(not modal.last_answer_correct, "Caixa B está errada")
	check_eq(GameManager.current_task_id, 7, "Errar não avança")
	modal._on_feedback_closed()
	# "Cadê a fase do gerador?" (18/11): o caminho até o gerador com a espera de entrada de verdade
	Fase1Flow.atraso_entrada = 1.2
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
	await tree().create_timer(1.5).timeout
	Fase1Flow.atraso_entrada = 0.0
	check(DialogueManager.is_active and GameManager.seen_events.has("t8_briefing"), "Na sala do gerador o Zelador explica o painel (com a espera de 1,2 s ligada)")

func _task8() -> void:
	var lines: Array = await _read_all()
	check(_has(lines, "exatamente 30 unidades"), "Mensagem do gerador: exatamente 30 unidades")
	check(_has(lines, "no máximo 3 alavancas"), "Zelador avisa: no máximo 3 alavancas ligadas")
	check(_has(lines, "Errou 3 vezes"), "Zelador avisa que o painel trava depois de 3 erros")
	var puzzle: Node = _find("GeradorPuzzle")
	if not check(puzzle != null, "Painel do gerador abre"):
		return
	check(DialogueManager.is_busy(), "Jogador fica travado com o painel aberto")
	var errors: Array[String] = puzzle.check_answer()
	check(errors[0].contains("faltam 22"), "Sem alavancas: 'faltam 22'")
	# Jogador clicando: a 4ª alavanca não liga
	for i in 4:
		puzzle.levers[i].button_pressed = true
	check_eq(puzzle.get_levers(), [true, true, true, false, false], "A 4ª alavanca não liga (máximo 3)")
	check(puzzle.feedback_label.text.contains("só aguenta 3"), "Painel avisa que só aguenta 3 alavancas")
	check(puzzle.charge_label.text.contains("?") and not puzzle.charge_label.text.contains("28"), "A carga não aparece antes de Verificar (tem que fazer a conta)")
	errors = puzzle.check_answer() # 8 + 6 + 5 + 9 = 28
	check(errors[0].contains("28") and puzzle.charge_label.text.contains("28"), "Depois de Verificar a carga medida (28) aparece")
	check(not puzzle.esta_travado(), "Com 2 erros o gerador ainda não travou")
	errors = puzzle.check_answer()
	check(puzzle.esta_travado(), "No 3º erro seguido o gerador trava para esfriar")
	check(puzzle.get_levers().all(func(v): return v == false), "Travou: as alavancas desligam")
	check(puzzle.levers[0].disabled and puzzle.check_button.disabled, "Travado: não dá para puxar alavanca nem verificar")
	puzzle.set_levers([true, false, true, false, true])
	check(not puzzle.check_answer().is_empty() and not puzzle.is_solved, "Travado: nem a resposta certa é aceita até esfriar")
	puzzle.destravar()
	check(not puzzle.levers[0].disabled, "Depois de esfriar dá para tentar de novo")
	puzzle.set_levers([true, false, true, false, true]) # √36 + 3² + √49
	errors = puzzle.check_answer()
	check(errors.is_empty() and puzzle.is_solved, "√36 + 3² + √49 = 22, com 8 dá 30: aceito")
	puzzle.close()
	await _frames(2)
	lines = await _read_all()
	check(_has(lines, "Até que é bom enxergar de novo"), "Zelador: 'Até que é bom enxergar de novo.'")
	check(not GameManager.lights_out and not _dark(), "As luzes voltam")
	check_eq(GameManager.current_task_id, 9, "Task 9 começa")

	# A antiga 2ª combinação (4 alavancas) não vale mais (testa num painel novo)
	var outro: Node = Fase2Flow.open_gerador_puzzle()
	outro.set_levers([true, true, false, true, true]) # √36 + √25 + 2² + √49
	check(not outro.check_answer().is_empty(), "√36 + √25 + 2² + √49 (4 alavancas) não é aceita")
	outro.solved.disconnect(Fase2Flow._on_gerador_solved)
	outro.close()
	await _frames(2)

func _task9() -> void:
	await _go(ALA, "SpawnFromGerador")
	var lines: Array = await _read_all()
	check(_has(lines, "Cantineira discutindo"), "Na Ala dá para ouvir a discussão no refeitório")
	await _go(REFEITORIO, "SpawnFromAla")
	lines = await _read_all()
	check(_has(lines, "4 turmas, cada uma com 28 alunos") and _has(lines, "2 turnos iguais"), "Cantineira explica: 4 turmas de 28 em 2 turnos (o total não é dado)")
	check(_has(lines, "Quer dizer... quase"), "Cantineira: 'Eu contei tudo direitinho! Quer dizer... quase.'")
	check_eq((_find("Interrogacao") as Label).text, "? lugares", "Antes da resposta a mesa final mostra '? lugares'")
	var modal: Node = _modal()
	check(modal.modal_panel.visible and modal.code_container.visible, "Pergunta das cadeiras abre")
	check(not modal.code_input.placeholder_text.contains("12") and not modal.question_label.text.contains("12"), "A resposta não aparece no texto de exemplo nem na pergunta")
	modal.code_input.text = "20"
	modal._on_code_submitted()
	check(not modal.last_answer_correct, "20 cadeiras está errado")
	modal._on_feedback_closed()
	modal.code_input.text = "68"
	modal._on_code_submitted()
	check(not modal.last_answer_correct and modal.feedback_text.text.contains("turnos"), "68 (esqueceu os turnos) dá a dica de dividir pelos turnos")
	check_eq(GameManager.current_task_id, 9, "Errar não avança")
	modal._on_feedback_closed()
	modal.code_input.text = "12"
	modal._on_code_submitted()
	check(modal.last_answer_correct, "12 cadeiras está certo")
	modal._on_feedback_closed()
	check_eq((_find("Interrogacao") as Label).text, "12 lugares", "Depois da resposta a mesa final mostra '12 lugares'")
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
	# 18/11: uma pergunta só (antes tinha a altura e depois o cartaz) e não abre direto
	var modal: Node = _modal()
	check(not modal.modal_panel.visible, "A pergunta não abre direto: primeiro olhar os cartazes")
	check(GameManager.current_objective.contains("cavaletes"), "Objetivo manda olhar os cartazes nos cavaletes")
	for letra in ["A", "B", "C"]:
		_find("Cartaz" + letra).interact()
		lines = await _read_all()
		check(_has(lines, "45 x "), "Cartaz %s mostra a medida com 45 de largura" % letra)
	for cav in _find("Cartazes").find_children("Cavalete", "Node2D", true, false):
		check_eq(cav.largura_cm, 45.0, "Cavalete %s desenhado com 45 de largura" % cav.letra)
	_find("NPCProfessorTask10").interact()
	await _read_all()
	check(modal.options_container.visible and not modal.code_container.visible, "Só uma pergunta: escolher o cartaz (sem digitar a altura)")
	check(not modal.title_label.text.contains("1/2") and not modal.title_label.text.contains("2/2"), "O título não fala em 2 passos")
	var opcoes: String = " ".join(modal.options_container.get_children().map(func(b): return b.text))
	check(not opcoes.contains("x"), "As opções não mostram as medidas (estão nos cavaletes)")
	modal._on_option_selected(1) # cartaz B (45x56)
	check(not modal.last_answer_correct, "Cartaz B (45 x 56) está errado")
	check(modal.feedback_text.text.contains("baixo demais"), "Dica: o B ficou baixo demais")
	check_eq(GameManager.current_task_id, 10, "Errar não conclui a tarefa")
	modal._on_feedback_closed()
	modal._on_option_selected(0) # cartaz A (45x64)
	check(modal.feedback_text.text.contains("alto demais"), "Dica: o A ficou alto demais")
	modal._on_feedback_closed()
	modal._on_option_selected(2) # cartaz C (45x60)
	check(modal.last_answer_correct, "Cartaz C (45 x 60) está certo")
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
	# Desde que a Fase 3 existe, o fim da Fase 2 leva direto para ela (tela preta o tempo todo)
	check_eq(GameManager.current_task_id, 11, "A Fase 3 começa na Tarefa 11")
	check_eq(scene().get("location_id"), "gabinete", "A Fase 3 começa no gabinete")
	check(_hud_text().contains("Fase 3"), "HUD mostra a Fase 3")
	var chamado: Array = await _read_all()
	check(_has(chamado, "problema muito sério na cantina"), "Um aluno chama o diretor para a cantina")
	await _wait_transition()
	await _read_all()
