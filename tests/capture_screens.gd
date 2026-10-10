extends Node

# Ferramenta: tira prints de cada etapa da Fase 1 (para o relatório de testes).
# Precisa rodar COM janela (sem --headless):
#   Godot_v4.6.2-stable_win64.exe --path . res://tests/capture_screens.tscn -- --out=C:/pasta/dos/prints

const Flow = preload("res://tests/test_3_fluxo_fase1.gd")

var out_dir: String = "user://capturas"
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
	var img: Image = get_viewport().get_texture().get_image()
	img.save_png(out_dir.path_join(file_name + ".png"))
	print("print salvo: ", file_name)

func _advance_until_name_prompt() -> void:
	var guard: int = 0
	while DialogueManager.is_active and guard < 50:
		guard += 1
		var box: Node = DialogueManager.dialogue_box_instance
		if box.waiting_for_name:
			return
		DialogueManager.advance()
		await sim._frames(1)

func _capture_all() -> void:
	GameManager.reset_progress()
	await sim._go(Flow.GABINETE)
	await _shot("01_introducao")
	await _advance_until_name_prompt()
	var box: Node = DialogueManager.dialogue_box_instance
	box.name_line_edit.text = "Ana"
	box.female_btn.button_pressed = true
	box.female_btn.pressed.emit()
	await _shot("02_criar_personagem")
	await sim._read_all(func(b): b._save_name_and_continue())

	await sim._go(Flow.CORREDOR, "SpawnFromDirector")
	await _shot("03_corredor_tour")
	sim._find("NPCZelador").interact()
	await _shot("04_zelador")
	await sim._read_all()
	await sim._go(Flow.MATEMATICA, "SpawnFromCorridor")
	sim._find("NPCProfessor").interact()
	await sim._read_all()
	await sim._wait_transition()
	await _shot("05_task2_coordenadora")
	await sim._read_all()
	var grade: Node = sim._find("SchedulePuzzle")
	await _shot("06_task2_grade")
	grade.check_answer()
	await _shot("07_task2_grade_erro")
	grade.set_assignment({"mat_2b": 3})
	grade.check_answer()
	await _shot("08_task2_grade_certa")
	grade.close()
	await sim._read_all()

	await sim._go(Flow.ALMOX, "SpawnFromCorridor")
	await sim._read_all()
	await _shot("09_task3_almoxarifado")
	sim._find("LockedCabinet").interact()
	sim._modal().code_input.text = "2 4 6"
	await _shot("10_task3_cadeado")
	sim._modal()._on_code_submitted()
	await _shot("11_task3_cadeado_aberto")
	sim._modal()._on_feedback_closed()
	await sim._read_all()

	await sim._go(Flow.CORREDOR, "SpawnFromAlmox")
	await sim._read_all()
	await _shot("12_task4_corredor")
	for nome in ["AlunoJoao", "AlunoPedro", "AlunoLucas"]:
		sim._find(nome).interact()
		await sim._read_all()
	sim._find("NPCCoordenadoraTask4").interact()
	await sim._read_all()
	await _shot("13_task4_acusacao")
	sim._modal()._on_option_selected(1)
	sim._modal()._on_feedback_closed()
	await sim._read_all()

	await sim._go(Flow.GABINETE, "SpawnFromCorridor")
	await _shot("14_task5_calendario")
	sim._find("Calendar").interact()
	await sim._read_all()
	await sim._go(Flow.PORTAO, "SpawnFromCorridor")
	await _shot("15_task5_portao")
	await sim._read_all()
	var vans: Node = sim._find("VanPuzzle")
	vans.set_assignment(Fase1Puzzles.VAN_SOLUTION)
	await _shot("16_task5_vans")
	vans.check_answer()
	vans.close()
	await get_tree().create_timer(2.3).timeout
	await sim._read_all()
	await get_tree().create_timer(1.0).timeout
	await _shot("17_fim_fase1")
	get_tree().quit()
