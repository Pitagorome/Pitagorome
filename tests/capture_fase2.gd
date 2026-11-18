extends Node

# Ferramenta: tira prints de cada etapa da Fase 2 (para a documentação).
# Precisa rodar COM janela (sem --headless):
#   Godot_v4.6.2-stable_win64.exe --path . res://tests/capture_fase2.tscn -- --out=C:/pasta/dos/prints

const Flow = preload("res://tests/test_5_fluxo_fase2.gd")

var out_dir: String = "user://capturas_fase2"
var sim = null

func _ready() -> void:
	Fase1Flow.atraso_entrada = 0.0 # falas ao entrar na sala sem a espera de 1,2 s
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_dir = arg.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(out_dir)
	get_tree().current_scene = null
	sim = Flow.new()
	sim.runner = self
	_capture_all.call_deferred()

func _shot(file_name: String) -> void:
	await get_tree().create_timer(0.35).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(out_dir.path_join(file_name + ".png"))
	print("print salvo: ", file_name)

func _capture_all() -> void:
	GameManager.jump_to_phase(2)
	GameManager.set_player_info("Ana", "F", 1)
	Fase2Flow.start_phase(false)
	await get_tree().create_timer(0.8).timeout
	await _shot("01_inicio_fase2")
	await sim._wait_transition()
	while Transition.is_transitioning:
		await sim._frames(1)
	await sim._wait_transition()
	await sim._read_all()

	# Task 6
	await sim._go(Flow.CORREDOR, "SpawnFromDirector")
	DialogueManager.advance()
	await _shot("02_task6_coordenadora")
	await sim._read_all()
	await _shot("02b_task6_prancheta_espiando")
	await sim._go(Flow.ALA, "SpawnFromCorridor")
	await _shot("04_ala_refeitorio")
	await sim._go(Flow.ARMARIOS, "SpawnFromAla")
	await sim._read_all()
	sim._find("Bilhete").interact()
	DialogueManager.advance()
	await _shot("03_task6_bilhete")
	for i in 3:
		DialogueManager.advance()
	await _shot("03b_task6_explicacao")
	await sim._read_all()
	sim._find("Armario15").interact()
	DialogueManager.advance()
	await _shot("05_task6_armario_errado")
	await sim._read_all()
	sim._find("Armario12").interact()
	await _shot("06_task6_trofeu")
	await sim._read_all()

	# Task 7
	await sim._go(Flow.ALA, "SpawnFromArmarios")
	await sim._go(Flow.ARTES, "SpawnFromAla")
	await _shot("07_task7_sala_artes")
	await sim._read_all()
	sim._find("NPCProfessora").interact()
	await _shot("08a_task7_examine_antes")
	await sim._read_all()
	for cx in ["CaixaA", "CaixaB", "CaixaC"]:
		sim._find(cx).interact()
		if cx == "CaixaB":
			await _shot("08b_task7_caixa_b")
		await sim._read_all()
	sim._find("NPCProfessora").interact()
	await sim._read_all()
	await _shot("08_task7_caixas")
	sim._modal()._on_option_selected(0)
	await _shot("09_task7_caixa_certa")
	sim._modal()._on_feedback_closed()
	DialogueManager.advance()
	DialogueManager.advance()
	DialogueManager.advance()
	await _shot("10_task8_apagao")
	await sim._read_all()
	await sim._wait_transition()

	# Task 8
	await sim._read_all()
	var ger: Node = sim._find("GeradorPuzzle")
	for i in 4:
		ger.levers[i].button_pressed = true # a 4ª não liga
	await _shot("11a_task8_maximo_3")
	ger.check_answer()
	await _shot("11b_task8_carga_medida")
	ger.check_answer()
	ger.check_answer()
	await _shot("11c_task8_travado")
	ger.destravar()
	ger.set_levers([true, false, true, false, true])
	ger.check_answer()
	await _shot("12_task8_gerador_certo")
	ger.close()
	await sim._frames(2)
	await sim._read_all()
	await _shot("13_task8_luz_voltou")

	# Task 9
	await sim._go(Flow.ALA, "SpawnFromGerador")
	await sim._read_all()
	await sim._go(Flow.REFEITORIO, "SpawnFromAla")
	await _shot("14_task9_refeitorio")
	await sim._read_all()
	sim._modal().code_input.text = "12"
	await _shot("15_task9_cadeiras")
	sim._modal()._on_code_submitted()
	sim._modal()._on_feedback_closed()
	await sim._read_all()

	# Task 10
	await sim._go(Flow.CORREDOR, "SpawnFromAla")
	await sim._go(Flow.BIBLIOTECA, "SpawnFromCorridor")
	await _shot("16_task10_biblioteca")
	await sim._read_all()
	sim._find("NPCProfessorTask10").interact()
	await sim._read_all()
	await _shot("18_task10_cartazes")
	sim._modal()._on_option_selected(2)
	sim._modal()._on_feedback_closed()
	await sim._read_all()
	await get_tree().create_timer(1.0).timeout
	await _shot("19_fim_fase2")
	get_tree().quit()
