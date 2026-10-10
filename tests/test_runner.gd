extends Node

# Executor dos testes automatizados do Pitagorome.
#
# Como rodar (na pasta Pitagorome):
#   Godot_v4.6.2-stable_win64_console.exe --headless --path . res://tests/test_runner.tscn
# Para salvar o resultado em JSON:
#   ... res://tests/test_runner.tscn -- --results=C:/caminho/resultado.json
# Também dá para abrir tests/test_runner.tscn no editor e apertar F6.

const SUITES: Array = [
	preload("res://tests/test_1_logica_desafios.gd"),
	preload("res://tests/test_2_cenas.gd"),
	preload("res://tests/test_3_fluxo_fase1.gd"),
]

func _ready() -> void:
	# O runner sai da posição de "cena atual" para não ser apagado quando os testes trocarem de cena
	get_tree().current_scene = null
	_run.call_deferred()

func _run() -> void:
	var results: Array = []
	var all_passed: bool = true
	var started: String = Time.get_datetime_string_from_system(false, true)
	print("\n===== TESTES AUTOMATIZADOS — PITAGOROME (Fase 1) =====")
	for suite_script in SUITES:
		var suite = suite_script.new()
		suite.runner = self
		print("\n>> ", suite.suite_name)
		await suite.run()
		print("   %d/%d casos passaram" % [suite.passed_count(), suite.cases.size()])
		results.append(suite.to_dict())
		if suite.passed_count() != suite.cases.size():
			all_passed = false

	var report: Dictionary = {
		"started": started,
		"godot": Engine.get_version_info()["string"],
		"all_passed": all_passed,
		"suites": results,
	}
	_save(report)
	print("\n===== RESULTADO: %s =====\n" % ("TODOS PASSARAM" if all_passed else "HÁ FALHAS"))
	get_tree().quit(0 if all_passed else 1)

func _save(report: Dictionary) -> void:
	var path: String = "user://test_results.json"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--results="):
			path = arg.trim_prefix("--results=")
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(report, "  "))
		print("Resultado salvo em: ", ProjectSettings.globalize_path(path))
