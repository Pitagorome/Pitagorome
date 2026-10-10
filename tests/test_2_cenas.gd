extends "res://tests/test_base.gd"

# TESTE 2 — Cenas, portas e personagens
# Abre todas as cenas, confere se as portas levam a lugares que existem,
# se todas as salas são alcançáveis e se cada NPC aparece na tarefa certa.

const ROOMS: Array = [
	"res://scenes/intro/intro_scene.tscn",
	"res://scenes/school/school_corridor.tscn",
	"res://scenes/school/math_classroom.tscn",
	"res://scenes/school/coordenacao_scene.tscn",
	"res://scenes/school/biblioteca_scene.tscn",
	"res://scenes/school/almoxarifado_scene.tscn",
	"res://scenes/school/portao_scene.tscn",
]
const START_ROOM: String = "res://scenes/intro/intro_scene.tscn"

func _init() -> void:
	suite_name = "Teste 2 — Cenas e navegação"
	suite_description = "Carrega todas as cenas (.tscn), confere portas, pontos de spawn, alcance das salas e presença dos NPCs por tarefa."

func get_cases() -> Array:
	return [
		["T2.1 Todas as cenas .tscn carregam e instanciam", _todas_cenas],
		["T2.2 Cada sala tem jogador, HUD, diálogo e local definido", _estrutura_salas],
		["T2.3 Cada porta leva a uma cena e spawn que existem", _portas],
		["T2.4 Todas as salas são alcançáveis a partir do gabinete", _alcance],
		["T2.5 NPCs aparecem nas tarefas certas", _npcs_por_tarefa],
		["T2.6 Sprites dos personagens têm as 8 animações", _animacoes],
		["T2.7 Indicadores '!' configurados nas Tasks 3 e 5", _marcadores],
	]

func _instantiate(path: String) -> Node:
	var packed: PackedScene = load(path) as PackedScene
	return packed.instantiate() if packed else null

func _find_scenes(dir_path: String, out: Array) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return
	for f in dir.get_files():
		if f.ends_with(".tscn"):
			out.append(dir_path.path_join(f))
	for d in dir.get_directories():
		_find_scenes(dir_path.path_join(d), out)

func _todas_cenas() -> void:
	var scenes: Array = []
	_find_scenes("res://scenes", scenes)
	for path in scenes:
		var node: Node = _instantiate(path)
		check(node != null, "Cena carrega: " + path)
		if node:
			node.free()
	note("%d cenas verificadas" % scenes.size())

func _estrutura_salas() -> void:
	for path in ROOMS:
		var room: Node = _instantiate(path)
		if not check(room != null, "Sala carrega: " + path):
			continue
		for required in ["Player", "HUD", "DialogueBox", "ChallengeModal"]:
			check(room.find_child(required, true, false) != null, "%s tem %s" % [path.get_file(), required])
		check(str(room.get("location_id")) != "", "%s tem location_id (school_room.gd)" % path.get_file())
		room.free()

func _doors_of(room: Node) -> Array:
	var doors: Array = []
	for node in room.find_children("*", "Area2D", true, false):
		if node.get("target_scene") != null:
			doors.append(node)
	return doors

func _portas() -> void:
	var total: int = 0
	for path in ROOMS:
		var room: Node = _instantiate(path)
		for door in _doors_of(room):
			total += 1
			var target: String = door.target_scene
			var spawn: String = door.target_spawn_id
			if not check(ResourceLoader.exists(target), "%s/%s leva a cena existente (%s)" % [path.get_file(), door.name, target]):
				continue
			var target_room: Node = _instantiate(target)
			check(target_room.find_child(spawn, true, false) != null, "%s/%s: spawn '%s' existe em %s" % [path.get_file(), door.name, spawn, target.get_file()])
			target_room.free()
		room.free()
	note("%d portas verificadas" % total)

