extends "res://tests/test_base.gd"

# TESTE 4 — Lógica dos desafios da Fase 2
# Confere as contas de cada desafio (Tasks 6 a 10) e, por força bruta, se cada um
# tem a resposta que o roteiro espera — e se não tem outra resposta "sobrando".

func _init() -> void:
	suite_name = "Teste 4 — Lógica dos desafios da Fase 2"
	suite_description = "Confere a resposta de cada desafio da Fase 2 e testa todas as respostas possíveis para achar respostas duplicadas ou erradas no roteiro."

func get_cases() -> Array:
	return [
		["T4.1 Troféu (Task 6): 2x + 6 = 36 leva ao armário 12", _trofeu],
		["T4.2 Figurinhas (Task 7): só a caixa A tem a proporção 1 : 2", _figurinhas],
		["T4.3 Gerador (Task 8): combinações que chegam a 30", _gerador],
		["T4.4 Refeitório (Task 9): faltam 12 cadeiras", _refeitorio],
		["T4.5 Cartaz (Task 10): altura 60 e um único cartaz certo", _cartaz],
		["T4.6 Tarefas da Fase 2 no GameManager", _tarefas],
	]

func _trofeu() -> void:
	check_eq(Fase2Puzzles.trofeu_x(), 15, "x = (36 − 6) ÷ 2 = 15")
	check_eq(Fase2Puzzles.TROFEU_A * Fase2Puzzles.trofeu_x() + Fase2Puzzles.TROFEU_B, Fase2Puzzles.TROFEU_C, "x = 15 satisfaz 2x + 6 = 36")
	check_eq(Fase2Puzzles.trofeu_armario(), 12, "Armário = x − 3 = 12")
	# Força bruta: só um x inteiro de 0 a 100 satisfaz a equação
	var solucoes: Array = []
	for x in range(0, 101):
		if Fase2Puzzles.TROFEU_A * x + Fase2Puzzles.TROFEU_B == Fase2Puzzles.TROFEU_C:
			solucoes.append(x)
	check_eq(solucoes, [15], "A equação tem uma única solução (força bruta de 0 a 100)")
	check(Fase2Puzzles.trofeu_armario() >= 1 and Fase2Puzzles.trofeu_armario() <= Fase2Puzzles.TOTAL_ARMARIOS, "O armário 12 existe (a sala tem 1 a 15)")
	for n in range(1, Fase2Puzzles.TOTAL_ARMARIOS + 1):
		if n != Fase2Puzzles.trofeu_armario():
			check(Fase2Puzzles.ARMARIO_CONTEUDO.has(n), "Armário errado %d tem algo dentro (texto de erro)" % n)
	check(not Fase2Puzzles.ARMARIO_CONTEUDO.has(12), "O armário 12 não tem texto de 'armário errado'")
	check(Fase2Puzzles.trofeu_hint(3).contains("15"), "A 3ª dica já mostra x = 15")

func _figurinhas() -> void:
	check_eq(Fase2Puzzles.caixas_certas(), ["A"], "Só a caixa A mantém 3 : 6")
	check_eq(Fase2Puzzles.CAIXA_CERTA, "A", "Resposta do roteiro: Caixa A")
	for c in Fase2Puzzles.CAIXAS:
		var proporcional: bool = float(c["normais"]) / float(c["douradas"]) == 2.0
		check_eq(Fase2Puzzles.caixa_tem_proporcao(c), proporcional, "Caixa %s (%d:%d) confere com a divisão" % [c["id"], c["douradas"], c["normais"]])

