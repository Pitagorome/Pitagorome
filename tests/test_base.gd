extends RefCounted

# Base das suítes de teste automatizado do Pitagorome.
# Cada suíte tem casos; cada caso faz várias verificações (check).
# Rodar: ver tests/test_runner.gd ou Explicacoes/como_testar.md

var suite_name: String = "Suíte"
var suite_description: String = ""
var runner: Node = null # nó do test_runner (dá acesso à árvore de cenas)
var cases: Array = []

var _current: Dictionary = {}

func tree() -> SceneTree:
	return runner.get_tree()

# Lista de casos: [[nome, Callable], ...] — implementado pelas suítes
func get_cases() -> Array:
	return []

func run() -> void:
	for entry in get_cases():
		_current = {"name": entry[0], "checks": [], "passed": true, "error": ""}
		var started: int = Time.get_ticks_msec()
		await entry[1].call()
		_current["time_ms"] = Time.get_ticks_msec() - started
		cases.append(_current)
		var mark: String = "OK  " if _current["passed"] else "FALHOU"
		print("  [%s] %s (%d ms)" % [mark, _current["name"], _current["time_ms"]])
		if not _current["passed"]:
			for c in _current["checks"]:
				if not c["ok"]:
					print("        x ", c["desc"])

func check(condition: bool, description: String) -> bool:
	_current["checks"].append({"ok": condition, "desc": description})
	if not condition:
		_current["passed"] = false
	return condition

func check_eq(actual: Variant, expected: Variant, description: String) -> bool:
	var ok: bool = actual == expected
	return check(ok, description if ok else "%s (esperado: %s, obtido: %s)" % [description, str(expected), str(actual)])

func note(text: String) -> void:
	# Registro informativo que vai para o relatório (não conta como verificação)
	_current["checks"].append({"ok": true, "desc": "[info] " + text})

func passed_count() -> int:
	return cases.filter(func(c): return c["passed"]).size()

func to_dict() -> Dictionary:
	return {"suite": suite_name, "description": suite_description, "cases": cases, "passed": passed_count(), "total": cases.size()}
