extends Node

# Ferramenta: grava a historinha do começo (scenes/intro/historia_inicio.tscn) em prints
# seguidos (um a cada 0,5 s), avançando as falas sozinha, até chegar no gabinete.
# Rodar COM janela:
#   Godot_v4.6.2-stable_win64.exe --path . res://tests/capture_historia.tscn -- --out=C:/pasta

var out_dir: String = "user://historia"

func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_dir = arg.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(out_dir)
	_run.call_deferred()

func _run() -> void:
	# Esta ferramenta sai da posição de "cena atual" para não ser apagada nas trocas de cena
	get_tree().current_scene = null
	var historia: Node = load("res://scenes/intro/historia_inicio.tscn").instantiate()
	get_tree().root.add_child(historia)
	get_tree().current_scene = historia
	await get_tree().process_frame
	var falas_vistas: int = 0
	for i in 140:
		await RenderingServer.frame_post_draw
		var cena: Node = get_tree().current_scene
		var lugar: String = str(cena.name) if is_instance_valid(cena) else "nenhuma"
		get_viewport().get_texture().get_image().save_png(out_dir.path_join("%03d_%s.png" % [i, lugar]))
		if lugar == "IntroScene" and DialogueManager.is_active:
			break # chegou no gabinete e a Coordenadora começou a falar
		await get_tree().create_timer(0.5).timeout
		# cada fala fica ~1,5 s na tela antes de avançar
		if DialogueManager.is_active and not Transition.is_transitioning:
			falas_vistas += 1
			if falas_vistas % 3 == 0:
				DialogueManager.advance()
	get_tree().quit()
