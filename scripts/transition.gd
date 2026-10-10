extends CanvasLayer

# Autoload: Transition (cena scenes/ui/transition.tscn)
# Escurece a tela ao trocar de sala e mostra cartões de texto ("Mais tarde...", "Fim da Fase 1").

signal transition_finished()

const FADE_TIME: float = 0.3

@onready var fade_rect: ColorRect = $FadeRect
@onready var caption_box: VBoxContainer = $CenterContainer/CaptionBox
@onready var title_label: Label = $CenterContainer/CaptionBox/TitleLabel
@onready var subtitle_label: Label = $CenterContainer/CaptionBox/SubtitleLabel

var is_transitioning: bool = false

func _ready() -> void:
	fade_rect.modulate.a = 0.0
	caption_box.visible = false

# Troca de cena com fade. "caption" mostra um texto no meio da tela preta.
func change_scene(scene_path: String, spawn_id: String = "", caption: String = "", hold_time: float = 1.2) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	await _fade_to(1.0)
	if caption != "":
		await _show_caption(caption, "", hold_time)
	GameManager.target_spawn_id = spawn_id
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await get_tree().process_frame
	await _fade_to(0.0)
	is_transitioning = false
	transition_finished.emit()

# Mostra um cartão de título sem trocar de cena (ex.: fim de fase).
func show_card(title: String, subtitle: String = "", hold_time: float = 3.5) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	await _fade_to(1.0)
	await _show_caption(title, subtitle, hold_time)
	await _fade_to(0.0)
	is_transitioning = false
	transition_finished.emit()

func _show_caption(title: String, subtitle: String, hold_time: float) -> void:
	title_label.text = title
	subtitle_label.text = subtitle
	subtitle_label.visible = subtitle != ""
	caption_box.visible = true
	await get_tree().create_timer(hold_time).timeout
	caption_box.visible = false

func _fade_to(alpha: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", alpha, FADE_TIME)
	await tween.finished
