extends "res://tests/test_base.gd"

# TESTE 1 — Lógica dos desafios da Fase 1
# Testa as regras de cada desafio sozinhas (sem cenas), incluindo força bruta
# para provar que cada desafio tem solução e que a resposta do roteiro é a certa.

func _init() -> void:
	suite_name = "Teste 1 — Lógica dos desafios"
	suite_description = "Valida as regras e respostas dos desafios das Tasks 2 a 5 e a troca de textos por gênero."

func get_cases() -> Array:
	return [
		["T1.1 Grade inicial (Task 2) começa com conflito", _grade_inicial],
		["T1.2 Grade: solução correta é aceita", _grade_solucao],
		["T1.3 Grade: cada regra quebrada é detectada", _grade_regras],
		["T1.4 Grade: força bruta encontra soluções", _grade_forca_bruta],
		["T1.5 Cofre (Task 3): senha 246 e pistas", _cofre],
		["T1.6 Suspeitos (Task 4): só o Pedro pode ser o mentiroso", _suspeitos],
		["T1.7 Vans (Task 5): solução do roteiro e força bruta", _vans_solucao],
		["T1.8 Vans: cada restrição quebrada é detectada", _vans_regras],
		["T1.9 Textos com gênero (Diretor/Diretora)", _textos_genero],
	]

func _grade_inicial() -> void:
	var errors: Array[String] = Fase1Puzzles.validate_schedule(Fase1Puzzles.SCHEDULE_INITIAL)
	check(errors.size() > 0, "A grade inicial deve ter pelo menos um conflito")
	check(errors.any(func(e): return e.contains("Sala 1")), "Conflito de sala (duas turmas na Sala 1) é apontado")
	check(errors.any(func(e): return e.contains("Prof. Carlos")), "Conflito de professor (Prof. Carlos em duas turmas) é apontado")
	note("Erros encontrados na grade inicial: %s" % " | ".join(errors))

func _grade_solucao() -> void:
	var solucao: Dictionary = Fase1Puzzles.SCHEDULE_INITIAL.duplicate()
	solucao["mat_2b"] = 3 # Matemática 2º B -> 2º horário, Sala 1
	check_eq(Fase1Puzzles.validate_schedule(solucao).size(), 0, "Mover Matemática do 2º B para o 2º horário resolve tudo")

func _grade_regras() -> void:
	var base: Dictionary = {"mat_1a": 1, "mat_2b": 3, "cie_1a": 4, "cie_2b": 2}
	check_eq(Fase1Puzzles.validate_schedule(base).size(), 0, "Grade de referência é válida")

	var cancelada: Dictionary = base.duplicate()
	cancelada["mat_1a"] = 0
	check(Fase1Puzzles.validate_schedule(cancelada).any(func(e): return e.contains("perder aula")), "Cancelar uma aula quebra a regra 'nenhuma turma pode perder aula'")

	var fora_lab: Dictionary = base.duplicate()
	fora_lab["cie_1a"] = 3
	check(Fase1Puzzles.validate_schedule(fora_lab).any(func(e): return e.contains("Laboratório")), "Ciências fora do laboratório é apontado")

	var lab_lotado: Dictionary = base.duplicate()
	lab_lotado["cie_1a"] = 2
	check(Fase1Puzzles.validate_schedule(lab_lotado).any(func(e): return e.contains("Laboratório") and e.contains("2 turmas")), "Laboratório com duas turmas no mesmo horário é apontado")

	var turma_dupla: Dictionary = {"mat_1a": 1, "mat_2b": 3, "cie_1a": 2, "cie_2b": 4}
	check(Fase1Puzzles.validate_schedule(turma_dupla).any(func(e): return e.contains("1º A") and e.contains("duas aulas")), "Turma com duas aulas no mesmo horário é apontada")

func _grade_forca_bruta() -> void:
	var total: int = 0
	var validas: int = 0
	var ids: Array = Fase1Puzzles.SCHEDULE_CLASSES.map(func(c): return c["id"])
	for a in 5:
		for b in 5:
			for c in 5:
				for d in 5:
					total += 1
					var g: Dictionary = {ids[0]: a, ids[1]: b, ids[2]: c, ids[3]: d}
					if Fase1Puzzles.validate_schedule(g).is_empty():
						validas += 1
	check(validas > 0, "Existe pelo menos uma grade válida")
	check(validas <= 4, "O desafio não é trivial (poucas grades válidas)")
	note("%d grades testadas, %d válidas" % [total, validas])

