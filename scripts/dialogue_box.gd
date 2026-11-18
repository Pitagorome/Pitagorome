extends CanvasLayer

# Interface da Caixa de Diálogo (UI)
# Estilo aconchegante com a paleta oficial: #F2E8D0 (fundo), #4A6741 (bordas), #FDA123 (nome), #545454 (texto)

@onready var panel: PanelContainer = $Control/DialoguePanel
@onready var speaker_label: Label = $Control/DialoguePanel/MarginContainer/Linha/VBoxContainer/SpeakerLabel
@onready var text_label: Label = $Control/DialoguePanel/MarginContainer/Linha/VBoxContainer/TextLabel
@onready var prompt_label: Label = $Control/DialoguePanel/MarginContainer/Linha/VBoxContainer/PromptLabel
# Retrato de quem está falando, no canto esquerdo do balão (apontamento do grupo, 18/11)
@onready var retrato_moldura: PanelContainer = $Control/DialoguePanel/MarginContainer/Linha/RetratoMoldura
@onready var retrato: TextureRect = $Control/DialoguePanel/MarginContainer/Linha/RetratoMoldura/Retrato

# Quem fala e não está na sala (ou fala de longe): visual padrão de cada um
const RETRATOS_PADRAO: Dictionary = {
	"Coordenadora": "res://assets/character_frames/amelia_frames.tres",
	"Zelador": "res://assets/character_frames/alex_frames.tres",
	"Professor de Matemática": "res://assets/character_frames/bob_frames.tres",
}
# Parte de cima do quadro 16x32 que aparece no retrato (cabeça e ombros)
const RETRATO_RECORTE: Rect2 = Rect2(0, 7, 16, 18) # a cabeça começa por volta da linha 9 do quadro

@onready var name_input_modal: PanelContainer = $Control/NameInputModal
@onready var name_line_edit: LineEdit = $Control/NameInputModal/MarginContainer/VBoxContainer/LineEdit
@onready var confirm_btn: Button = $Control/NameInputModal/MarginContainer/VBoxContainer/ConfirmButton
@onready var male_btn: Button = $Control/NameInputModal/MarginContainer/VBoxContainer/GenderRow/MaleButton
@onready var female_btn: Button = $Control/NameInputModal/MarginContainer/VBoxContainer/GenderRow/FemaleButton
@onready var appearance_label: Label = $Control/NameInputModal/MarginContainer/VBoxContainer/AppearanceRow/AppearanceLabel
@onready var prev_btn: Button = $Control/NameInputModal/MarginContainer/VBoxContainer/AppearanceRow/PrevButton
@onready var next_btn: Button = $Control/NameInputModal/MarginContainer/VBoxContainer/AppearanceRow/NextButton
@onready var preview_rect: TextureRect = $Control/NameInputModal/MarginContainer/VBoxContainer/PreviewPanel/Preview

# Prévia animada do visual escolhido (troca de quadro a cada PREVIEW_FRAME_TIME segundos)
const PREVIEW_ANIMATION: StringName = &"idle_down"
const PREVIEW_FRAME_TIME: float = 0.15
var _preview_frame: int = 0
var _preview_time: float = 0.0

var waiting_for_name: bool = false

func _ready() -> void:
	DialogueManager.register_dialogue_box(self)
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_line_changed.connect(_on_dialogue_line_changed)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.dialogue_event_triggered.connect(_on_dialogue_event_triggered)
	
	if confirm_btn:
		confirm_btn.pressed.connect(_on_confirm_name_pressed)
	if name_line_edit:
		name_line_edit.text_submitted.connect(_on_name_submitted)
	# Gênero e aparência são aplicados na hora, para o jogador ver o sprite mudando
	male_btn.pressed.connect(func(): GameManager.set_player_info("", "M"))
	female_btn.pressed.connect(func(): GameManager.set_player_info("", "F"))
	prev_btn.pressed.connect(func(): _cycle_appearance(-1))
	next_btn.pressed.connect(func(): _cycle_appearance(1))
	
	panel.visible = false
	name_input_modal.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not DialogueManager.is_active or waiting_for_name:
		return
	
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("abrir_licoes") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		get_viewport().set_input_as_handled()
		DialogueManager.advance()

