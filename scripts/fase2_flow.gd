extends Node

# Autoload: Fase2Flow
# Roteiro jogável da Fase 2 — Equações, Proporções e Probabilidade (Tasks 6 a 10).
# Segue o mesmo modelo do Fase1Flow: as salas e os NPCs chamam o Fase1Flow, que repassa
# para cá quando GameManager.current_phase == 2 (a partir da 3, para o Fase3Flow).
# Falas: data/dialogues/fase2_dialogues.gd | Desafios: data/puzzles/fase2_puzzles.gd

signal puzzle_opened(puzzle: Node)
signal phase_finished()

const SCENE_GABINETE: String = "res://scenes/intro/intro_scene.tscn"
const SCENE_GERADOR: String = "res://scenes/school/sala_gerador_scene.tscn"
const GERADOR_PUZZLE: PackedScene = preload("res://scenes/ui/gerador_puzzle.tscn")
const CHALLENGE_MODAL: PackedScene = preload("res://scenes/ui/challenge_modal.tscn")

var current_location: String = ""

# ------------------------------------------------------------------
# Começo da fase (chamado pelo Fase1Flow depois do cartão "Fim da Fase 1")
# ------------------------------------------------------------------

# Tudo com a tela preta: antes os cartões eram separados e a tela voltava ao portão entre eles.
func start_phase(com_fim_fase1: bool = true) -> void:
	var cards: Array = []
	if com_fim_fase1:
		cards.append(["Fim da Fase 1", "Lógica e Organização concluída!", 3.0])
	cards.append(["Fase 2", GameManager.PHASE_NAMES[2], 2.5])
	cards.append(["No dia seguinte...", "", 1.5])
	await Transition.change_scene_with_cards(SCENE_GABINETE, "SpawnDesk", cards, func():
		GameManager.current_phase = 2
		GameManager.set_lights_out(false)
		GameManager.start_task(6)
	)

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
	match location:
		"gabinete":
			if task == 6 and GameManager.mark_event("t6_dia"):
				DialogueManager.start_dialogue(Fase2Dialogues.phase_start())
		"corredor":
			if task == 6 and not GameManager.seen_events.has("t6_briefing"):
				_start_task6_briefing()
		"sala_armarios":
			if task == 6 and GameManager.seen_events.has("t6_briefing") and GameManager.mark_event("t6_arrival"):
				DialogueManager.start_dialogue(Fase2Dialogues.task6_arrival())
		"sala_artes":
			if task == 7 and GameManager.mark_event("t7_briefing"):
				DialogueManager.start_dialogue(Fase2Dialogues.task7_briefing(), func():
					GameManager.set_objective("Examine as 3 caixas e diga à Professora qual mantém a proporção do mural (3 douradas : 6 normais).")
				)
		"sala_gerador":
			if task == 8 and GameManager.mark_event("t8_briefing"):
				DialogueManager.start_dialogue(Fase2Dialogues.task8_briefing(), open_gerador_puzzle)
		"ala_refeitorio":
			if task == 9 and GameManager.mark_event("t9_overheard"):
				DialogueManager.start_dialogue(Fase2Dialogues.task9_overheard())
		"refeitorio":
			if task == 9 and GameManager.mark_event("t9_briefing"):
				DialogueManager.start_dialogue(Fase2Dialogues.task9_briefing(), open_mesas)
		"biblioteca":
			if task == 10 and GameManager.mark_event("t10_briefing"):
				DialogueManager.start_dialogue(Fase2Dialogues.task10_briefing(), open_cartaz_altura)

# ------------------------------------------------------------------
# NPCs
# ------------------------------------------------------------------

