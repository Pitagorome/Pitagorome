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
	"res://scenes/school/ala_refeitorio_scene.tscn",
	"res://scenes/school/sala_armarios_scene.tscn",
	"res://scenes/school/sala_artes_scene.tscn",
	"res://scenes/school/sala_gerador_scene.tscn",
	"res://scenes/school/refeitorio_scene.tscn",
	"res://scenes/school/patio_scene.tscn",
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
		["T2.7 Indicadores '!' configurados (Tasks 3, 5 e 7 a 15)", _marcadores],
		["T2.8 Andando pela sala: portas, NPCs e objetos alcançáveis, sem sair do mapa", _alcance_andando],
		["T2.9 Chão desenhado atrás dos móveis (nada escondido)", _camadas],
		["T2.10 Ninguém nasce em cima de uma porta (bug da porta que não funcionava)", _spawn_fora_da_porta],
		["T2.11 Minimapa acompanha o jogador em todas as salas (inclusive o saguão)", _minimapa_acompanha],
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
		check(room.find_children("*", "Camera2D", true, false).size() == 1, "%s tem uma câmera só (a do jogador)" % path.get_file())
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

	# ---- Fase 2 ----
	var t6: Array = _present_npcs(corredor, 6)
	check(t6.has("Coordenadora") and t6.has("Zelador"), "Task 6, corredor: Coordenadora (apressada) e Zelador presentes")
	check(not _present_npcs(corredor, 8).has("Zelador"), "Task 8: o Zelador sai do corredor (está na sala do gerador)")
	var ger8: Array = _present_npcs("res://scenes/school/sala_gerador_scene.tscn", 8)
	check(ger8.has("Zelador") and ger8.has("Coordenadora"), "Task 8, sala do gerador: Zelador e Coordenadora presentes")
	check(_present_npcs("res://scenes/school/sala_gerador_scene.tscn", 7).is_empty(), "Antes da Task 8 a sala do gerador está vazia")
	var artes7: Array = _present_npcs("res://scenes/school/sala_artes_scene.tscn", 7)
	check(artes7.has("Professora") and artes7.has("Aluno"), "Task 7, sala de artes: Professora e Aluno presentes")
	var ref9: Array = _present_npcs("res://scenes/school/refeitorio_scene.tscn", 9)
	check(ref9.has("Cantineira") and ref9.has("Coordenadora"), "Task 9, refeitório: Cantineira e Coordenadora presentes")
	var bib10: Array = _present_npcs("res://scenes/school/biblioteca_scene.tscn", 10)
	check(bib10.has("Professor de Matemática"), "Task 10, biblioteca: Professor de Matemática presente")
	check(not _present_npcs("res://scenes/school/math_classroom.tscn", 10).has("Professor de Matemática"), "Task 10: o professor sai da sala de matemática (está na biblioteca)")
	GameManager.seen_events.erase("t6_briefing")
	check(not _present_npcs("res://scenes/school/sala_armarios_scene.tscn", 6).has("Coordenadora"), "Task 6: a Coordenadora só vai à Sala dos Armários depois de entregar o bilhete")
	GameManager.seen_events["t6_briefing"] = true
	check(_present_npcs("res://scenes/school/sala_armarios_scene.tscn", 6).has("Coordenadora"), "Task 6: depois do bilhete a Coordenadora espera na Sala dos Armários")
	check(not _present_npcs(corredor, 6).has("Coordenadora"), "Task 6: depois do bilhete a Coordenadora não fica mais no corredor")
	GameManager.seen_events.clear()

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
	# Pedido de 17/11: os visuais 6 a 9 têm o nome dos personagens do grupo
	check_eq(GameManager.APPEARANCE_NAMES.size(), GameManager.APPEARANCES.size(), "Todo visual tem nome no seletor")
	check_eq(GameManager.APPEARANCE_NAMES.slice(5, 9), ["João", "Edu", "Guigas", "Ana"], "Visuais 6 a 9: João, Edu, Guigas e Ana")
	# Minimapa: toda sala do jogo aparece no mapa, e a missão de cada tarefa aponta para uma sala do mapa
	var Minimapa = load("res://scripts/minimapa.gd")
	for room in ROOMS:
		var inst: Node = _instantiate(room)
		var loc: String = str(inst.get("location_id"))
		check(Minimapa.SALAS.has(loc), "A sala '%s' está no minimapa" % loc)
		inst.free()
	# Pedido de 17/11 (image-8): as portas precisam ser coerentes entre as salas e com o minimapa.
	# Se a porta da sala A para B fica embaixo, a porta de B para A tem que ficar em cima,
	# e no minimapa B tem que estar abaixo de A.
	var lados: Dictionary = {}  # "a>b" -> Vector2 (lado da porta)
	var loc_da_cena: Dictionary = {}
	for room in ROOMS:
		var inst: Node = _instantiate(room)
		loc_da_cena[room] = str(inst.get("location_id"))
		inst.free()
	for room in ROOMS:
		var inst: Node = _instantiate(room)
		var sala_rect: Rect2 = ExteriorFundo.room_rect_of(inst)
		for porta in inst.get_children():
			if porta is Area2D and porta.get("target_scene") and loc_da_cena.has(porta.target_scene):
				# lado = parede da sala mais perto da porta (mesma regra do passagem_porta.gd)
				var p: Vector2 = porta.position
				var dist: Dictionary = {Vector2.UP: absf(p.y - sala_rect.position.y), Vector2.DOWN: absf(sala_rect.end.y - p.y),
					Vector2.LEFT: absf(p.x - sala_rect.position.x), Vector2.RIGHT: absf(sala_rect.end.x - p.x)}
				var lado: Vector2 = Vector2.UP
				for d in dist:
					if dist[d] < dist[lado]:
						lado = d
				lados["%s>%s" % [loc_da_cena[room], loc_da_cena[porta.target_scene]]] = lado
		inst.free()
	for chave in lados:
		var ab: PackedStringArray = chave.split(">")
		var volta: String = "%s>%s" % [ab[1], ab[0]]
		if lados.has(volta):
			check(lados[chave] == -lados[volta], "Portas coerentes: %s está do lado oposto da volta" % chave)
		if Minimapa.SALAS.has(ab[0]) and Minimapa.SALAS.has(ab[1]):
			var dir: Vector2 = Minimapa.SALAS[ab[1]]["rect"].get_center() - Minimapa.SALAS[ab[0]]["rect"].get_center()
			check(dir.dot(lados[chave]) > 0, "Minimapa: %s fica do mesmo lado da porta" % chave)
	var antes_tarefa: int = GameManager.current_task_id
	var concluidas: Array = GameManager.completed_tasks.duplicate()
	GameManager.completed_tasks.clear()
	var esperado: Dictionary = {2: "gabinete", 3: "almoxarifado", 4: "corredor", 7: "sala_artes", 8: "sala_gerador", 9: "refeitorio", 10: "biblioteca", 13: "corredor", 14: "portao", 15: "patio"}
	for t in esperado:
		GameManager.current_task_id = t
		check_eq(Minimapa.local_da_missao(), esperado[t], "Minimapa: missão da Tarefa %d" % t)
	GameManager.current_task_id = antes_tarefa
	GameManager.completed_tasks.assign(concluidas)
	# Nenhum visual do jogador pode ser igual ao de um NPC fixo
	for npc_path in ["res://scenes/characters/npc_coordenadora.tscn", "res://scenes/characters/npc_professor.tscn", "res://scenes/characters/npc_zelador.tscn"]:
		var npc: Node = _instantiate(npc_path)
		var npc_frames: String = npc.get_node("AnimatedSprite2D").sprite_frames.resource_path
		check(not GameManager.APPEARANCES.has(npc_frames), "Visual do jogador diferente de %s" % npc_path.get_file())
		npc.free()

