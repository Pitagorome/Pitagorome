extends "res://scripts/npc.gd"

# NPC Aluno genérico (também usado para os monitores da excursão).
# Com testimony_id preenchido, dá o depoimento da Task 4 (Quem Está Matando Aula?).

@export var frames: SpriteFrames
@export var tint: Color = Color.WHITE
@export var testimony_id: String = ""
@export var lines: Array[String] = []

func _ready() -> void:
	if animated_sprite and frames:
		animated_sprite.sprite_frames = frames
	if animated_sprite:
		animated_sprite.modulate = tint
	super._ready()

func interact() -> void:
	super.interact()
	if testimony_id != "" and GameManager.current_task_id == 4:
		Fase1Flow.hear_testimony(testimony_id, npc_name)
	elif not lines.is_empty():
		DialogueManager.start_dialogue([{"speaker": npc_name, "text": lines.pick_random()}])
