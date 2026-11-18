extends Node

# Autoload: Fase3Flow
# Roteiro jogável da Fase 3 — Funções, Combinatória e Raciocínio Algébrico (Tasks 11 a 15)
# e o Encerramento do jogo (seção 6 do roteiro).
# Mesmo modelo das outras fases: as salas e os NPCs chamam o Fase1Flow, que repassa para
# cá quando GameManager.current_phase >= 3 (ver Fase1Flow._flow()).
# O que não é da Fase 3 (falas soltas, objetos das fases anteriores) volta para o Fase2Flow.
# Falas: data/dialogues/fase3_dialogues.gd | Desafios: data/puzzles/fase3_puzzles.gd

signal puzzle_opened(puzzle: Node)
signal phase_finished()
signal game_finished()

const SCENE_GABINETE: String = "res://scenes/intro/intro_scene.tscn"
const SCENE_REFEITORIO: String = "res://scenes/school/refeitorio_scene.tscn"
const SCENE_PATIO: String = "res://scenes/school/patio_scene.tscn"
const CHALLENGE_MODAL: PackedScene = preload("res://scenes/ui/challenge_modal.tscn")

var current_location: String = ""

# ------------------------------------------------------------------
# Começo da fase (chamado pelo Fase2Flow depois da Task 10)
# ------------------------------------------------------------------

# Tudo com a tela preta, igual à virada da Fase 1 para a 2.
func start_phase(com_fim_fase2: bool = true) -> void:
	var cards: Array = []
	if com_fim_fase2:
		cards.append(["Fim da Fase 2", "%s concluída!\nA feira foi um sucesso e o 2º trimestre acabou." % GameManager.PHASE_NAMES[2], 3.5])
	cards.append(["Fase 3", GameManager.PHASE_NAMES[3], 2.5])
	cards.append(["Primeiro dia do 3º trimestre...", "", 1.5])
	await Transition.change_scene_with_cards(SCENE_GABINETE, "SpawnDesk", cards, func():
		GameManager.current_phase = 3
		GameManager.set_lights_out(false)
		GameManager.start_task(11)
	)

# Estado que depende da tarefa (vale também quando a fase começa por um atalho de teste)
func sync_task_state() -> void:
	var task: int = GameManager.current_task_id
	GameManager.set_room_dark("matematica", task == 13 and not GameManager.is_task_completed(13))
	# Marcas dos lugares da foto no chão do Portão: só no dia da foto
	var scene: Node = get_tree().current_scene
	if scene and current_location == "portao":
		for marca in ["MarcaTrasEsq", "MarcaTrasDir", "MarcaFrente"]:
			var n: CanvasItem = scene.find_child(marca, true, false) as CanvasItem
			if n:
				n.visible = task == 14

# ------------------------------------------------------------------
# Entrada nas salas (eventos automáticos)
# ------------------------------------------------------------------

