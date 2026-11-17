extends Node

# Ferramenta: grava a passagem da Fase 1 para a Fase 2 em vários prints seguidos
# (um a cada 0,4 s), para ver se a tela pisca ou mostra algo errado.
# Rodar COM janela:
#   Godot_v4.6.2-stable_win64.exe --path . res://tests/capture_virada_fase.tscn -- --out=C:/pasta

const Flow = preload("res://tests/test_3_fluxo_fase1.gd")

var out_dir: String = "user://virada_fase"
var sim = null

func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_dir = arg.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(out_dir)
	get_tree().current_scene = null
	sim = Flow.new()
	sim.runner = self
	_run.call_deferred()

func _run() -> void:
	# Estado: Fase 1 na Task 5, já no portão
	GameManager.jump_to_phase(1)
	for t in range(1, 5):
		GameManager.complete_task(t)
	GameManager.set_player_info("Ana", "F", 1)
	await sim._go(Flow.PORTAO, "SpawnFromCorridor")
	await sim._read_all()
	var vans: Node = sim._find("VanPuzzle")
	vans.set_assignment(Fase1Puzzles.VAN_SOLUTION)
	vans.check_answer()
	vans.close()
	# Vai avançando os diálogos da despedida e tira um print a cada 0,4 s
	for i in 45:
		if DialogueManager.is_active and not Transition.is_transitioning:
			DialogueManager.advance()
		await RenderingServer.frame_post_draw
		var cena: Node = get_tree().current_scene
		var lugar: String = str(cena.get("location_id")) if is_instance_valid(cena) else "nenhuma"
		var nome: String = "%02d_%s_t%d" % [i, lugar, GameManager.current_task_id]
		get_viewport().get_texture().get_image().save_png(out_dir.path_join(nome + ".png"))
		await get_tree().create_timer(0.4).timeout
	get_tree().quit()