func on_coordenadora_interact() -> void:
	var task: int = GameManager.current_task_id
	match task:
		6:
			if not GameManager.seen_events.has("t6_briefing"):
				_start_task6_briefing()
				return
			if not GameManager.seen_events.has("t6_bilhete"):
				DialogueManager.start_dialogue(Fase2Dialogues.task6_ler_bilhete_primeiro())
				return
			DialogueManager.start_dialogue(Fase2Dialogues.task6_reminder())
			return
		8:
			if current_location == "sala_gerador":
				DialogueManager.start_dialogue(Fase2Dialogues.task8_reminder(), open_gerador_puzzle)
				return
		9:
			if current_location == "refeitorio":
				DialogueManager.start_dialogue(Fase2Dialogues.task9_reminder(), open_mesas)
				return
		0:
			_say("Coordenadora", "Mais um trimestre concluído, {diretor} {player_name}. A próxima fase ainda está sendo preparada!")
			return
	_say("Coordenadora", Fase2Dialogues.hint_for_task(task))

func on_zelador_interact() -> void:
	var task: int = GameManager.current_task_id
	if task == 6 and GameManager.seen_events.has("t6_bilhete"):
		DialogueManager.start_dialogue([{"speaker": "Zelador", "text": "Quer ler o bilhete de novo? Aqui."}] + Fase2Dialogues.bilhete())
	elif task == 6 and GameManager.seen_events.has("t6_briefing"):
		_say("Zelador", "O bilhete está no quadro de avisos da Sala dos Armários, na Ala do Refeitório.")
	elif task == 8 and current_location == "sala_gerador":
		DialogueManager.start_dialogue(Fase2Dialogues.task8_reminder(), open_gerador_puzzle)
	else:
		DialogueManager.start_dialogue(Fase1Dialogues.zelador_idle())

func on_professor_interact() -> void:
	if GameManager.current_task_id == 10 and current_location == "biblioteca":
		DialogueManager.start_dialogue(Fase2Dialogues.task10_reminder(), _reopen_cartaz)
	else:
		DialogueManager.start_dialogue(Fase1Dialogues.professor_idle())

# NPCs genéricos (npc_aluno.gd com flow_id). Retorna true se a história usou a conversa.
func on_npc_event(flow_id: String, npc: Node = null) -> bool:
	var task: int = GameManager.current_task_id
	match flow_id:
		"professora":
			if task == 7:
				var faltam: Array[String] = caixas_nao_vistas()
				if faltam.is_empty():
					DialogueManager.start_dialogue(Fase2Dialogues.task7_reminder(), open_caixas)
				else:
					DialogueManager.start_dialogue(Fase2Dialogues.task7_falta_caixa(faltam))
			else:
				DialogueManager.start_dialogue(Fase2Dialogues.professora_idle())
			return true
		"aluno_mural":
			if task == 7:
				_say("Aluno", "Olha as caixas ali na mesa. Uma delas tem que estar certa!")
				return true
		"cantineira":
			if task == 9 and current_location == "refeitorio":
				DialogueManager.start_dialogue(Fase2Dialogues.task9_reminder(), open_mesas)
			else:
				DialogueManager.start_dialogue(Fase2Dialogues.cantineira_idle())
			return true
		"aluno_aleatorio":
			var speaker: String = str(npc.get("npc_name")) if npc else "Aluno"
			_say(speaker, Fase2Dialogues.FALAS_ALUNOS.pick_random())
			return true
	return false

# ------------------------------------------------------------------
# Objetos do cenário (interactable_object.gd com flow_event)
# ------------------------------------------------------------------

