extends CanvasLayer

# =====================================================================
# Versão do jogo e canal (TESTE ou FINAL)
# ---------------------------------------------------------------------
# - O número vem de Projeto > Configurações > Aplicação > Config > Versão
#   (application/config/version no project.godot). Regras em VERSOES.md.
# - O canal vem do PRESET de exportação, não do número:
#     presets "... - TESTE" têm a feature tag "teste"  -> build de teste
#     presets "... - FINAL" não têm                    -> build final
# - Rodando pelo editor do Godot conta como teste (para os botões de pular
#   fase continuarem aparecendo enquanto vocês desenvolvem), mas a marca
#   "VERSÃO DE TESTE" só aparece nas builds exportadas de teste.
# =====================================================================

var marca: Label

func numero() -> String:
	return str(ProjectSettings.get_setting("application/config/version", "0.0.0"))

func exportado_teste() -> bool:
	return OS.has_feature("teste")

# Teste = build exportada de teste OU rodando pelo editor.
func eh_teste() -> bool:
	return OS.has_feature("teste") or OS.has_feature("editor")

# Ex.: "v0.3.0-teste" ou "v1.0.0"
func texto() -> String:
	return "v" + numero() + ("-teste" if exportado_teste() else "")

func _ready() -> void:
	layer = 100 # por cima de tudo, mas só um textinho no canto
	if not exportado_teste():
		return
	marca = Label.new()
	marca.text = "VERSÃO DE TESTE  " + texto()
	marca.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marca.add_theme_font_size_override("font_size", 7)
	marca.add_theme_color_override("font_color", Color(1, 0.95, 0.8, 0.55))
	marca.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	marca.add_theme_constant_override("shadow_offset_x", 1)
	marca.add_theme_constant_override("shadow_offset_y", 1)
	# canto inferior esquerdo (não cobre minimapa, prancheta nem diálogo)
	marca.anchor_top = 1.0
	marca.anchor_bottom = 1.0
	marca.offset_left = 4
	marca.offset_top = -12
	marca.offset_bottom = -2
	marca.offset_right = 200
	add_child(marca)
