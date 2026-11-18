extends "res://tests/test_base.gd"

# TESTE 6 — Lógica dos desafios da Fase 3
# Confere as contas de cada desafio (Tasks 11 a 15) contra o roteiro. As combinações e
# arranjos são contados de verdade (listando todos os grupos), não só pela fórmula.
# Também confere que as dicas de resposta errada não dão a resposta certa.

func _init() -> void:
	suite_name = "Teste 6 — Lógica dos desafios da Fase 3"
	suite_description = "Confere a resposta de cada desafio da Fase 3 (função afim, combinações, equação e arranjos) listando todas as possibilidades, e confere as dicas de erro."

func get_cases() -> Array:
	return [
		["T6.1 Máquina (Task 11): y = 3x + 3 e 6 refrigerantes = R$ 21", _maquina],
		["T6.2 Gincana (Task 12): 20 equipes de 3 com 6 alunos", _gincana],
		["T6.3 Luzes (Task 13): A = 8 e B = 12", _luzes],
		["T6.4 Foto (Task 14): 30 fotos diferentes", _foto],
		["T6.5 Mural (Task 15): 120 organizações", _mural],
		["T6.6 Dicas de erro não entregam a resposta", _dicas],
		["T6.7 Tarefas da Fase 3 no GameManager", _tarefas],
	]

func _maquina() -> void:
	var f: Vector2 = Fase3Puzzles.maquina_funcao()
	check(is_equal_approx(f.x, 3.0) and is_equal_approx(f.y, 3.0), "Os registros (2 → 9, 4 → 15) dão y = 3x + 3 (obtido: a=%s, b=%s)" % [f.x, f.y])
	check_eq(Fase3Puzzles.maquina_preco(6), 21, "6 refrigerantes custam R$ 21 (roteiro: 21)")
	# Só uma das 3 regras oferecidas bate com os registros, e é a marcada como certa
	var servem: Array = []
	for i in Fase3Puzzles.MAQUINA_REGRAS.size():
		var r: Dictionary = Fase3Puzzles.MAQUINA_REGRAS[i]
		if Fase3Puzzles.regra_bate_com_registros(r["a"], r["b"]):
			servem.append(i)
	check_eq(servem, [Fase3Puzzles.MAQUINA_REGRA_CERTA], "Só a regra y = 3x + 3 bate com os dois registros")
	# A regra de três do aluno (proporcional) não funciona, como diz o roteiro
	check(not Fase3Puzzles.regra_bate_com_registros(4.5, 0.0), "Regra de três (R$ 4,50 cada) não bate com os registros")

func _gincana() -> void:
	var grupos: Array = Fase3Puzzles.grupos_possiveis(Fase3Puzzles.GINCANA_REPRESENTANTES, 3)
	check_eq(grupos.size(), 20, "Listando todas: 20 equipes de 3 (roteiro: C(6,3) = 20)")
	# nenhuma equipe repetida (mesmas pessoas em outra ordem)
	var vistos: Dictionary = {}
	for g in grupos:
		var chave: Array = g.duplicate()
		chave.sort()
		vistos[str(chave)] = true
	check_eq(vistos.size(), 20, "Nenhuma equipe aparece duas vezes")
	check(grupos.all(func(g): return g.size() == 3 and g[0] != g[1] and g[1] != g[2] and g[0] != g[2]), "Toda equipe tem 3 pessoas diferentes")
	check_eq(Fase3Puzzles.gincana_resposta(), 20, "Resposta do jogo = 20")

func _luzes() -> void:
	var a: int = Fase3Puzzles.luzes_a()
	var b: int = Fase3Puzzles.luzes_b()
	check_eq([a, b], [8, 12], "A = 8 e B = 12 (roteiro)")
	check_eq(a + b, 20, "Juntos controlam 20 lâmpadas")
	check_eq(b - a, 4, "B controla 4 a mais que A")
	# Força bruta: só um x de 0 a 20 resolve x + (x + 4) = 20
	var solucoes: Array = []
	for x in range(0, 21):
		if x + (x + Fase3Puzzles.LUZES_DIFERENCA) == Fase3Puzzles.LUZES_TOTAL:
			solucoes.append(x)
	check_eq(solucoes, [8], "A equação tem uma única solução")
	check_eq(Fase3Puzzles.LUZES_EQUACOES[Fase3Puzzles.LUZES_EQUACAO_CERTA], "x + (x + 4) = 20", "A opção certa é x + (x + 4) = 20")