func on_object_event(event_id: String, source: Node = null) -> void:
	var task: int = GameManager.current_task_id
	match event_id:
		"armario_numerado":
			open_locker(int(source.get("numero")) if source else 0)
		"caixa_figurinhas":
			var id: String = str(source.get("flow_value")) if source else ""
			for c in Fase2Puzzles.CAIXAS:
				if c["id"] == id:
					var texto: String = Fase2Puzzles.caixa_texto(c) + "."
					if task == 7:
						GameManager.seen_events["t7_caixa_" + id] = true
						var faltam: Array[String] = caixas_nao_vistas()
						if faltam.is_empty():
							texto += "\n(Você já viu as 3 caixas. Fale com a Professora.)"
						else:
							texto += "\n(Falta olhar: Caixa " + " e Caixa ".join(faltam) + ".)"
					_say("Caixa " + id, texto)
		"bilhete":
			if task == 6 and GameManager.seen_events.has("t6_briefing"):
				ler_bilhete()
			else:
				_say("Quadro de avisos", "\"Armários numerados de 1 a 15. Não guarde comida aqui.\" — Zelador")
		"mural":
			_say("Mural", "Mural da turma: para cada 3 figurinhas douradas, 6 normais.")
		"gerador":
			if task == 8:
				open_gerador_puzzle()
			else:
				_say("Gerador", "O gerador de emergência está funcionando. Carga: 30 unidades.")
		"mesa_final":
			if task == 9:
				open_mesas()
			elif GameManager.is_task_completed(9):
				_say("Mesa final", "A mesa final agora tem 12 cadeiras. 56 lugares no total!")
			else:
				_say("Mesa final", "Uma mesa ainda sem cadeiras.")
		"cartaz":
			var id: String = str(source.get("flow_value")) if source else ""
			for c in Fase2Puzzles.CARTAZES:
				if c["id"] == id:
					_say("Cartaz " + id, Fase2Puzzles.cartaz_texto(c) + ".")
		"calendario":
			_say("Calendário", "Segundo trimestre. Tem uma feira de matemática marcada para o fim do mês...")
		"cofre":
			_say("Armário", "O armário está aberto. Os materiais novos já foram distribuídos.")

# ------------------------------------------------------------------
# Task 6 — armários numerados
# ------------------------------------------------------------------

func _start_task6_briefing() -> void:
	GameManager.mark_event("t6_briefing")
	DialogueManager.start_dialogue(Fase2Dialogues.task6_briefing(), func():
		GameManager.set_objective("Vá até a Sala dos Armários (porta de cima à esquerda → Ala do Refeitório) e leia o bilhete do Zelador no quadro de avisos.")
	)

# Bilhete na parede da Sala dos Armários. Na 1ª leitura a Coordenadora explica o que fazer
# e só então o bilhete vai para o HUD e os armários podem ser abertos.
func ler_bilhete() -> void:
	var falas: Array = [{"speaker": "", "text": "(O bilhete do Zelador, preso no quadro de avisos.)"}] + Fase2Dialogues.bilhete()
	if GameManager.seen_events.has("t6_bilhete"):
		DialogueManager.start_dialogue(falas)
		return
	DialogueManager.start_dialogue(falas + Fase2Dialogues.task6_explicacao(), func():
		GameManager.mark_event("t6_bilhete")
		GameManager.set_note(Fase2Puzzles.BILHETE_HUD)
		GameManager.set_objective("Resolva 2x + 6 = 36, diminua 3 do x e abra o armário com esse número.")
	)

func open_locker(numero: int) -> void:
	if GameManager.current_task_id != 6 or not GameManager.seen_events.has("t6_briefing"):
		if GameManager.is_task_completed(6) and numero == Fase2Puzzles.trofeu_armario():
			_say("Armário %d" % numero, "Vazio. O troféu já voltou para a estante da escola.")
		else:
			_say("Armário %d" % numero, "Armário %d. Melhor não mexer no que não é seu." % numero)
		return
	if not GameManager.seen_events.has("t6_bilhete"):
		DialogueManager.start_dialogue(Fase2Dialogues.task6_ler_bilhete_primeiro())
		return
	if numero == Fase2Puzzles.trofeu_armario():
		DialogueManager.start_dialogue(Fase2Dialogues.task6_done(), func():
			GameManager.set_note("")
			GameManager.complete_task(6)
		)
		return
	GameManager.wrong_lockers += 1
	var conteudo: String = Fase2Puzzles.ARMARIO_CONTEUDO.get(numero, "nada")
	DialogueManager.start_dialogue(Fase2Dialogues.task6_wrong(numero, conteudo, Fase2Puzzles.trofeu_hint(GameManager.wrong_lockers)))