func on_room_ready(location: String) -> void:
	current_location = location
	sync_task_state()
	if Transition.is_transitioning:
		await Transition.transition_finished
	if current_location != location or DialogueManager.is_busy():
		return

	var task: int = GameManager.current_task_id
	match location:
		"gabinete":
			if task == 11 and GameManager.mark_event("t11_chamado"):
				_task11_chamado()
			elif task == 12 and GameManager.mark_event("t12_gabinete"):
				_task12_gabinete()
			elif GameManager.current_phase > GameManager.LAST_PHASE and GameManager.mark_event("final"):
				_start_ending()
		"refeitorio":
			if task == 11 and GameManager.mark_event("t11_briefing"):
				DialogueManager.start_dialogue(Fase3Dialogues.task11_briefing(), func():
					GameManager.set_objective("Olhe o visor da máquina de refrigerante (com \"!\") e descubra quanto custam 6 refrigerantes.")
				)
		"patio":
			if task == 12 and GameManager.mark_event("t12_briefing"):
				GameManager.mark_event("t12_gabinete")
				DialogueManager.start_dialogue(Fase3Dialogues.task12_briefing(), func():
					GameManager.set_objective("Leia o quadro da gincana e diga à Coordenadora quantas equipes de 3 dá para formar.")
				)
			elif task == 15 and GameManager.mark_event("t15_briefing"):
				DialogueManager.start_dialogue(Fase3Dialogues.task15_briefing(), func():
					GameManager.set_objective("Veja as 6 placas e o mural e diga quantas organizações diferentes de 3 placas existem.")
				)
		"corredor":
			if task == 13 and GameManager.mark_event("t13_briefing"):
				DialogueManager.start_dialogue(Fase3Dialogues.task13_briefing(), func():
					GameManager.set_objective("Use o painel de interruptores (com \"!\") ao lado da porta da Sala de Matemática.")
				)
		"matematica":
			if task == 13 and GameManager.mark_event("t13_sala_escura"):
				_say("", "(Está tudo escuro aqui dentro. Melhor resolver os interruptores no painel do corredor.)")
		"portao":
			if task == 14 and GameManager.mark_event("t14_briefing"):
				DialogueManager.start_dialogue(Fase3Dialogues.task14_briefing(), func():
					GameManager.set_objective("Use a câmera (com \"!\") e diga de quantas formas dá para montar a foto.")
				)

# ------------------------------------------------------------------
# NPCs
# ------------------------------------------------------------------

func on_coordenadora_interact() -> void:
	var task: int = GameManager.current_task_id
	match task:
		11:
			if current_location == "refeitorio":
				DialogueManager.start_dialogue(Fase3Dialogues.task11_reminder())
				return
		12:
			if current_location == "gabinete":
				GameManager.mark_event("t12_gabinete")
				_task12_gabinete()
				return
			if current_location == "patio":
				DialogueManager.start_dialogue(Fase3Dialogues.task12_reminder(), open_gincana)
				return
		13:
			if current_location == "corredor":
				DialogueManager.start_dialogue(Fase3Dialogues.task13_reminder(), open_luzes)
				return
		14:
			if current_location == "portao":
				DialogueManager.start_dialogue(Fase3Dialogues.task14_reminder(), open_foto)
				return
		15:
			if current_location == "patio":
				DialogueManager.start_dialogue(Fase3Dialogues.task15_reminder(), open_mural)
				return
		0:
			DialogueManager.start_dialogue(Fase3Dialogues.depois_do_fim())
			return
	_say("Coordenadora", Fase3Dialogues.hint_for_task(task))

func on_zelador_interact() -> void:
	if GameManager.current_task_id == 15 and current_location == "patio":
		DialogueManager.start_dialogue([{"speaker": "Zelador", "text": "A posição de cada placa muda o resultado. Não é só escolher, é organizar."}], open_mural)
	else:
		DialogueManager.start_dialogue(Fase1Dialogues.zelador_idle())

func on_professor_interact() -> void:
	var task: int = GameManager.current_task_id
	if task == 15 and current_location == "patio":
		DialogueManager.start_dialogue(Fase3Dialogues.task15_reminder(), open_mural)
	elif task == 14 and current_location == "portao":
		_say("Professor de Matemática", Fase3Dialogues.FALAS_PROFESSORES.pick_random())
	else:
		DialogueManager.start_dialogue(Fase1Dialogues.professor_idle())

