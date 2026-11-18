extends Node

# Ferramenta: tira prints de cada etapa da Fase 3 e do Encerramento (para a documentação).
# Precisa rodar COM janela (sem --headless):
#   Godot_v4.6.2-stable_win64.exe --path . res://tests/capture_fase3.tscn -- --out=C:/pasta/dos/prints

const Flow = preload("res://tests/test_7_fluxo_fase3.gd")

var out_dir: String = "user://capturas_fase3"
var sim = null

func _ready() -> void:
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

func _advance(n: int) -> void:
	for i in n:
		DialogueManager.advance()
		await sim._frames(1)

func _answer(text: String, shot_name: String = "") -> void:
	var modal: Node = sim._modal()
	modal.code_input.text = text
	if shot_name != "":
		await _shot(shot_name)
	modal._on_code_submitted()

func _capture_all() -> void:
	GameManager.jump_to_phase(3)
	GameManager.set_player_info("João", "M", 5)
	Fase3Flow.start_phase(false)
	await get_tree().create_timer(0.8).timeout
	await _shot("01_inicio_fase3")
	await sim._wait_transition()

	# Task 11
	await _advance(1)
	await _shot("02_task11_aluno_chama")
	await sim._read_all()
	await sim._wait_transition()
	await _advance(3)
	await _shot("03_task11_cantina")
	await sim._read_all()
	await _shot("04_task11_maquina")
	sim._find("MaquinaRefri").interact()
	await sim._read_all()
	await _shot("05_task11_regra")
	sim._modal()._on_option_selected(0)
	await _shot("06_task11_regra_de_tres_errada")
	sim._modal()._on_feedback_closed()
	sim._modal()._on_option_selected(1)
	sim._modal()._on_feedback_closed()
	await sim._read_all()
	await _answer("21", "07_task11_preco")
	sim._modal()._on_feedback_closed()
	await sim._read_all()

	# Task 12
	await sim._go(Flow.GABINETE, "SpawnFromCorridor")
	await _shot("08_task12_gabinete")
	await sim._read_all()
	await sim._wait_transition()
	await _advance(1)
	await _shot("09_task12_patio_gincana")
	await sim._read_all()
	sim._find("NPCCoordenadora").interact()
	await sim._read_all()
	await _answer("120")
	await _shot("10_task12_dica_ordem")
	sim._modal()._on_feedback_closed()
	await _answer("20")
	sim._modal()._on_feedback_closed()
	await sim._read_all()

	# Task 13
	await sim._go(Flow.CORREDOR, "SpawnFromPatio")
	await _advance(5)
	await _shot("11_task13_corredor")
	await sim._read_all()
	await sim._go(Flow.MATEMATICA, "SpawnFromCorridor")
	await sim._read_all()
	await _shot("12_task13_sala_escura")
	await sim._go(Flow.CORREDOR, "SpawnFromMath")
	await _shot("13_task13_interruptores")
	sim._find("Interruptores").interact()
	await sim._frames(2)
	await _shot("14_task13_equacao")
	sim._modal()._on_option_selected(1)
	sim._modal()._on_feedback_closed()
	await sim._read_all()
	await _answer("8")
	sim._modal()._on_feedback_closed()
	await sim._read_all()
	await sim._go(Flow.MATEMATICA, "SpawnFromCorridor")
	await _shot("15_task13_luz_acesa")

	# Task 14
	await sim._go(Flow.PORTAO, "SpawnFromCorridor")
	await sim._read_all()
	await _shot("16_task14_portao_foto")
	sim._find("CameraFoto").interact()
	await sim._frames(2)
	await _answer("60")
	await _shot("17_task14_dica_60")
	sim._modal()._on_feedback_closed()
	await _answer("30")
	sim._modal()._on_feedback_closed()
	await sim._read_all()

	# Task 15
	await sim._go(Flow.PATIO, "SpawnFromCorridor")
	await sim._read_all()
	await _shot("18_task15_patio_mural")
	sim._find("MuralPlacas").interact()
	await sim._frames(2)
	await _answer("120", "19_task15_mural")
	sim._modal()._on_feedback_closed()
	await sim._read_all()
	await get_tree().create_timer(1.0).timeout
	await _shot("20_fim_fase3")
	await sim._wait_transition()

	# Encerramento
	await _advance(14)
	await _shot("21_final_conversa")
	await _advance(1)
	await _shot("22_final_despedida")
	await sim._read_all()
	await get_tree().create_timer(1.2).timeout
	await _shot("23_final_mensagem")
	await sim._wait_transition()
	await _shot("24_depois_do_fim")
	print("CAPTURAS PRONTAS")
	get_tree().quit()