func _on_dialogue_started() -> void:
	panel.visible = true
	name_input_modal.visible = false

func _on_dialogue_line_changed(speaker: String, text: String) -> void:
	speaker_label.text = speaker
	# Narração (o que acontece na cena) vem sem nome de quem fala
	speaker_label.visible = speaker != ""
	text_label.text = text
	_mostrar_retrato(speaker)
	panel.visible = true

# Acha o sprite de quem fala: o jogador, um NPC da sala com esse nome ou o visual padrão.
# Narração, bilhetes, painéis e objetos ficam sem retrato.
func frames_de(speaker: String) -> SpriteFrames:
	if speaker == "":
		return null
	if speaker == GameManager.player_name or speaker == GameManager.get_director_title():
		return GameManager.get_appearance_frames()
	var cena: Node = get_tree().current_scene
	if cena:
		for npc in cena.find_children("*", "CharacterBody2D", true, false):
			if npc.get("npc_name") == speaker and npc.is_inside_tree() and (npc as CanvasItem).is_visible_in_tree():
				var sprite: AnimatedSprite2D = npc.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
				if sprite and sprite.sprite_frames:
					return sprite.sprite_frames
	if RETRATOS_PADRAO.has(speaker):
		return load(RETRATOS_PADRAO[speaker]) as SpriteFrames
	return null

func _mostrar_retrato(speaker: String) -> void:
	var frames: SpriteFrames = frames_de(speaker)
	if frames == null or not frames.has_animation(PREVIEW_ANIMATION) or frames.get_frame_count(PREVIEW_ANIMATION) == 0:
		retrato_moldura.visible = false
		return
	var quadro: Texture2D = frames.get_frame_texture(PREVIEW_ANIMATION, 0)
	var recorte := AtlasTexture.new()
	if quadro is AtlasTexture:
		recorte.atlas = (quadro as AtlasTexture).atlas
		recorte.region = Rect2((quadro as AtlasTexture).region.position + RETRATO_RECORTE.position, RETRATO_RECORTE.size)
	else:
		recorte.atlas = quadro
		recorte.region = RETRATO_RECORTE
	retrato.texture = recorte
	retrato_moldura.visible = true

func _on_dialogue_ended() -> void:
	panel.visible = false
	name_input_modal.visible = false

func _on_dialogue_event_triggered(event_name: String) -> void:
	if event_name == "ask_name":
		waiting_for_name = true
		name_input_modal.visible = true
		name_line_edit.text = GameManager.player_name
		male_btn.button_pressed = GameManager.player_gender != "F"
		female_btn.button_pressed = GameManager.player_gender == "F"
		_update_appearance_label()
		name_line_edit.grab_focus()
		name_line_edit.select_all()

func _process(delta: float) -> void:
	if not name_input_modal.visible:
		return
	_preview_time += delta
	if _preview_time >= PREVIEW_FRAME_TIME:
		_preview_time = 0.0
		_preview_frame += 1
		_update_preview()

func _update_preview() -> void:
	var frames: SpriteFrames = GameManager.get_appearance_frames()
	if frames == null or not frames.has_animation(PREVIEW_ANIMATION):
		return
	var count: int = frames.get_frame_count(PREVIEW_ANIMATION)
	if count > 0:
		preview_rect.texture = frames.get_frame_texture(PREVIEW_ANIMATION, _preview_frame % count)

func _cycle_appearance(step: int) -> void:
	var total: int = GameManager.APPEARANCES.size()
	GameManager.set_player_info("", "", (GameManager.player_appearance + step + total) % total)
	_update_appearance_label()

func _update_appearance_label() -> void:
	appearance_label.text = GameManager.get_appearance_name()
	_preview_frame = 0
	_update_preview()

func _on_confirm_name_pressed() -> void:
	_save_name_and_continue()

func _on_name_submitted(_new_text: String) -> void:
	_save_name_and_continue()

func _save_name_and_continue() -> void:
	var typed_name: String = name_line_edit.text.strip_edges()
	if typed_name.is_empty():
		typed_name = GameManager.get_director_title()
	GameManager.set_player_info(typed_name, "F" if female_btn.button_pressed else "M")
	waiting_for_name = false
	name_input_modal.visible = false
	DialogueManager.advance()
