extends "res://tests/test_base.gd"

# TESTE 7 — Jogada completa da Fase 3 e do Encerramento (integração)
# Começa no primeiro dia do 3º trimestre e joga as Tasks 11 a 15 nas cenas reais:
# segue o aluno até a cantina, vai ao pátio, apaga/acende a Sala de Matemática,
# monta a foto no Portão, decora o pátio e assiste ao final do jogo. Em cada desafio
# erra primeiro (com a resposta errada mais comum) e confere a dica específica.

const GABINETE: String = "res://scenes/intro/intro_scene.tscn"
const CORREDOR: String = "res://scenes/school/school_corridor.tscn"
const REFEITORIO: String = "res://scenes/school/refeitorio_scene.tscn"
const PATIO: String = "res://scenes/school/patio_scene.tscn"
const MATEMATICA: String = "res://scenes/school/math_classroom.tscn"
const PORTAO: String = "res://scenes/school/portao_scene.tscn"

func _init() -> void:
	suite_name = "Teste 7 — Jogada completa da Fase 3 e Encerramento"
	suite_description = "Simula um jogador fazendo as Tasks 11 a 15 nas cenas reais, errando e acertando cada desafio, e confere o final do jogo."

func get_cases() -> Array:
	return [
		["T7.1 Começo da Fase 3: o aluno leva o diretor à cantina", _inicio],
		["T7.2 Task 11: máquina de refrigerante em 2 passos (erro e acerto)", _task11],
		["T7.3 Task 12: gincana no pátio (erro e acerto)", _task12],
		["T7.4 Task 13: sala escura e interruptores em 2 passos", _task13],
		["T7.5 Task 14: foto oficial no Portão (erros e acerto)", _task14],
		["T7.6 Task 15: decoração do pátio e fim da Fase 3", _task15],
		["T7.7 Encerramento do jogo", _final],
	]

# ---------------- Utilitários (iguais aos do Teste 5) ----------------

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

func _type(modal: Node, answer: String) -> void:
	modal.code_input.text = answer
	modal._on_code_submitted()

func _feedback(modal: Node) -> String:
	return modal.feedback_text.text

# ---------------- Casos ----------------

func _inicio() -> void:
	GameManager.jump_to_phase(3)
	GameManager.set_player_info("Caio Teste", "M", 6)
	Fase3Flow.start_phase(false)
	await _wait_transition()
	check_eq(scene().get("location_id"), "gabinete", "Fase 3 começa no gabinete")
	check(_hud_text().contains("Fase 3 · Tarefa 11: A Máquina de Refrigerante"), "HUD mostra 'Fase 3 · Tarefa 11'")
	check(_find("AlunoChamado").visible, "Um aluno está no gabinete")
	var lines: Array = await _read_all()
	check(_has(lines, "DIRETOR! Temos um problema muito sério na cantina"), "Aluno: 'DIRETOR! Temos um problema muito sério na cantina'")
	await _wait_transition()
	check_eq(scene().get("location_id"), "refeitorio", "Os dois vão até o Refeitório")
	lines = await _read_all()
	check(_has(lines, "Uma máquina de refrigerante... sério?"), "Diretor: 'Uma máquina de refrigerante... sério?'")
	check(_has(lines, "Eu tentei fazer uma regra de três"), "Aluno tentou regra de três")
	check(GameManager.current_objective.contains("visor"), "Objetivo manda olhar o visor da máquina")
	check(_find("NPCCoordenadora").visible and _find("AlunoRefri").visible, "Coordenadora e aluno estão no Refeitório")