# ------------------------------------------------------------------
# Task 7 — caixas de figurinhas
# ------------------------------------------------------------------

# Letras das caixas que o jogador ainda não examinou na Task 7
func caixas_nao_vistas() -> Array[String]:
	var faltam: Array[String] = []
	for c in Fase2Puzzles.CAIXAS:
		if not GameManager.seen_events.has("t7_caixa_" + str(c["id"])):
			faltam.append(str(c["id"]))
	return faltam

# A pergunta NÃO mostra o que tem em cada caixa: o jogador precisa ter examinado as caixas
# (a Professora só abre a pergunta depois das 3) e lembrar/anotar o que viu.
func open_caixas() -> Node:
	var modal: Node = _get_challenge_modal()
	var context: String = "Regra do mural: para cada %d figurinhas douradas, %d normais.\nLembre do que você viu dentro de cada caixa (dá para fechar com Esc e olhar de novo)." % [Fase2Puzzles.MURAL_DOURADAS, Fase2Puzzles.MURAL_NORMAIS]
	var options: Array[String] = []
	var correct: int = 0
	for i in Fase2Puzzles.CAIXAS.size():
		var c: Dictionary = Fase2Puzzles.CAIXAS[i]
		options.append("Caixa %s" % c["id"])
		if c["id"] == Fase2Puzzles.CAIXA_CERTA:
			correct = i
	modal.show_multiple_choice_challenge(
		7,
		"Tarefa 7: Figurinhas",
		context.strip_edges(),
		"Qual caixa mantém a mesma proporção do mural?",
		options,
		correct,
		"Isso! No mural, 3 : 6 = 1 : 2 (o dobro de normais). Na caixa A, 4 : 8 = 1 : 2. Na B, 5 : 9 não é o dobro, e na C, 6 : 10 também não.",
		"Essa caixa não tem a mesma proporção. No mural as normais são o DOBRO das douradas (3 : 6 = 1 : 2). Confira em qual caixa isso acontece.",
		func(): DialogueManager.start_dialogue(Fase2Dialogues.task7_done(), _start_blackout)
	)
	puzzle_opened.emit(modal)
	return modal

# ------------------------------------------------------------------
# Task 8 — apagão e gerador
# ------------------------------------------------------------------

func _start_blackout() -> void:
	GameManager.set_lights_out(true)
	DialogueManager.start_dialogue(Fase2Dialogues.task8_blackout(), func():
		Transition.change_scene(SCENE_GERADOR, "SpawnFromAla", "Todos vão até a sala do gerador...")
	)

func open_gerador_puzzle() -> Node:
	var puzzle: Node = _open_puzzle(GERADOR_PUZZLE)
	puzzle.solved.connect(_on_gerador_solved)
	return puzzle

func _on_gerador_solved() -> void:
	GameManager.set_lights_out(false)
	DialogueManager.start_dialogue(Fase2Dialogues.task8_done(), func():
		GameManager.complete_task(8)
	)

# ------------------------------------------------------------------
# Task 9 — mesas do refeitório
# ------------------------------------------------------------------

func open_mesas() -> Node:
	var modal: Node = _get_challenge_modal()
	var context: String = "Lugares disponíveis: %d\n• 4 mesas com 8 cadeiras cada\n• 2 mesas com 6 cadeiras cada\n• 1 mesa final, ainda sem cadeiras" % Fase2Puzzles.REFEITORIO_LUGARES
	modal.show_code_challenge(
		9,
		"Tarefa 9: As Mesas do Refeitório",
		context,
		"Quantas cadeiras faltam na mesa final? (digite só o número)",
		str(Fase2Puzzles.cadeiras_mesa_final()),
		"Isso! 4 × 8 = 32 e 2 × 6 = 12, então já são 32 + 12 = 44 lugares. 56 − 44 = 12 cadeiras na mesa final.",
		"Não fecha a conta. Some as cadeiras que já estão nas mesas (4 × 8 e 2 × 6) e veja quanto falta para chegar a 56.",
		func(): DialogueManager.start_dialogue(Fase2Dialogues.task9_done())
	)
	modal.code_input.placeholder_text = "Digite um número"
	puzzle_opened.emit(modal)
	return modal

