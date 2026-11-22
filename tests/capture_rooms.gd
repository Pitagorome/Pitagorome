extends Node

# Ferramenta: tira um print de cada sala inteira (câmera afastada), para revisar o cenário.
# Rodar COM janela:
#   Godot_v4.6.2-stable_win64.exe --path . res://tests/capture_rooms.tscn -- --out=C:/pasta --task=1

const ROOMS: Array = [
	"res://scenes/intro/intro_scene.tscn",
	"res://scenes/school/school_corridor.tscn",
	"res://scenes/school/math_classroom.tscn",
	"res://scenes/school/coordenacao_scene.tscn",
	"res://scenes/school/biblioteca_scene.tscn",
	"res://scenes/school/almoxarifado_scene.tscn",
	"res://scenes/school/portao_scene.tscn",
	"res://scenes/school/ala_refeitorio_scene.tscn",
	"res://scenes/school/sala_armarios_scene.tscn",
	"res://scenes/school/sala_artes_scene.tscn",
	"res://scenes/school/sala_gerador_scene.tscn",
	"res://scenes/school/refeitorio_scene.tscn",
]

var out_dir: String = "user://salas"
var so_sala: String = ""             # --sala=ala_refeitorio  (só essa sala)
var centro_camera: Vector2 = Vector2.ZERO  # --cam=-180,-40  (onde a câmera olha)

func _ready() -> void:
	Fase1Flow.atraso_entrada = 0.0 # falas ao entrar na sala sem a espera de 1,2 s
	var task: int = 1
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_dir = arg.trim_prefix("--out=")
		elif arg.begins_with("--task="):
			task = int(arg.trim_prefix("--task="))
		elif arg.begins_with("--sala="):
			so_sala = arg.trim_prefix("--sala=")
		elif arg.begins_with("--cam="):
			var xy: PackedStringArray = arg.trim_prefix("--cam=").split(",")
			centro_camera = Vector2(float(xy[0]), float(xy[1]))
	DirAccess.make_dir_recursive_absolute(out_dir)
	GameManager.current_phase = GameManager.TASK_PHASE.get(task, 1)
	GameManager.start_task(task)
	GameManager.intro_dialogue_finished = true
	GameManager.set_lights_out(task == 8)
	for t in range(1, task):
		GameManager.seen_events["t%d_briefing" % t] = true
	get_tree().current_scene = null
	_capture.call_deferred()

func _capture() -> void:
	for path in ROOMS:
		if so_sala != "" and not path.get_file().begins_with(so_sala):
			continue
		var room: Node = load(path).instantiate()
		get_tree().root.add_child(room)
		get_tree().current_scene = room
		await get_tree().process_frame
		for ui in ["HUD", "DialogueBox", "ChallengeModal"]:
			var n: Node = room.find_child(ui, true, false)
			if n:
				n.visible = false
		var cam: Camera2D = room.find_child("Camera2D", true, false)
		cam.get_parent().remove_child(cam)
		room.add_child(cam)
		cam.position = centro_camera
		cam.zoom = Vector2(1.5, 1.5)
		cam.position_smoothing_enabled = false
		cam.make_current()
		DialogueManager.end_dialogue()
		await get_tree().create_timer(0.4).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(out_dir.path_join(path.get_file().get_basename() + ".png"))
		room.queue_free()
		await get_tree().process_frame
	get_tree().quit()
