class_name Fase1Puzzles
extends RefCounted

# Dados e validação dos desafios da Fase 1 (Lógica e Organização).
# Fica separado da interface para poder ser testado sozinho (ver tests/).

# ------------------------------------------------------------------
# Task 2 — Conflito no Horário
# ------------------------------------------------------------------

const SALA_COMUM: String = "Sala 1"
const LABORATORIO: String = "Laboratório"

# Índice 0 = aula cancelada. Os outros índices são [horário, sala].
const SCHEDULE_SLOTS: Array = [
	"— Cancelar aula —",
	"1º horário · Sala 1",
	"1º horário · Laboratório",
	"2º horário · Sala 1",
	"2º horário · Laboratório",
]
const SLOT_INFO: Dictionary = {
	1: [1, SALA_COMUM],
	2: [1, LABORATORIO],
	3: [2, SALA_COMUM],
	4: [2, LABORATORIO],
}

const SCHEDULE_CLASSES: Array = [
	{"id": "mat_1a", "disciplina": "Matemática", "turma": "1º A", "professor": "Prof. Carlos", "precisa_lab": false},
	{"id": "mat_2b", "disciplina": "Matemática", "turma": "2º B", "professor": "Prof. Carlos", "precisa_lab": false},
	{"id": "cie_1a", "disciplina": "Ciências", "turma": "1º A", "professor": "Profa. Helena", "precisa_lab": true},
	{"id": "cie_2b", "disciplina": "Ciências", "turma": "2º B", "professor": "Profa. Helena", "precisa_lab": true},
]

# Grade com o conflito: as duas aulas de Matemática no 1º horário da Sala 1.
const SCHEDULE_INITIAL: Dictionary = {"mat_1a": 1, "mat_2b": 1, "cie_1a": 4, "cie_2b": 2}

static func get_class_label(class_data: Dictionary) -> String:
	return "%s — %s (%s)" % [class_data["disciplina"], class_data["turma"], class_data["professor"]]