# Simula o jogador andando (de 4 em 4 pixels) a partir do ponto inicial da sala, usando a física de verdade.
# Pega paredes invisíveis, portas bloqueadas por móveis, NPCs inalcançáveis e buracos para fora do mapa.
const STEP: int = 4

func _rect_of(shape_node: CollisionShape2D) -> Rect2:
	var r: Rect2 = shape_node.shape.get_rect()
	return Rect2(shape_node.global_position + r.position, r.size)

func _room_bounds(room: Node) -> Rect2:
	var bounds: Rect2 = Rect2()
	var first: bool = true
	for bg_name in ["MapBackground", "RoomBackground"]:
		var bg: Node = room.get_node_or_null(bg_name)
		if bg == null:
			continue
		# chão e parede podem ser ColorRect ou TextureRect
		for rect in bg.find_children("*", "Control", true, false):
			var r: Rect2 = Rect2(rect.global_position, rect.size)
			bounds = r if first else bounds.merge(r)
			first = false
	return bounds.grow(16)

func _flood(room: Node) -> Dictionary:
	var player: CharacterBody2D = room.find_child("Player", true, false)
	var bounds: Rect2 = _room_bounds(room)
	var doors: Array = []
	for door in _doors_of(room):
		doors.append({"name": str(door.name), "rect": _rect_of(door.get_node("CollisionShape2D")), "hit": false})
	var start: Vector2 = player.global_position.snapped(Vector2(STEP, STEP))
	var seen: Dictionary = {start: true}
	var queue: Array = [start]
	var leaked: Vector2 = Vector2.INF
	while not queue.is_empty() and seen.size() < 40000:
		var p: Vector2 = queue.pop_front()
		var foot: Rect2 = Rect2(p.x - 5, p.y + 7, 10, 8)
		var in_door: bool = false
		for d in doors:
			if foot.intersects(d["rect"]):
				d["hit"] = true
				in_door = true
		if in_door:
			continue # na porta o jogador troca de sala
		if not bounds.has_point(p):
			leaked = p
			continue
		for dir in [Vector2(STEP, 0), Vector2(-STEP, 0), Vector2(0, STEP), Vector2(0, -STEP)]:
			var n: Vector2 = p + dir
			if seen.has(n):
				continue
			player.global_position = p
			if player.move_and_collide(dir, true) == null:
				seen[n] = true
				queue.append(n)
	return {"seen": seen, "doors": doors, "leaked": leaked}

