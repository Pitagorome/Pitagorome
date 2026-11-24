class_name NPC
extends CharacterBody2D

# Base NPC (UML: Objeto / NPC)
# Permite interação, indicador visual, animação idle e direcionamento para o player.

@export var npc_name: String = "NPC"
@export var default_animation: String = "idle_down"
@export var auto_start_dialogue: bool = false
# Em quais tarefas o NPC aparece nesta sala (vazio = sempre)
@export var visible_in_tasks: Array[int] = []
# Em quais tarefas o NPC NÃO aparece nesta sala
@export var hidden_in_tasks: Array[int] = []
# Só aparece depois que esse evento aconteceu (GameManager.seen_events). Ex.: "t6_briefing"
@export var requires_event: String = ""
# Some da sala depois que esse evento aconteceu (vale ao entrar de novo na sala)
@export var gone_after_event: String = ""
# Nessas tarefas o NPC anda junto com o jogador (ex.: Coordenadora no tour da Task 1)
@export var follow_player_in_tasks: Array[int] = []

const FOLLOW_SPEED: float = 95.0
const FOLLOW_DISTANCE: float = 28.0
const FOLLOW_TOO_FAR: float = 110.0

@onready var interaction_area: Area2D = $InteractionArea
@onready var hint_label: Label = $HintLabel
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var player_in_range: bool = false
var player_ref: Node2D = null

func _ready() -> void:
	if not is_present_in_task(GameManager.current_task_id):
		_remove_from_room()
		return

	if animated_sprite:
		animated_sprite.play(default_animation)

	if hint_label:
		hint_label.visible = false

	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)

	if is_following():
		add_to_group("acompanha_jogador")
		# Não empurra nem trava o jogador: só bate nas paredes e nos móveis
		collision_layer = 0
		come_to_player.call_deferred()

# Durante um diálogo/desafio o "[E] Conversar" some (antes ficava aparecendo atrás da caixa de diálogo)
func _process(_delta: float) -> void:
	if hint_label:
		hint_label.visible = player_in_range and not DialogueManager.is_busy() and Interacao.eh_o_mais_proximo(self)

func is_following() -> bool:
	return follow_player_in_tasks.has(GameManager.current_task_id)

func _get_player() -> Node2D:
	return get_tree().get_first_node_in_group("player") as Node2D

func _physics_process(_delta: float) -> void:
	if not is_following() or not is_visible_in_tree():
		return
	var player: Node2D = _get_player()
	if player == null:
		return
	var to_player: Vector2 = player.global_position - global_position
	if DialogueManager.is_busy() or to_player.length() <= FOLLOW_DISTANCE:
		velocity = Vector2.ZERO
		if animated_sprite and animated_sprite.animation.begins_with("walk"):
			animated_sprite.play(animated_sprite.animation.replace("walk", "idle"))
		return
	if to_player.length() > FOLLOW_TOO_FAR:
		come_to_player() # ficou presa atrás de algum móvel: reaparece perto
		return
	velocity = to_player.normalized() * FOLLOW_SPEED
	move_and_slide()
	if animated_sprite:
		var dir: String
		if absf(to_player.x) > absf(to_player.y):
			dir = "right" if to_player.x > 0 else "left"
		else:
			dir = "down" if to_player.y > 0 else "up"
		animated_sprite.play("walk_" + dir)

# Coloca o NPC num lugar livre ao lado do jogador
func come_to_player() -> void:
	var player: Node2D = _get_player()
	if player == null:
		return
	if global_position.distance_to(player.global_position) <= FOLLOW_DISTANCE + 8.0:
		return
	for offset in [Vector2(24, 0), Vector2(-24, 0), Vector2(0, 22), Vector2(0, -22), Vector2(20, 18), Vector2(-20, 18)]:
		var spot: Vector2 = player.global_position + offset
		var t: Transform2D = global_transform
		t.origin = spot
		if not test_move(t, Vector2(0.5, 0)) and not test_move(t, Vector2(-0.5, 0)):
			global_position = spot
			break
	face_target(player)