func _foto() -> void:
	var fotos: Array = Fase3Puzzles.fotos_possiveis()
	check_eq(fotos.size(), 30, "Listando todas: 30 fotos diferentes (5 na frente × 6 duplas atrás)")
	check_eq(Fase3Puzzles.foto_resposta(), 30, "Resposta do jogo = 30")
	# cada foto: 1 na frente que não está na dupla de trás
	check(fotos.all(func(f): return f[1].size() == 2 and not f[1].has(f[0]) and f[1][0] != f[1][1]), "Toda foto tem 3 professores diferentes")
	# Por que 30 e não 60: contando a ordem dos dois de trás, cada foto aparece 2 vezes
	check_eq(Fase3Puzzles.formacoes_possiveis(Fase3Puzzles.FOTO_PROFESSORES, 3).size(), 60, "Contando a ordem dos de trás seriam 60 (o dobro) — é o erro que a dica explica")
	var por_frente: Dictionary = {}
	for f in fotos:
		por_frente[f[0]] = por_frente.get(f[0], 0) + 1
	check(por_frente.size() == 5 and por_frente.values().all(func(v): return v == 6), "Cada professor na frente aparece com 6 duplas atrás")

func _mural() -> void:
	check_eq(Fase3Puzzles.formacoes_possiveis(Fase3Puzzles.PLACAS, 3).size(), 120, "Listando todas: 120 organizações (roteiro: 120)")
	check_eq(Fase3Puzzles.grupos_possiveis(Fase3Puzzles.PLACAS, 3).size(), 20, "Sem contar a ordem seriam só 20 (a dica explica a diferença)")
	check_eq(Fase3Puzzles.mural_resposta(), 120, "Resposta do jogo = 120")

func _dicas() -> void:
	var casos: Array = [
		[Fase3Puzzles.gincana_dicas(), str(Fase3Puzzles.gincana_resposta()), "gincana"],
		[Fase3Puzzles.foto_dicas(), str(Fase3Puzzles.foto_resposta()), "foto"],
		[Fase3Puzzles.mural_dicas(), str(Fase3Puzzles.mural_resposta()), "mural"],
	]
	for c in casos:
		var dicas: Dictionary = c[0]
		check(not dicas.has(c[1]), "A resposta certa (%s) não está na lista de dicas de erro (%s)" % [c[1], c[2]])
		for errada in dicas:
			check(not str(dicas[errada]).contains(c[1]), "A dica para '%s' não escreve a resposta %s (%s)" % [errada, c[1], c[2]])

func _tarefas() -> void:
	for t in range(11, 16):
		check(GameManager.TASK_NAMES.has(t), "Task %d tem nome" % t)
		check_eq(GameManager.TASK_PHASE.get(t, 0), 3, "Task %d é da Fase 3" % t)
		check(str(GameManager.TASK_OBJECTIVES.get(t, "")) != "", "Task %d tem objetivo" % t)
	GameManager.jump_to_phase(3)
	check_eq(GameManager.current_task_id, 11, "Atalho jump_to_phase(3) começa na Task 11")
	check_eq(GameManager.completed_tasks.size(), 10, "Atalho marca as Fases 1 e 2 como concluídas")
	GameManager.set_room_dark("matematica", true)
	check(GameManager.is_room_dark("matematica") and not GameManager.is_room_dark("corredor"), "set_room_dark apaga só uma sala")
	GameManager.reset_progress()
	check(not GameManager.is_room_dark("matematica"), "reset_progress acende a sala de novo")