# Retorna a lista de regras quebradas. Lista vazia = grade válida.
static func validate_schedule(assignment: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var by_room: Dictionary = {}
	var by_teacher: Dictionary = {}
	var by_group: Dictionary = {}

	for class_data in SCHEDULE_CLASSES:
		var slot: int = int(assignment.get(class_data["id"], 0))
		if not SLOT_INFO.has(slot):
			errors.append("A turma %s ficou sem a aula de %s. Nenhuma turma pode perder aula!" % [class_data["turma"], class_data["disciplina"]])
			continue

		var horario: int = SLOT_INFO[slot][0]
		var sala: String = SLOT_INFO[slot][1]
		if class_data["precisa_lab"] and sala != LABORATORIO:
			errors.append("A aula de %s do %s precisa acontecer no Laboratório." % [class_data["disciplina"], class_data["turma"]])

		_append_to(by_room, "%d|%s" % [horario, sala], class_data)
		_append_to(by_teacher, "%d|%s" % [horario, class_data["professor"]], class_data)
		_append_to(by_group, "%d|%s" % [horario, class_data["turma"]], class_data)

	for key in by_room:
		if by_room[key].size() > 1:
			var parts: PackedStringArray = key.split("|")
			errors.append("%s no %sº horário está com %d turmas ao mesmo tempo. Cada sala comporta só uma turma!" % [parts[1], parts[0], by_room[key].size()])
	for key in by_teacher:
		if by_teacher[key].size() > 1:
			var parts: PackedStringArray = key.split("|")
			errors.append("%s estaria em duas turmas no %sº horário. Um professor não pode estar em dois lugares!" % [parts[1], parts[0]])
	for key in by_group:
		if by_group[key].size() > 1:
			var parts: PackedStringArray = key.split("|")
			errors.append("A turma %s teria duas aulas ao mesmo tempo no %sº horário." % [parts[1], parts[0]])
	return errors

static func _append_to(groups: Dictionary, key: String, value: Variant) -> void:
	if not groups.has(key):
		groups[key] = []
	groups[key].append(value)

# ------------------------------------------------------------------
# Task 3 — O Cofre da Escola
# ------------------------------------------------------------------

const COFRE_SENHA: String = "246"

# Pistas do roteiro + uma pista extra do Zelador. Sem a pista extra existem
# 5 senhas possíveis (039, 048, 057, 237, 246) — ver Explicacoes/fase1.md.
const COFRE_PISTAS: Array = [
	"O cadeado possui 3 dígitos.",
	"O primeiro número é PAR.",
	"A soma dos 3 números é 12.",
	"Nenhum dígito se repete e estão em ordem CRESCENTE.",
	"(Zelador) Todos os números eram pares... e nenhum era zero.",
]

static func normalize_code(code: String) -> String:
	return code.replace(" ", "").replace("-", "").strip_edges()

# Diz quais pistas a senha digitada quebra (útil para o feedback e para os testes).
static func cofre_broken_clues(code: String, with_extra_clue: bool = true) -> Array[String]:
	var broken: Array[String] = []
	var clean: String = normalize_code(code)
	if clean.length() != 3 or not clean.is_valid_int():
		broken.append(COFRE_PISTAS[0])
		return broken
	var d: Array[int] = [int(clean[0]), int(clean[1]), int(clean[2])]
	if d[0] % 2 != 0:
		broken.append(COFRE_PISTAS[1])
	if d[0] + d[1] + d[2] != 12:
		broken.append(COFRE_PISTAS[2])
	if not (d[0] < d[1] and d[1] < d[2]):
		broken.append(COFRE_PISTAS[3])
	if with_extra_clue:
		for digit in d:
			if digit % 2 != 0 or digit == 0:
				broken.append(COFRE_PISTAS[4])
				break
	return broken

static func cofre_all_solutions(with_extra_clue: bool = true) -> Array[String]:
	var found: Array[String] = []
	for n in range(1000):
		var code: String = "%03d" % n
		if cofre_broken_clues(code, with_extra_clue).is_empty():
			found.append(code)
	return found

# ------------------------------------------------------------------
# Task 4 — Quem Está Matando Aula?
# ------------------------------------------------------------------

const SUSPECTS: Array = [
	{"id": "joao", "nome": "João", "fala": "Pedro estava comigo na biblioteca."},
	{"id": "pedro", "nome": "Pedro", "fala": "Eu não fui para a biblioteca."},
	{"id": "lucas", "nome": "Lucas", "fala": "João está falando a verdade."},
]
const CULPADO: String = "pedro"

# Testa todos os cenários (quem mente × Pedro foi ou não à biblioteca) e devolve
# quem pode ser o único mentiroso sem contradição.
static func find_consistent_liars() -> Array[String]:
	var result: Array[String] = []
	for liar in ["joao", "pedro", "lucas"]:
		for pedro_na_biblioteca in [true, false]:
			var joao_diz: bool = pedro_na_biblioteca
			var pedro_diz: bool = not pedro_na_biblioteca
			var joao_sincero: bool = liar != "joao"
			var lucas_diz: bool = joao_sincero
			var ok: bool = joao_diz == (liar != "joao") and pedro_diz == (liar != "pedro") and lucas_diz == (liar != "lucas")
			if ok and not result.has(liar):
				result.append(liar)
	return result

# ------------------------------------------------------------------
# Task 5 — O Ônibus da Excursão
# ------------------------------------------------------------------

const VAN_CAPACITY: int = 4
const VAN_PARTICIPANTS: Array = [
	{"id": "joao", "nome": "João", "monitor": false},
	{"id": "pedro", "nome": "Pedro", "monitor": false},
	{"id": "ana", "nome": "Ana", "monitor": false},
	{"id": "lucas", "nome": "Lucas", "monitor": false},
	{"id": "maria", "nome": "Maria", "monitor": false},
	{"id": "carlos", "nome": "Carlos", "monitor": false},
	{"id": "rafael", "nome": "Monitor Rafael", "monitor": true},
	{"id": "beatriz", "nome": "Monitora Beatriz", "monitor": true},
]
const VAN_RULES: Array = [
	"João e Pedro não podem viajar juntos (brigaram recentemente).",
	"Ana e Lucas devem ficar em vans diferentes (cada um lidera um grupo).",
	"Maria deve viajar com Ana.",
	"Carlos não pode viajar na mesma van que João.",
	"Cada van deve ter exatamente 1 monitor.",
	"Nenhuma van pode passar de 4 passageiros.",
]
const VAN_SOLUTION: Dictionary = {
	"joao": 1, "ana": 1, "maria": 1, "rafael": 1,
	"pedro": 2, "lucas": 2, "carlos": 2, "beatriz": 2,
}

# assignment: id -> 0 (sem van), 1 ou 2. Lista vazia = distribuição válida.
static func validate_vans(assignment: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var count: Dictionary = {1: 0, 2: 0}
	var monitors: Dictionary = {1: 0, 2: 0}

	for p in VAN_PARTICIPANTS:
		var van: int = int(assignment.get(p["id"], 0))
		if van != 1 and van != 2:
			errors.append("%s ainda não tem van." % p["nome"])
			continue
		count[van] += 1
		if p["monitor"]:
			monitors[van] += 1

	for van in [1, 2]:
		if count[van] > VAN_CAPACITY:
			errors.append("A Van %d está com %d passageiros (máximo %d)." % [van, count[van], VAN_CAPACITY])
		if monitors[van] != 1:
			errors.append("A Van %d precisa de exatamente 1 monitor (tem %d)." % [van, monitors[van]])

	var v: Callable = func(id: String) -> int: return int(assignment.get(id, 0))
	if v.call("joao") != 0 and v.call("joao") == v.call("pedro"):
		errors.append("João e Pedro brigaram: não podem viajar juntos.")
	if v.call("ana") != 0 and v.call("ana") == v.call("lucas"):
		errors.append("Ana e Lucas precisam liderar grupos em vans diferentes.")
	if v.call("maria") != 0 and v.call("maria") != v.call("ana"):
		errors.append("Maria deve viajar com Ana.")
	if v.call("carlos") != 0 and v.call("carlos") == v.call("joao"):
		errors.append("Carlos não pode viajar na mesma van que João.")
	return errors

# Força bruta das 2^8 distribuições — usada nos testes para provar que existe solução.
static func van_all_solutions() -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	var ids: Array = VAN_PARTICIPANTS.map(func(p): return p["id"])
	for mask in range(1 << ids.size()):
		var assignment: Dictionary = {}
		for i in ids.size():
			assignment[ids[i]] = 2 if (mask >> i) & 1 else 1
		if validate_vans(assignment).is_empty():
			found.append(assignment)
	return found