# NPCs genéricos (npc_aluno.gd com flow_id). Retorna true se a história usou a conversa.
func on_npc_event(flow_id: String, npc: Node = null) -> bool:
	var task: int = GameManager.current_task_id
	var speaker: String = str(npc.get("npc_name")) if npc else "Aluno"
	match flow_id:
		"aluno_chamado":
			if task == 11:
				_task11_chamado()
				return true
		"aluno_refri":
			if task == 11:
				_say(speaker, "Eu tentei regra de três... 2 custam 9, então 4 deveriam custar 18. Mas ela cobrou 15!")
				return true
		"cantineira":
			if task == 11 and current_location == "refeitorio":
				_say(speaker, "Os preços que ela já cobrou estão no visor. Eu só quero saber quanto cobrar por 6!")
				return true
		"gincana":
			_say(speaker, Fase3Dialogues.FALAS_GINCANA.pick_random())
			return true
		"professor_foto":
			if task == 14:
				_say(speaker, Fase3Dialogues.FALAS_PROFESSORES.pick_random())
				return true
		"aluno_luzes":
			if task == 13:
				_say(speaker, "O B controla 4 lâmpadas a mais que o A. Juntos são 20. Foi o que a professora disse!")
				return true
	return Fase2Flow.on_npc_event(flow_id, npc)

# ------------------------------------------------------------------
# Objetos do cenário (interactable_object.gd com flow_event)
# ------------------------------------------------------------------

func on_object_event(event_id: String, source: Node = null) -> void:
	var task: int = GameManager.current_task_id
	match event_id:
		"maquina_refri":
			if task == 11:
				DialogueManager.start_dialogue([{"speaker": "Visor da máquina", "text": Fase3Puzzles.maquina_registros_texto().replace("\n", "   |   ") + "   |   %d refrigerantes = R$ ???" % Fase3Puzzles.MAQUINA_PERGUNTA}], open_maquina)
			elif GameManager.is_task_completed(11):
				_say("Máquina de refrigerante", "Preço configurado: y = 3x + 3. 6 refrigerantes = R$ %d." % Fase3Puzzles.maquina_preco(6))
			else:
				_say("Máquina de refrigerante", "Uma máquina de refrigerante novinha. Ainda está sem preço.")
		"quadro_gincana":
			_say("Quadro da gincana", "Representantes: %s.\nFinal: equipes de %d alunos." % [", ".join(Fase3Puzzles.GINCANA_REPRESENTANTES), Fase3Puzzles.GINCANA_EQUIPE])
		"interruptores":
			if task == 13:
				open_luzes()
			else:
				_say("Interruptores", "Interruptor A: 8 lâmpadas. Interruptor B: 12 lâmpadas.")
		"camera_foto":
			if task == 14:
				open_foto()
			elif GameManager.is_task_completed(14):
				_say("Câmera", "A foto oficial já foi tirada. Todo mundo saiu sorrindo (quase todo mundo).")
			else:
				_say("Câmera", "Uma câmera num tripé.")
		"placas":
			_say("Placas", "6 placas: %s." % ", ".join(Fase3Puzzles.PLACAS))
		"mural_placas":
			if task == 15:
				open_mural()
			else:
				_say("Mural", "Um mural com 3 espaços para placas.")
		"calendario":
			if GameManager.current_phase > GameManager.LAST_PHASE:
				_say("Calendário", "Os 3 trimestres acabaram. O tempo passou rápido...")
			else:
				_say("Calendário", "Terceiro trimestre: gincana, feira educacional e a despedida dos alunos.")
		_:
			Fase2Flow.on_object_event(event_id, source)

# ------------------------------------------------------------------
# Task 11 — A Máquina de Refrigerante (2 passos: a regra e depois o preço)
# ------------------------------------------------------------------

func _task11_chamado() -> void:
	DialogueManager.start_dialogue(Fase3Dialogues.task11_chamado(), func():
		Transition.change_scene(SCENE_REFEITORIO, "SpawnFromAla", "Vocês correm até o Refeitório...")
	)