# ------------------------------------------------------------------
# Task 10 — cartaz da feira (2 passos: altura e depois o cartaz certo)
# ------------------------------------------------------------------

func open_cartaz_altura() -> Node:
	var modal: Node = _get_challenge_modal()
	modal.show_code_challenge(
		0, # passo intermediário: não conclui a tarefa
		"Tarefa 10: O Cartaz da Feira (1/2)",
		"Modelo original: %d cm de largura × %d cm de altura.\nA nova largura será %d cm, sem mudar a proporção." % [Fase2Puzzles.MODELO_LARGURA, Fase2Puzzles.MODELO_ALTURA, Fase2Puzzles.NOVA_LARGURA],
		"Qual deve ser a nova altura, em cm? (digite só o número)",
		str(Fase2Puzzles.cartaz_nova_altura()),
		"Isso! 45 ÷ 18 = 2,5 (a largura ficou 2,5 vezes maior). Então a altura também: 24 × 2,5 = 60 cm.",
		"Essa altura muda a proporção. Descubra quantas vezes 45 é maior que 18 e aumente a altura 24 na mesma quantidade.",
		func():
			GameManager.mark_event("t10_altura")
			DialogueManager.start_dialogue(Fase2Dialogues.task10_height_ok(), func():
				GameManager.set_objective("Olhe as medidas dos 3 cartazes nos cavaletes e diga ao Professor qual é o certo.")
			)
	)
	modal.code_input.placeholder_text = "Altura em cm"
	puzzle_opened.emit(modal)
	return modal

func open_cartaz_escolha() -> Node:
	GameManager.mark_event("t10_altura")
	var modal: Node = _get_challenge_modal()
	# Sem as medidas nas opções: elas estão escritas nos cavaletes da biblioteca
	var context: String = "Você calculou o tamanho certo do cartaz. Agora compare com as medidas escritas nos cavaletes (dá para fechar com Esc e olhar de novo)."
	var options: Array[String] = []
	var correct: int = 0
	for i in Fase2Puzzles.CARTAZES.size():
		var c: Dictionary = Fase2Puzzles.CARTAZES[i]
		options.append("Cartaz %s" % c["id"])
		if c["id"] == Fase2Puzzles.CARTAZ_CERTO:
			correct = i
	modal.show_multiple_choice_challenge(
		0, # a tarefa só termina depois da fala final do professor
		"Tarefa 10: O Cartaz da Feira (2/2)",
		context.strip_edges(),
		"Qual cartaz mantém a proporção do modelo original?",
		options,
		correct,
		"Isso! O cartaz B mede 45 x 60: 18/24 = 45/60 = 3/4. Os outros não mantêm a proporção (27/40 e 36/50 não dão 3/4).",
		"Esse cartaz não tem 45 x 60 e não mantém a proporção 18 : 24 (= 3 : 4). Procure o que tem a altura que você calculou.",
		func(): DialogueManager.start_dialogue(Fase2Dialogues.task10_done(), _finish_phase)
	)
	puzzle_opened.emit(modal)
	return modal

func _reopen_cartaz() -> void:
	if GameManager.seen_events.has("t10_altura"):
		open_cartaz_escolha()
	else:
		open_cartaz_altura()

func _finish_phase() -> void:
	GameManager.complete_task(10)
	phase_finished.emit()
	# O cartão "Fim da Fase 2" faz parte da mesma tela preta que leva à Fase 3 (ver Fase3Flow.start_phase)
	Fase3Flow.start_phase()

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