func _task11() -> void:
	var modal: Node = _modal()
	_find("MaquinaRefri").interact()
	var lines: Array = await _read_all()
	check(_has(lines, "2 refrigerantes = R$ 9") and _has(lines, "4 refrigerantes = R$ 15"), "O visor mostra os registros 2 = R$ 9 e 4 = R$ 15")
	check(modal.modal_panel.visible and modal.title_label.text.contains("1/2"), "Passo 1: qual é a regra da máquina")
	modal._on_option_selected(0) # regra de três
	check(not modal.last_answer_correct and _feedback(modal).contains("R$ 18"), "Regra de três está errada e a dica mostra que 4 custariam R$ 18")
	modal._on_feedback_closed()
	modal._on_option_selected(1)
	check(modal.last_answer_correct, "y = 3x + 3 está certa")
	modal._on_feedback_closed()
	lines = await _read_all()
	check(_has(lines, "E quanto ficam 6?"), "Cantineira pergunta o preço de 6")
	check(modal.modal_panel.visible and modal.title_label.text.contains("2/2"), "Passo 2: preço de 6 refrigerantes")
	check(not modal.context_label.text.contains("21") and not modal.question_label.text.contains("21"), "A pergunta não mostra a resposta")
	_type(modal, "18")
	check(not modal.last_answer_correct and _feedback(modal).contains("R$ 3 fixos"), "18 está errado e a dica lembra dos R$ 3 fixos")
	modal._on_feedback_closed()
	check(GameManager.current_task_id == 11, "Errar não avança a tarefa")
	_type(modal, "21")
	check(modal.last_answer_correct, "R$ 21 está certo")
	modal._on_feedback_closed()
	lines = await _read_all()
	check(_has(lines, "eu estava sem função"), "Aluno: '...eu estava sem função.'")
	check(GameManager.is_task_completed(11), "Task 11 concluída")
	check_eq(GameManager.current_task_id, 12, "Task 12 começa")
	check(GameManager.current_objective.contains("gabinete"), "Objetivo manda voltar ao gabinete")

func _task12() -> void:
	await _go(GABINETE, "SpawnFromCorridor")
	check(_find("NPCCoordenadora").visible, "A Coordenadora está no gabinete")
	check(not _find("AlunoChamado").visible, "O aluno da cantina não está mais no gabinete")
	var lines: Array = await _read_all()
	check(_has(lines, "os alunos terão uma gincana"), "Coordenadora fala da gincana")
	await _wait_transition()
	check_eq(scene().get("location_id"), "patio", "Os dois vão até o pátio")
	lines = await _read_all()
	check(_has(lines, "Essa equipe tá roubada!") and _has(lines, "Se trocasse uma pessoa"), "Alunos reclamam das equipes")
	var reps: int = 0
	for n in ["RepAna", "RepBruno", "RepCaio", "RepDuda", "RepEnzo", "RepFê"]:
		if _find(n) and _find(n).visible:
			reps += 1
	check_eq(reps, 6, "Os 6 representantes estão no pátio")
	_find("QuadroGincana").interact()
	lines = await _read_all()
	check(_has(lines, "Ana, Bruno, Caio, Duda, Enzo, Fê"), "O quadro mostra os 6 nomes")
	var modal: Node = _modal()
	_find("NPCCoordenadora").interact()
	await _read_all()
	check(modal.modal_panel.visible and modal.code_container.visible, "Pergunta das equipes abre")
	check(not modal.context_label.text.contains("20"), "A pergunta não mostra a resposta")
	_type(modal, "120")
	check(not modal.last_answer_correct and _feedback(modal).contains("ORDEM"), "120 está errado e a dica explica que a ordem não importa")
	modal._on_feedback_closed()
	_type(modal, "20")
	check(modal.last_answer_correct, "20 equipes está certo")
	modal._on_feedback_closed()
	lines = await _read_all()
	check(_has(lines, "o sorteio parece menos suspeito"), "Aluno: '...o sorteio parece menos suspeito agora.'")
	check_eq(GameManager.current_task_id, 13, "Task 13 começa")
	check(GameManager.is_room_dark("matematica"), "A Sala de Matemática fica escura")
	check(not _dark(), "O pátio continua claro")
	# Volta ao corredor andando pela porta do pátio (física de verdade)
	await tree().create_timer(0.6).timeout
	_find("Player").global_position = _find("DoorToCorridor").global_position + Vector2(0, -12)
	await _physics_frames(6)
	await _wait_transition()
	check_eq(scene().get("location_id"), "corredor", "A porta do pátio leva ao corredor")