func open_maquina() -> Node:
	if GameManager.seen_events.has("t11_regra"):
		return open_maquina_preco()
	var modal: Node = _get_challenge_modal()
	var options: Array[String] = []
	for r in Fase3Puzzles.MAQUINA_REGRAS:
		options.append(str(r["texto"]))
	modal.show_multiple_choice_challenge(
		0, # passo intermediário
		"Tarefa 11: A Máquina de Refrigerante (1/2)",
		"Visor da máquina:\n" + Fase3Puzzles.maquina_registros_texto(),
		"Qual regra (função) a máquina usa para cobrar x refrigerantes?",
		options,
		Fase3Puzzles.MAQUINA_REGRA_CERTA,
		"Isso! Teste nos registros: 3 × 2 + 3 = 9 e 3 × 4 + 3 = 15. A máquina cobra R$ 3 por refrigerante, mais R$ 3 fixos.",
		"Essa regra não bate com os registros. Teste: coloque x = 2 e veja se dá R$ 9; depois x = 4 e veja se dá R$ 15.",
		func():
			GameManager.mark_event("t11_regra")
			DialogueManager.start_dialogue(Fase3Dialogues.task11_regra_ok(), open_maquina_preco)
	)
	modal.wrong_hints = {
		0: "Com regra de três, R$ 4,50 cada, 4 refrigerantes custariam R$ 18. Mas a máquina cobrou R$ 15! Ela não é proporcional.",
		2: "Teste nos registros: 2 × 2 + 5 = 9 (certo!), mas 2 × 4 + 5 = 13, e a máquina cobrou R$ 15. A regra tem que bater com os dois.",
	}
	puzzle_opened.emit(modal)
	return modal

func open_maquina_preco() -> Node:
	var modal: Node = _get_challenge_modal()
	modal.show_code_challenge(
		11,
		"Tarefa 11: A Máquina de Refrigerante (2/2)",
		"Regra da máquina: y = 3x + 3  (x = quantidade de refrigerantes, y = preço em R$)",
		"Quanto custam %d refrigerantes? (digite só o número, em reais)" % Fase3Puzzles.MAQUINA_PERGUNTA,
		str(Fase3Puzzles.maquina_preco(Fase3Puzzles.MAQUINA_PERGUNTA)),
		"Isso! y = 3 × 6 + 3 = 18 + 3 = R$ 21.",
		"Não é esse o preço. Troque x por 6 na regra y = 3x + 3.",
		func(): DialogueManager.start_dialogue(Fase3Dialogues.task11_done())
	)
	modal.wrong_hints = {
		"18": "Quase! 3 × 6 = 18 é só a parte que depende da quantidade. Não esqueça os R$ 3 fixos.",
		"27": "Isso seria regra de três (R$ 4,50 cada). A máquina segue y = 3x + 3.",
	}
	modal.code_input.placeholder_text = "Preço em R$"
	puzzle_opened.emit(modal)
	return modal

# ------------------------------------------------------------------
# Task 12 — As Equipes da Gincana
# ------------------------------------------------------------------

func _task12_gabinete() -> void:
	DialogueManager.start_dialogue(Fase3Dialogues.task12_gabinete(), func():
		Transition.change_scene(SCENE_PATIO, "SpawnFromCorridor", "Vocês vão até o pátio...")
	)

func open_gincana() -> Node:
	var modal: Node = _get_challenge_modal()
	modal.show_code_challenge(
		12,
		"Tarefa 12: As Equipes da Gincana",
		"Representantes: %s (6 alunos).\nSó 3 vão para a final. A ordem não importa: Ana, Bruno e Caio é a mesma equipe que Caio, Bruno e Ana." % ", ".join(Fase3Puzzles.GINCANA_REPRESENTANTES),
		"Quantas equipes diferentes de 3 alunos podem ser formadas?",
		str(Fase3Puzzles.gincana_resposta()),
		"Isso! Escolhendo em ordem seriam 6 × 5 × 4 = 120, mas cada equipe aparece 3 × 2 × 1 = 6 vezes (só muda a ordem). 120 ÷ 6 = 20 equipes. É a combinação C(6, 3).",
		"Não é esse número. Tente listar as equipes começando pela Ana (Ana-Bruno-Caio, Ana-Bruno-Duda...) e lembre que a ordem não importa.",
		func(): DialogueManager.start_dialogue(Fase3Dialogues.task12_done(), sync_task_state)
	)
	modal.wrong_hints = Fase3Puzzles.gincana_dicas()
	modal.code_input.placeholder_text = "Número de equipes"
	puzzle_opened.emit(modal)
	return modal