func _cofre() -> void:
	check(Fase1Puzzles.cofre_broken_clues("246").is_empty(), "246 respeita todas as pistas")
	check(Fase1Puzzles.cofre_broken_clues("2 4 6").is_empty(), "'2 4 6' com espaços também é aceito")
	check(not Fase1Puzzles.cofre_broken_clues("264").is_empty(), "264 não está em ordem crescente")
	check(not Fase1Puzzles.cofre_broken_clues("345").is_empty(), "345 começa com número ímpar")
	check(not Fase1Puzzles.cofre_broken_clues("12").is_empty(), "Senha com 2 dígitos é rejeitada")

	var sem_pista_extra: Array[String] = Fase1Puzzles.cofre_all_solutions(false)
	var com_pista_extra: Array[String] = Fase1Puzzles.cofre_all_solutions(true)
	note("Só com as 4 pistas do roteiro, senhas possíveis: %s" % ", ".join(sem_pista_extra))
	check(sem_pista_extra.has("246"), "A senha do roteiro (246) atende às pistas do roteiro")
	check_eq(", ".join(com_pista_extra), "246", "Com a pista extra do Zelador a única senha é 246")

func _suspeitos() -> void:
	var mentirosos: Array[String] = Fase1Puzzles.find_consistent_liars()
	check_eq(", ".join(mentirosos), "pedro", "Testando todas as hipóteses, só o Pedro pode ser o único mentiroso")
	check_eq(Fase1Puzzles.CULPADO, "pedro", "A resposta configurada no jogo é o Pedro")

func _vans_solucao() -> void:
	check_eq(Fase1Puzzles.validate_vans(Fase1Puzzles.VAN_SOLUTION).size(), 0, "A solução do roteiro é aceita")
	var solucoes: Array[Dictionary] = Fase1Puzzles.van_all_solutions()
	check(solucoes.size() > 0, "A força bruta encontra soluções")
	var sempre_juntos: bool = solucoes.all(func(s): return s["joao"] == s["ana"] and s["ana"] == s["maria"])
	check(sempre_juntos, "Em toda solução João, Ana e Maria viajam juntos (a solução é única a menos de trocar monitor/número da van)")
	note("%d distribuições válidas entre 256 possíveis" % solucoes.size())

func _vans_regras() -> void:
	var base: Dictionary = Fase1Puzzles.VAN_SOLUTION.duplicate()
	var casos: Array = [
		[{"pedro": 1, "joao": 1}, "João e Pedro"],
		[{"lucas": 1}, "Ana e Lucas"],
		[{"maria": 2}, "Maria deve viajar com Ana"],
		[{"carlos": 1}, "Carlos"],
		[{"beatriz": 1}, "monitor"],
		[{"pedro": 1}, "passageiros"],
		[{"ana": 0}, "ainda não tem van"],
	]
	for caso in casos:
		var teste: Dictionary = base.duplicate()
		for k in caso[0]:
			teste[k] = caso[0][k]
		var errors: Array[String] = Fase1Puzzles.validate_vans(teste)
		check(errors.any(func(e): return e.contains(caso[1])), "Mudança %s gera erro com '%s'" % [str(caso[0]), caso[1]])

func _textos_genero() -> void:
	var nome_antes: String = GameManager.player_name
	var genero_antes: String = GameManager.player_gender
	GameManager.set_player_info("Ana", "F")
	check_eq(DialogueManager.format_text("{diretor}, {Seja bem-vindo|Seja bem-vinda}, {player_title} {player_name}!"), "Diretora, Seja bem-vinda, Sra. Ana!", "Texto feminino")
	GameManager.set_player_info("João", "M")
	check_eq(DialogueManager.format_text("{diretor}, {Seja bem-vindo|Seja bem-vinda}, {player_title} {player_name}!"), "Diretor, Seja bem-vindo, Sr. João!", "Texto masculino")
	GameManager.set_player_info(nome_antes, genero_antes)