func _gerador() -> void:
	var nada: Array = [false, false, false, false, false]
	check_eq(Fase2Puzzles.gerador_carga(nada), 8, "Sem alavanca a carga é 8")
	check_eq(Fase2Puzzles.gerador_carga([true, true, true, true, true]), 39, "Todas ligadas: 8 + 6 + 5 + 9 + 4 + 7 = 39")
	var valores: Array = Fase2Puzzles.ALAVANCAS.map(func(a): return a["valor"])
	check_eq(valores, [6, 5, 9, 4, 7], "Valores das alavancas: √36=6, √25=5, 3²=9, 2²=4, √49=7")
	var solucoes: Array[Array] = Fase2Puzzles.gerador_all_solutions()
	var textos: PackedStringArray = []
	for s in solucoes:
		textos.append(Fase2Puzzles.gerador_descricao(s))
	note("Combinações que dão 30 (força bruta das 32): " + " | ".join(textos))
	check_eq(solucoes.size(), 2, "Existem 2 combinações certas (o jogo aceita as duas)")
	check(textos.has("8 + √36(6) + 3²(9) + √49(7) = 30"), "√36 + 3² + √49 é uma solução")
	check(textos.has("8 + √36(6) + √25(5) + 2²(4) + √49(7) = 30"), "√36 + √25 + 2² + √49 é uma solução")
	check(Fase2Puzzles.validate_gerador(nada)[0].contains("faltam 22"), "Carga baixa diz quanto falta")
	check(Fase2Puzzles.validate_gerador([true, true, true, true, true])[0].contains("passou de 30"), "Carga acima de 30 avisa que passou")

func _refeitorio() -> void:
	check_eq(Fase2Puzzles.cadeiras_ja_montadas(), 44, "4 × 8 + 2 × 6 = 44 cadeiras já montadas")
	check_eq(Fase2Puzzles.cadeiras_mesa_final(), 12, "56 − 44 = 12 cadeiras na mesa final")

func _cartaz() -> void:
	check_eq(Fase2Puzzles.cartaz_nova_altura(), 60, "18/24 = 45/h → h = 60")
	# Problema encontrado no roteiro original
	var prop_roteiro: Array[String] = Fase2Puzzles.cartazes_proporcionais(Fase2Puzzles.CARTAZES_ROTEIRO)
	note("Roteiro original: cartazes com a proporção 3:4 = %s; com 45x60 = %s" % [str(prop_roteiro), str(Fase2Puzzles.cartazes_certos(Fase2Puzzles.CARTAZES_ROTEIRO))])
	check_eq(prop_roteiro.size(), 2, "No roteiro original DOIS cartazes (A e B) mantêm a proporção (problema documentado)")
	check(Fase2Puzzles.cartazes_certos(Fase2Puzzles.CARTAZES_ROTEIRO).is_empty(), "No roteiro original nenhum cartaz mede 45x60 (problema documentado)")
	# Versão corrigida usada no jogo
	check_eq(Fase2Puzzles.cartazes_proporcionais(), ["B"], "No jogo só um cartaz mantém a proporção")
	check_eq(Fase2Puzzles.cartazes_certos(), [Fase2Puzzles.CARTAZ_CERTO], "O cartaz certo é o de 45x60")

func _tarefas() -> void:
	for t in range(6, 11):
		check(GameManager.TASK_NAMES.has(t) and GameManager.TASK_OBJECTIVES.has(t), "Tarefa %d tem nome e objetivo" % t)
		check_eq(GameManager.TASK_PHASE.get(t), 2, "Tarefa %d é da Fase 2" % t)
	# Virada de fase: completar a 5 não começa a 6 sozinho (o roteiro mostra o cartão antes)
	GameManager.reset_progress()
	for t in range(1, 6):
		GameManager.complete_task(t)
	check_eq(GameManager.current_phase, 2, "Completar a Task 5 passa para a Fase 2")
	check_eq(GameManager.current_task_id, 0, "Entre as fases fica sem tarefa (cartão de fim de fase)")
	GameManager.jump_to_phase(2)
	check_eq(GameManager.current_task_id, 6, "Atalho jump_to_phase(2) começa na Task 6")
	check_eq(GameManager.completed_tasks.size(), 5, "Atalho marca a Fase 1 como concluída")
	for t in range(6, 11):
		GameManager.complete_task(t)
	check_eq(GameManager.current_phase, 3, "Completar a Task 10 passa para a Fase 3")
	check(GameManager.current_objective.contains("em desenvolvimento"), "Fase 3 ainda aparece como 'em desenvolvimento'")
	GameManager.reset_progress()
	check_eq(GameManager.current_phase, 1, "reset_progress volta para a Fase 1")
	check(not GameManager.lights_out, "reset_progress acende as luzes")