# ------------------------------------------------------------------
# Task 13 — As Luzes do Corredor (2 passos: a equação e depois o x)
# ------------------------------------------------------------------

func open_luzes() -> Node:
	if GameManager.seen_events.has("t13_equacao"):
		return open_luzes_resposta()
	var modal: Node = _get_challenge_modal()
	modal.show_multiple_choice_challenge(
		0,
		"Tarefa 13: As Luzes do Corredor (1/2)",
		"O interruptor A controla x lâmpadas.\nO interruptor B controla 4 lâmpadas a mais que o A.\nJuntos, eles controlam 20 lâmpadas.",
		"Qual equação representa o problema?",
		Fase3Puzzles.LUZES_EQUACOES,
		Fase3Puzzles.LUZES_EQUACAO_CERTA,
		"Isso! A tem x lâmpadas, B tem x + 4, e os dois juntos: x + (x + 4) = 20.",
		"Essa equação não representa os dois interruptores juntos.",
		func():
			GameManager.mark_event("t13_equacao")
			DialogueManager.start_dialogue(Fase3Dialogues.task13_equacao_ok(), open_luzes_resposta)
	)
	modal.wrong_hints = {
		0: "Assim você só contou o interruptor B (x + 4). O A também acende lâmpadas: os DOIS juntos dão 20.",
		2: "Quase: os 4 a mais são de um interruptor só (o B). Some A (x) com B (x + 4) e iguale a 20.",
	}
	puzzle_opened.emit(modal)
	return modal

func open_luzes_resposta() -> Node:
	var modal: Node = _get_challenge_modal()
	modal.show_code_challenge(
		13,
		"Tarefa 13: As Luzes do Corredor (2/2)",
		"x + (x + 4) = 20",
		"Quantas lâmpadas o interruptor A controla? (digite só o número)",
		str(Fase3Puzzles.luzes_a()),
		"Isso! x + x + 4 = 20 → 2x + 4 = 20 → 2x = 16 → x = 8. O interruptor A controla 8 lâmpadas e o B, 8 + 4 = 12. Conferindo: 8 + 12 = 20.",
		"Não fecha. Junte os x (x + x = 2x), tire o 4 dos dois lados e depois divida por 2.",
		func():
			sync_task_state()
			DialogueManager.start_dialogue(Fase3Dialogues.task13_done())
	)
	modal.wrong_hints = {
		"12": "12 é o interruptor B! O A controla 4 lâmpadas a menos que o B.",
		"10": "Se os dois fossem iguais, seria 10 para cada. Mas o B tem 4 a mais: 2x + 4 = 20.",
		"16": "16 é o 2x (20 − 4). Ainda falta dividir por 2.",
	}
	modal.code_input.placeholder_text = "Lâmpadas do A"
	puzzle_opened.emit(modal)
	return modal

# ------------------------------------------------------------------
# Task 14 — O Lugar da Foto Oficial
# ------------------------------------------------------------------

func open_foto() -> Node:
	var modal: Node = _get_challenge_modal()
	modal.show_code_challenge(
		14,
		"Tarefa 14: O Lugar da Foto Oficial",
		"5 professores disponíveis: %s.\nLugares marcados no chão: %s.\nNa fila de trás, trocar os dois de lado dá a MESMA foto." % [", ".join(Fase3Puzzles.FOTO_PROFESSORES), "; ".join(Fase3Puzzles.FOTO_LUGARES).to_lower()],
		"De quantas formas diferentes dá para montar a foto?",
		str(Fase3Puzzles.foto_resposta()),
		"Isso! Na frente podem ir 5 professores. Com os 4 que sobram dá para formar 6 duplas para a fila de trás (a ordem não importa): 5 × 6 = 30 fotos diferentes.",
		"Não é esse número. Pense em duas partes: quem pode ir na frente, e quantas duplas diferentes dá para formar com quem sobrou?",
		func(): DialogueManager.start_dialogue(Fase3Dialogues.task14_done())
	)
	modal.wrong_hints = Fase3Puzzles.foto_dicas()
	modal.code_input.placeholder_text = "Número de formações"
	puzzle_opened.emit(modal)
	return modal