# O NPC anda de verdade até o jogador (ex.: Coordenadora chegando no corredor na Task 6).
# Se ficar preso em algum móvel ou demorar demais, aparece ao lado dele (come_to_player).
func caminhar_ate_jogador(velocidade: float = 90.0, distancia: float = 26.0, limite: float = 4.0) -> void:
	var player: Node2D = _get_player()
	if player == null:
		return
	var tempo: float = 0.0
	var parado: float = 0.0
	while is_inside_tree() and global_position.distance_to(player.global_position) > distancia and tempo < limite:
		await get_tree().physics_frame
		if not is_inside_tree():
			return
		var dt: float = get_physics_process_delta_time()
		tempo += dt
		var to_player: Vector2 = player.global_position - global_position
		var antes: Vector2 = global_position
		velocity = to_player.normalized() * velocidade
		move_and_slide()
		parado = parado + dt if global_position.distance_to(antes) < 0.2 else 0.0
		if parado > 0.4:
			break
		if animated_sprite:
			var dir: String
			if absf(to_player.x) > absf(to_player.y):
				dir = "right" if to_player.x > 0 else "left"
			else:
				dir = "down" if to_player.y > 0 else "up"
			animated_sprite.play("walk_" + dir)
	velocity = Vector2.ZERO
	if global_position.distance_to(player.global_position) > distancia + 10.0:
		come_to_player()
	face_target(player)
	# o jogador também se vira para quem chegou
	if "current_direction" in player:
		var para_npc: Vector2 = global_position - player.global_position
		player.current_direction = Vector2(signf(para_npc.x), 0) if absf(para_npc.x) > absf(para_npc.y) else Vector2(0, signf(para_npc.y))
		if player.has_method("_update_animation"):
			player._update_animation(Vector2.ZERO)

func face_target(target: Node2D) -> void:
	if not animated_sprite or not target:
		return
	var dir: Vector2 = (target.global_position - global_position).normalized()
	if abs(dir.x) > abs(dir.y):
		animated_sprite.play("idle_right" if dir.x > 0 else "idle_left")
	else:
		animated_sprite.play("idle_down" if dir.y > 0 else "idle_up")

func is_present_in_task(task_id: int) -> bool:
	if hidden_in_tasks.has(task_id):
		return false
	if not (visible_in_tasks.is_empty() or visible_in_tasks.has(task_id)):
		return false
	if requires_event != "" and not GameManager.seen_events.has(requires_event):
		return false
	if gone_after_event != "" and GameManager.seen_events.has(gone_after_event):
		return false
	return true

# O NPC não está nesta sala na tarefa atual: esconde e desliga colisão/interação.
func _remove_from_room() -> void:
	player_in_range = false
	Interacao.saiu(self)
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)
	if interaction_area:
		interaction_area.set_deferred("monitoring", false)

func _unhandled_input(event: InputEvent) -> void:
	if not player_in_range or DialogueManager.is_busy() or not Interacao.eh_o_mais_proximo(self):
		return

	if event.is_action_pressed("abrir_licoes") or event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and (event.keycode == KEY_E or event.physical_keycode == KEY_E or event.keycode == KEY_SPACE or event.keycode == KEY_ENTER)):
		get_viewport().set_input_as_handled()
		interact()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player" or body.name == "director":
		player_in_range = true
		player_ref = body
		Interacao.entrou(self)
		if auto_start_dialogue and not DialogueManager.is_busy():
			auto_start_dialogue = false
			interact()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player" or body.name == "director":
		player_in_range = false
		player_ref = null
		Interacao.saiu(self)
		if hint_label:
			hint_label.visible = false

func face_player() -> void:
	if not animated_sprite or not player_ref:
		return
	var dir: Vector2 = (player_ref.global_position - global_position).normalized()
	if abs(dir.x) > abs(dir.y):
		animated_sprite.play("idle_right" if dir.x > 0 else "idle_left")
	else:
		animated_sprite.play("idle_down" if dir.y > 0 else "idle_up")

func interact() -> void:
	Audio.tocar("interagir")
	if hint_label:
		hint_label.visible = false
	face_player()
	print("[NPC] Interagindo com: ", npc_name)