func _reaches(seen: Dictionary, center: Vector2, radius: float) -> bool:
	for p in seen:
		if Vector2(p.x, p.y + 11).distance_to(center) <= radius + 6.0:
			return true
	return false

func _alcance_andando() -> void:
	var problems: Array = []
	var total_targets: int = 0
	for path in ROOMS:
		for task in range(1, 16):
			GameManager.current_phase = GameManager.TASK_PHASE[task]
			GameManager.start_task(task)
			GameManager.intro_dialogue_finished = true
			GameManager.seen_events.clear()
			if task >= 6:
				GameManager.seen_events["t6_briefing"] = true
			# Na Fase 3 algumas cenas automáticas levam a outra sala (ex.: o aluno da Task 11
			# chama o diretor para o Refeitório). Aqui só interessa andar pela sala.
			if task >= 11:
				for ev in ["t11_chamado", "t12_gabinete", "t12_briefing", "t13_briefing", "t14_briefing", "t15_briefing"]:
					GameManager.seen_events[ev] = true
			var room: Node = _instantiate(path)
			if not check(room != null, "Sala carrega: " + path):
				continue
			tree().root.add_child(room)
			tree().current_scene = room
			for i in 4:
				await tree().physics_frame
			var result: Dictionary = _flood(room)
			var label: String = "%s (Task %d)" % [path.get_file(), task]
			if result["leaked"] != Vector2.INF:
				problems.append("%s: jogador sai do mapa perto de %s" % [label, str(result["leaked"])])
			for d in result["doors"]:
				if not d["hit"]:
					problems.append("%s: porta %s não pode ser alcançada" % [label, d["name"]])
			for area in room.find_children("InteractionArea", "Area2D", true, false):
				var owner_node: Node = area.get_parent()
				if not owner_node.is_visible_in_tree() or owner_node.process_mode == Node.PROCESS_MODE_DISABLED:
					continue
				var shape: CollisionShape2D = area.get_node("CollisionShape2D")
				var radius: float = shape.shape.radius if shape.shape is CircleShape2D else 16.0
				total_targets += 1
				if not _reaches(result["seen"], shape.global_position, radius):
					problems.append("%s: não dá para chegar perto de %s" % [label, owner_node.name])
			DialogueManager.end_dialogue()
			DialogueManager.modal_open = false
			tree().current_scene = null
			room.queue_free()
			await tree().process_frame
	check(problems.is_empty(), "Nenhum bloqueio ou buraco encontrado nas %d salas × 15 tarefas" % ROOMS.size())
	for pr in problems:
		check(false, pr)
	note("%d NPCs/objetos testados (somando todas as tarefas)" % total_targets)
	GameManager.reset_progress()