func _task13() -> void:
	var lines: Array = await _read_all()
	check(_has(lines, "foram divididas entre dois interruptores"), "Coordenadora explica os dois interruptores")
	check(_has(lines, "4 lâmpadas a mais"), "Aluno: o segundo controla 4 lâmpadas a mais")
	check(_find("NPCCoordenadoraTask13").visible and _find("AlunoLuzes").visible, "Coordenadora e aluno estão perto da Sala de Matemática")
	await _go(MATEMATICA, "SpawnFromCorridor")
	check(_dark(), "A Sala de Matemática está escura")
	lines = await _read_all()
	check(_has(lines, "Está tudo escuro"), "Ao entrar, avisa que está escuro")
	check(not _find("NPCProfessor").visible, "O professor não está na sala escura")
	await _go(CORREDOR, "SpawnFromMath")
	check(not _dark(), "O corredor tem luz")
	var modal: Node = _modal()
	_find("Interruptores").interact()
	await _frames(2)
	check(modal.modal_panel.visible and modal.title_label.text.contains("1/2"), "Passo 1: qual é a equação")
	modal._on_option_selected(0)
	check(not modal.last_answer_correct and _feedback(modal).contains("só contou o interruptor B"), "x + 4 = 20 está errada, com dica")
	modal._on_feedback_closed()
	modal._on_option_selected(1)
	check(modal.last_answer_correct, "x + (x + 4) = 20 está certa")
	modal._on_feedback_closed()
	await _read_all()
	check(modal.modal_panel.visible and modal.title_label.text.contains("2/2"), "Passo 2: lâmpadas do interruptor A")
	_type(modal, "12")
	check(not modal.last_answer_correct and _feedback(modal).contains("é o interruptor B"), "12 está errado (é o B), com dica")
	modal._on_feedback_closed()
	_type(modal, "8")
	check(modal.last_answer_correct, "A = 8 está certo")
	modal._on_feedback_closed()
	lines = await _read_all()
	check(_has(lines, "quem trocou os interruptores de lugar"), "Aluno: 'Agora só falta descobrir quem trocou os interruptores de lugar.'")
	check(not GameManager.is_room_dark("matematica"), "A Sala de Matemática acende")
	check_eq(GameManager.current_task_id, 14, "Task 14 começa")
	await _go(MATEMATICA, "SpawnFromCorridor")
	check(not _dark(), "A Sala de Matemática está clara de novo")

func _task14() -> void:
	await _go(PORTAO, "SpawnFromCorridor")
	var lines: Array = await _read_all()
	check(_has(lines, "temos 5 professores disponíveis"), "Coordenadora: 5 professores, só 3 na foto")
	check(_find("MarcaFrente").visible and _find("MarcaTrasEsq").visible, "Os lugares da foto estão marcados no chão")
	var profs: int = 0
	for n in ["ProfFotoMat", "ProfFoto1", "ProfFoto2", "ProfFoto3", "ProfFoto4"]:
		if _find(n) and _find(n).visible:
			profs += 1
	check_eq(profs, 5, "Os 5 professores estão no Portão")
	var modal: Node = _modal()
	_find("CameraFoto").interact()
	await _frames(2)
	check(modal.modal_panel.visible, "A câmera abre a pergunta da foto")
	check(not modal.context_label.text.contains("30"), "A pergunta não mostra a resposta")
	_type(modal, "60")
	check(not modal.last_answer_correct and _feedback(modal).contains("MESMA foto"), "60 está errado: trocar os dois de trás dá a mesma foto")
	modal._on_feedback_closed()
	_type(modal, "10")
	check(not modal.last_answer_correct and _feedback(modal).contains("só QUEM"), "10 está errado: quem fica na frente muda a foto")
	modal._on_feedback_closed()
	_type(modal, "30")
	check(modal.last_answer_correct, "30 fotos está certo")
	modal._on_feedback_closed()
	lines = await _read_all()
	check(_has(lines, "vamos arrebentar nessa feira"), "Coordenadora: 'Tenho certeza que vamos arrebentar nessa feira.'")
	check_eq(GameManager.current_task_id, 15, "Task 15 começa")