func _alcance() -> void:
	var visited: Dictionary = {START_ROOM: true}
	var queue: Array = [START_ROOM]
	while not queue.is_empty():
		var path: String = queue.pop_front()
		var room: Node = _instantiate(path)
		for door in _doors_of(room):
			if not visited.has(door.target_scene):
				visited[door.target_scene] = true
				queue.append(door.target_scene)
		room.free()
	for path in ROOMS:
		check(visited.has(path), "Alcançável: " + path.get_file())

func _present_npcs(path: String, task: int) -> Array:
	var room: Node = _instantiate(path)
	var names: Array = []
	for node in room.find_children("*", "CharacterBody2D", true, false):
		if node.has_method("is_present_in_task") and node.is_present_in_task(task):
			names.append(str(node.npc_name))
	room.free()
	return names

func _npcs_por_tarefa() -> void:
	var corredor: String = "res://scenes/school/school_corridor.tscn"
	var t1: Array = _present_npcs(corredor, 1)
	var t4: Array = _present_npcs(corredor, 4)
	check(t1.has("Zelador") and t1.has("Coordenadora"), "Task 1, corredor: Zelador e Coordenadora presentes")
	check(not t1.has("Pedro"), "Task 1, corredor: alunos da Task 4 ainda não aparecem")
	for nome in ["João", "Pedro", "Lucas", "Coordenadora", "Professor de Matemática"]:
		check(t4.has(nome), "Task 4, corredor: %s presente" % nome)

	var mat4: Array = _present_npcs("res://scenes/school/math_classroom.tscn", 4)
	check(not mat4.has("Professor de Matemática"), "Task 4: o professor sai da sala de matemática (está no corredor)")

	var almox3: Array = _present_npcs("res://scenes/school/almoxarifado_scene.tscn", 3)
	var almox1: Array = _present_npcs("res://scenes/school/almoxarifado_scene.tscn", 1)
	check(almox3.has("Zelador") and almox3.has("Coordenadora"), "Task 3, almoxarifado: Zelador e Coordenadora presentes")
	check(almox1.is_empty(), "Antes da Task 3 o almoxarifado está vazio")

	var portao5: Array = _present_npcs("res://scenes/school/portao_scene.tscn", 5)
	check_eq(portao5.size(), 9, "Task 5, portão: 6 alunos + 2 monitores + Coordenadora")

	var gab2: Array = _present_npcs("res://scenes/intro/intro_scene.tscn", 2)
	var gab5: Array = _present_npcs("res://scenes/intro/intro_scene.tscn", 5)
	check(gab2.has("Coordenadora"), "Task 2: a Coordenadora aparece no gabinete")
	check(not gab5.has("Coordenadora"), "Task 5: o diretor está sozinho no gabinete (calendário)")

func _animacoes() -> void:
	var needed: Array = ["idle_down", "idle_up", "idle_left", "idle_right", "walk_down", "walk_up", "walk_left", "walk_right"]
	for path in GameManager.APPEARANCES:
		var frames: SpriteFrames = load(path) as SpriteFrames
		if not check(frames != null, "Carrega " + path.get_file()):
			continue
		for anim in needed:
			check(frames.has_animation(anim), "%s tem '%s'" % [path.get_file(), anim])

func _marcadores() -> void:
	var almox: Node = _instantiate("res://scenes/school/almoxarifado_scene.tscn")
	var m3: Node = almox.find_child("ExclamationMarker", true, false)
	check(m3 != null and m3.show_in_tasks.has(3), "Armário do almoxarifado tem '!' na Task 3")
	var cab: Node = almox.find_child("LockedCabinet", true, false)
	check(cab != null and cab.flow_event == "cofre", "Armário trancado abre o desafio do cofre")
	almox.free()
	var gab: Node = _instantiate(START_ROOM)
	var m5: Node = gab.find_child("ExclamationMarker", true, false)
	check(m5 != null and m5.show_in_tasks.has(5), "Calendário do gabinete tem '!' na Task 5")
	gab.free()