# ------------------------------------------------------------------
# Task 15 — A Decoração do Pátio
# ------------------------------------------------------------------

func open_mural() -> Node:
	var modal: Node = _get_challenge_modal()
	modal.show_code_challenge(
		0, # a tarefa só termina depois das falas finais (aí vem o encerramento)
		"Tarefa 15: A Decoração do Pátio",
		"6 placas diferentes: %s.\nO mural tem 3 posições, e a ordem das placas importa." % ", ".join(Fase3Puzzles.PLACAS),
		"Quantas organizações diferentes de 3 placas podem ser feitas no mural?",
		str(Fase3Puzzles.mural_resposta()),
		"Isso! Na 1ª posição podem ir 6 placas, na 2ª sobram 5 e na 3ª sobram 4: 6 × 5 × 4 = 120 organizações.",
		"Não é esse número. Pense posição por posição: quantas placas podem ir em cada uma, sem repetir?",
		func(): DialogueManager.start_dialogue(Fase3Dialogues.task15_done(), _finish_phase)
	)
	modal.wrong_hints = Fase3Puzzles.mural_dicas()
	modal.code_input.placeholder_text = "Número de organizações"
	puzzle_opened.emit(modal)
	return modal

func _finish_phase() -> void:
	GameManager.complete_task(15)
	phase_finished.emit()
	await Transition.change_scene_with_cards(SCENE_GABINETE, "SpawnDesk", [
		["Fim da Fase 3", "%s concluída!\nO 3º trimestre acabou." % GameManager.PHASE_NAMES[3], 3.5],
		["No fim do dia...", "", 1.5],
	])

# ------------------------------------------------------------------
# Encerramento (seção 6 do roteiro)
# ------------------------------------------------------------------

func _start_ending() -> void:
	var parte1: Array = Fase3Dialogues.final_parte1()
	var batida: int = 0
	for i in parte1.size():
		if str(parte1[i]["text"]).contains("batida na porta"):
			batida = i
	# A Coordenadora aparece quando bate na porta, e os servidores quando ela abre a porta
	DialogueManager.start_dialogue(parte1.slice(0, batida + 1), func():
		_mostrar_grupo("final_coordenadora")
		DialogueManager.start_dialogue(parte1.slice(batida + 1), func():
			GameManager.mark_event("final_porta")
			_mostrar_grupo("final_despedida")
			DialogueManager.start_dialogue(Fase3Dialogues.final_parte2(), _final_cards)
		)
	)

func _mostrar_grupo(grupo: String) -> void:
	for npc in get_tree().get_nodes_in_group(grupo):
		npc.visible = true
		npc.process_mode = Node.PROCESS_MODE_INHERIT
		var sprite: AnimatedSprite2D = npc.get("animated_sprite") as AnimatedSprite2D
		if sprite:
			sprite.play(str(npc.get("default_animation")))

func _final_cards() -> void:
	GameManager.mark_event("final_fim")
	await Transition.change_scene_with_cards(SCENE_GABINETE, "SpawnDesk", Fase3Dialogues.MENSAGEM_FINAL, func():
		GameManager.game_finished = true
		GameManager.set_objective("Obrigado por jogar Pitagorome! Você ainda pode andar pela escola.")
	)
	game_finished.emit()

# ------------------------------------------------------------------
# Utilitários
# ------------------------------------------------------------------

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