func _task15() -> void:
	await _go(PATIO, "SpawnFromCorridor")
	var lines: Array = await _read_all()
	check(_has(lines, "Temos 6 placas diferentes"), "Professor: 6 placas, só 3 no mural")
	check(_has(lines, "A posição de cada uma também muda o resultado"), "Zelador: a posição muda o resultado")
	check(_find("NPCProfessor").visible and _find("NPCZelador").visible and _find("NPCCoordenadora").visible, "Coordenadora, Professor e Zelador estão no pátio")
	check(not _find("RepAna").visible, "Os representantes da gincana não estão mais no pátio")
	var modal: Node = _modal()
	_find("MuralPlacas").interact()
	await _frames(2)
	check(modal.modal_panel.visible, "O mural abre a pergunta")
	_type(modal, "20")
	check(not modal.last_answer_correct and _feedback(modal).contains("a ordem importa"), "20 está errado: a ordem importa")
	modal._on_feedback_closed()
	_type(modal, "120")
	check(modal.last_answer_correct, "120 organizações está certo")
	modal._on_feedback_closed()
	lines = await _read_all()
	check(_has(lines, "Eu falei que era melhor não fazer isso"), "Zelador: 'Eu falei que era melhor não fazer isso.'")
	await _frames(2)
	var guard: int = 0
	while not Transition.caption_box.visible and guard < 300:
		guard += 1
		await _frames(1)
	check_eq(Transition.title_label.text, "Fim da Fase 3", "Cartão 'Fim da Fase 3'")
	await _wait_transition()
	for t in range(11, 16):
		check(GameManager.is_task_completed(t), "Task %d concluída" % t)

func _final() -> void:
	check_eq(scene().get("location_id"), "gabinete", "O final acontece no gabinete")
	var lines: Array = await _read_all()
	check(_has(lines, "Já acabaram os 3 trimestres?"), "Diretor: 'Já acabaram os 3 trimestres?'")
	check(_has(lines, "Seu contrato era temporário"), "Coordenadora: o contrato acaba hoje")
	check(_has(lines, "Você ainda me deve um refrigerante"), "Cantineira: 'Você ainda me deve um refrigerante.'")
	check(_has(lines, "ninguém perdeu documento"), "Secretária fala")
	check(_has(lines, "Sobreviveu mais tempo que o diretor anterior"), "Professor fala")
	check(_has(lines, "Nos vemos por aí, diretor"), "Coordenadora: 'Nos vemos por aí, diretor.'")
	var visiveis: int = 0
	for n in ["FinalCantineira", "FinalSecretaria", "FinalAluno", "FinalZelador", "FinalProfessor", "NPCCoordenadoraFinal"]:
		if _find(n) and _find(n).visible:
			visiveis += 1
	check_eq(visiveis, 6, "Servidores, aluno e Coordenadora aparecem na porta do gabinete")
	var titulos: Array = []
	var guard: int = 0
	while guard < 3000 and (Transition.is_transitioning or titulos.is_empty()):
		guard += 1
		if Transition.caption_box.visible and not titulos.has(Transition.title_label.text):
			titulos.append(Transition.title_label.text)
		await tree().process_frame
	await _frames(4)
	check_eq(titulos, ["Obrigado por cuidar da Escola Pitagórica.", "Talvez alguns problemas tenham sido resolvidos.", "Talvez outros tenham acabado de começar.", "Fim."], "Mensagem final do roteiro, na ordem")
	check(GameManager.game_finished, "Jogo marcado como concluído")
	check(_hud_text().contains("Jogo concluído!"), "HUD mostra 'Jogo concluído!'")
	check(not DialogueManager.is_active, "O final não recomeça ao voltar para o gabinete")
	check(not _find("FinalCantineira").visible, "Depois do fim, os servidores foram embora")
	_find("NPCCoordenadoraFinal").interact()
	lines = await _read_all()
	check(_has(lines, "Vá descansar"), "Falar com a Coordenadora depois do fim")
