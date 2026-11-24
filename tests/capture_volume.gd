extends Node

# Ferramenta: print do botão de volume (fechado e aberto) no corredor da Fase 1 e na historinha.
# Rodar COM janela:
#   Godot_v4.6.2-stable_win64.exe --path . res://tests/capture_volume.tscn -- --out=C:/pasta

var out_dir: String = "user://volume"

func _ready() -> void:
	Fase1Flow.atraso_entrada = 0.0
	Audio.salvar_config_ativo = false # não mexe no volume salvo de quem joga
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_dir = arg.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(out_dir)
	GameManager.start_task(1)
	GameManager.intro_dialogue_finished = true
	GameManager.player_name = "Teste"
	GameManager.player_named = true
	GameManager.seen_events["t1_briefing"] = true
	get_tree().current_scene = null
	_capture.call_deferred()

func _capture() -> void:
	var room: Node = load("res://scenes/school/school_corridor.tscn").instantiate()
	get_tree().root.add_child(room)
	get_tree().current_scene = room
	for i in 30:
		await get_tree().process_frame
	await _print("volume_fechado.png")
	ControleVolume.abrir()
	Audio.set_mudo("Musica", true)
	Audio.set_volume("Efeitos", 0.6)
	await _print("volume_aberto.png")
	Audio.set_mudo("Musica", false)
	Audio.set_volume("Efeitos", 1.0)
	ControleVolume.fechar()
	get_tree().current_scene = null
	room.queue_free()
	var hist: Node = load("res://scenes/intro/historia_inicio.tscn").instantiate()
	get_tree().root.add_child(hist)
	get_tree().current_scene = hist
	for i in 60:
		await get_tree().process_frame
	await _print("volume_historia.png")
	ControleVolume.abrir()
	await _print("volume_historia_aberto.png")
	get_tree().quit()

func _print(nome: String) -> void:
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(out_dir.path_join(nome))
	print("print: ", out_dir.path_join(nome))