func _camadas() -> void:
	for path in ROOMS:
		var room: Node = _instantiate(path)
		if not check(room != null, "Sala carrega: " + path):
			continue
		var bg: Node2D = room.get_node_or_null("MapBackground")
		if bg == null:
			bg = room.get_node_or_null("RoomBackground")
		check(bg != null and bg.z_index < 0, "%s: chão (fundo) fica atrás dos móveis" % path.get_file())
		room.free()

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
	# Fase 2: o "!" mostra onde está o desafio de cada tarefa
	for item in [
		["res://scenes/school/sala_artes_scene.tscn", "CaixaB", 7],
		["res://scenes/school/sala_gerador_scene.tscn", "Gerador", 8],
		["res://scenes/school/refeitorio_scene.tscn", "MesaFinal", 9],
		["res://scenes/school/biblioteca_scene.tscn", "NPCProfessorTask10", 10],
		# Fase 3
		["res://scenes/school/refeitorio_scene.tscn", "MaquinaRefri", 11],
		["res://scenes/school/patio_scene.tscn", "QuadroGincana", 12],
		["res://scenes/school/school_corridor.tscn", "Interruptores", 13],
		["res://scenes/school/portao_scene.tscn", "CameraFoto", 14],
		["res://scenes/school/patio_scene.tscn", "MuralPlacas", 15],
	]:
		var room: Node = _instantiate(item[0])
		var owner_node: Node = room.find_child(item[1], true, false)
		var mk: Node = owner_node.find_child("ExclamationMarker", true, false) if owner_node else null
		check(mk != null and mk.show_in_tasks.has(item[2]), "%s/%s tem '!' na Task %d" % [item[0].get_file(), item[1], item[2]])
		room.free()
	var arm: Node = _instantiate("res://scenes/school/sala_armarios_scene.tscn")
	var numeros: Array = []
	for n in arm.find_children("Armario*", "StaticBody2D", false, false) + arm.get_node("Furniture").get_children():
		if n.get("numero") != null and not numeros.has(n.numero):
			numeros.append(n.numero)
	numeros.sort()
	check_eq(numeros, range(1, Fase2Puzzles.TOTAL_ARMARIOS + 1), "Sala dos Armários tem os armários de 1 a 15 (sem repetir)")
	arm.free()

# Bug de 18/11: entrando numa sala e indo de volta para a porta, o jogador não trocava de sala
# e andava até a parte vazia do mapa. Um dos motivos era nascer EM CIMA da porta de volta:
# a porta não percebe a "entrada" de quem já está dentro dela. Aqui o pé do jogador no ponto
# de spawn (com 2 px de folga) não pode encostar em nenhuma porta da sala.
func _spawn_fora_da_porta() -> void:
	var total: int = 0
	for path in ROOMS:
		var room: Node = _instantiate(path)
		var door_rects: Array = []
		for door in _doors_of(room):
			var shape_node: CollisionShape2D = door.get_node("CollisionShape2D")
			var r: Rect2 = shape_node.shape.get_rect()
			door_rects.append([str(door.name), Rect2(_pos_fora_da_arvore(shape_node) + r.position, r.size)])
		for spawn in room.find_children("Spawn*", "Node2D", true, false):
			total += 1
			var p: Vector2 = _pos_fora_da_arvore(spawn)
			var foot: Rect2 = Rect2(p.x - 5, p.y + 7, 10, 8).grow(2)
			for d in door_rects:
				check(not foot.intersects(d[1]), "%s: spawn %s não nasce em cima da porta %s" % [path.get_file(), spawn.name, d[0]])
		room.free()
	note("%d pontos de spawn verificados" % total)

# Posição "global" de um nó de uma cena que não foi colocada na árvore (sem rodar o _ready da sala)
func _pos_fora_da_arvore(node: Node) -> Vector2:
	var t: Transform2D = Transform2D.IDENTITY
	var n: Node = node
	while n != null:
		if n is Node2D:
			t = (n as Node2D).transform * t
		n = n.get_parent()
	return t.origin

# Apontamento do grupo (18/11): no saguão (corredor) o ponto branco do minimapa não se mexia.
# Em cada sala o jogador vai para a esquerda e depois para a direita: o ponto tem que andar junto.
func _minimapa_acompanha() -> void:
	GameManager.intro_dialogue_finished = true
	for path in ROOMS:
		var room: Node = _instantiate(path)
		tree().root.add_child(room)
		tree().current_scene = room
		for i in 3:
			await tree().physics_frame
		var mapa: Node = room.find_child("Minimapa", true, false)
		var player: Node2D = room.find_child("Player", true, false)
		var area: Rect2 = mapa._area_da_sala()
		if check(area.size != Vector2.ZERO, "%s: minimapa acha a área da sala" % path.get_file()):
			var sala: String = mapa.sala_atual()
			player.global_position = area.position + area.size * Vector2(0.25, 0.3)
			var a: Vector2 = mapa._posicao_jogador(sala)
			player.global_position = area.position + area.size * Vector2(0.75, 0.7)
			var b: Vector2 = mapa._posicao_jogador(sala)
			check(b.x > a.x + 1.0 and b.y > a.y + 0.5, "%s: ponto branco anda junto com o jogador (%s -> %s)" % [path.get_file(), str(a), str(b)])
		DialogueManager.end_dialogue()
		DialogueManager.modal_open = false
		tree().current_scene = null
		room.queue_free()
		await tree().process_frame
	GameManager.reset_progress()
