class_name Fase1Puzzles
extends RefCounted

# Dados e validação dos desafios da Fase 1 (Lógica e Organização).
# Fica separado da interface para poder ser testado sozinho (ver tests/).

# ------------------------------------------------------------------
# Task 2 — Conflito no Horário
# ------------------------------------------------------------------
# Versão mais difícil (17/11): antes eram 4 aulas e bastava mudar UMA para resolver.
# Agora são 6 aulas (Matemática, Português e Ciências do 1º A e do 2º B), 3 horários,
# 2 salas + o Laboratório, e dois professores com horário limitado. A grade inicial
# quebra 4 regras diferentes e precisa de 5 mudanças. Só existem 2 jeitos de distribuir
# os horários (o resto é escolher Sala 1 ou Sala 2) — ver tests/test_1_logica_desafios.gd.

const SALA_COMUM: String = "Sala 1"
const SALA_2: String = "Sala 2"
const LABORATORIO: String = "Laboratório"
const SCHEDULE_SALAS: Array[String] = [SALA_COMUM, SALA_2, LABORATORIO]
const SCHEDULE_HORARIOS: int = 3

# Índice 0 = aula cancelada. Os outros índices são [horário, sala]:
# 1-3 = 1º horário (Sala 1, Sala 2, Lab.), 4-6 = 2º horário, 7-9 = 3º horário.
const SCHEDULE_SLOTS: Array = [
	"— Cancelar aula —",
	"1º horário · Sala 1",
	"1º horário · Sala 2",
	"1º horário · Laboratório",
	"2º horário · Sala 1",
	"2º horário · Sala 2",
	"2º horário · Laboratório",
	"3º horário · Sala 1",
	"3º horário · Sala 2",
	"3º horário · Laboratório",
]
const SLOT_INFO: Dictionary = {
	1: [1, SALA_COMUM], 2: [1, SALA_2], 3: [1, LABORATORIO],
	4: [2, SALA_COMUM], 5: [2, SALA_2], 6: [2, LABORATORIO],
	7: [3, SALA_COMUM], 8: [3, SALA_2], 9: [3, LABORATORIO],
}

const SCHEDULE_CLASSES: Array = [
	{"id": "mat_1a", "disciplina": "Matemática", "turma": "1º A", "professor": "Prof. Carlos", "precisa_lab": false},
	{"id": "por_1a", "disciplina": "Português", "turma": "1º A", "professor": "Profa. Rita", "precisa_lab": false},
	{"id": "cie_1a", "disciplina": "Ciências", "turma": "1º A", "professor": "Profa. Helena", "precisa_lab": true},
	{"id": "mat_2b", "disciplina": "Matemática", "turma": "2º B", "professor": "Prof. Carlos", "precisa_lab": false},
	{"id": "por_2b", "disciplina": "Português", "turma": "2º B", "professor": "Profa. Rita", "precisa_lab": false},
	{"id": "cie_2b", "disciplina": "Ciências", "turma": "2º B", "professor": "Profa. Helena", "precisa_lab": true},
]

# Horários em que cada professor pode dar aula (quem não está aqui pode em todos)
const SCHEDULE_DISPONIVEL: Dictionary = {
	"Prof. Carlos": [2, 3], # só chega na escola no 2º horário
	"Profa. Rita": [1, 2],  # vai embora depois do 2º horário
}
const SCHEDULE_DISPONIVEL_TEXTO: Dictionary = {
	"Prof. Carlos": "só chega no 2º horário",
	"Profa. Rita": "vai embora depois do 2º horário",
}

# Grade com os conflitos: as duas Matemáticas no 1º horário da Sala 1 (mesma sala e mesmo
# professor, e o Prof. Carlos ainda nem chegou) e Português do 2º B no 3º horário (a Profa.
# Rita já foi embora).
const SCHEDULE_INITIAL: Dictionary = {"mat_1a": 1, "por_1a": 5, "cie_1a": 9, "mat_2b": 1, "por_2b": 8, "cie_2b": 6}
# Uma das grades certas (usada pelos testes e pelos prints; o jogo não mostra)
const SCHEDULE_SOLUTION: Dictionary = {"mat_1a": 4, "por_1a": 1, "cie_1a": 9, "mat_2b": 7, "por_2b": 5, "cie_2b": 3}

static func get_class_label(class_data: Dictionary) -> String:
	return "%s %s (%s)" % [class_data["disciplina"], class_data["turma"], class_data["professor"]]

static func slot_of(horario: int, sala: String) -> int:
	return 1 + (horario - 1) * SCHEDULE_SALAS.size() + SCHEDULE_SALAS.find(sala)

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
		elif not class_data["precisa_lab"] and sala == LABORATORIO:
			errors.append("O Laboratório é só para as aulas de Ciências (%s do %s está lá)." % [class_data["disciplina"], class_data["turma"]])
		var professor: String = class_data["professor"]
		if SCHEDULE_DISPONIVEL.has(professor) and not SCHEDULE_DISPONIVEL[professor].has(horario):
			errors.append("%s %s, mas a aula de %s do %s está no %dº horário." % [professor, SCHEDULE_DISPONIVEL_TEXTO[professor], class_data["disciplina"], class_data["turma"], horario])

		_append_to(by_room, "%d|%s" % [horario, sala], class_data)
		_append_to(by_teacher, "%d|%s" % [horario, professor], class_data)
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
# A ordem da lista é embaralhada de propósito: antes a resposta alternava Van 1 / Van 2
# na ordem em que os nomes apareciam, e dava para acertar sem pensar.
const VAN_PARTICIPANTS: Array = [
	{"id": "maria", "nome": "Maria", "monitor": false},
	{"id": "carlos", "nome": "Carlos", "monitor": false},
	{"id": "rafael", "nome": "Monitor Rafael", "monitor": true},
	{"id": "joao", "nome": "João", "monitor": false},
	{"id": "beatriz", "nome": "Monitora Beatriz", "monitor": true},
	{"id": "lucas", "nome": "Lucas", "monitor": false},
	{"id": "ana", "nome": "Ana", "monitor": false},
	{"id": "pedro", "nome": "Pedro", "monitor": false},
]
# As 6 primeiras são do roteiro. As 2 últimas (Pedro na Van 1 e Beatriz longe do Lucas)
# foram adicionadas para deixar a tarefa mais difícil: agora existe UMA única resposta,
# e para chegar nela é preciso usar a regra dos 4 passageiros (ver Explicacoes/fase2_implementacao.md).
const VAN_RULES: Array = [
	"João e Pedro não podem viajar juntos (brigaram recentemente).",
	"Ana e Lucas devem ficar em vans diferentes (cada um lidera um grupo).",
	"Maria deve viajar com Ana.",
	"Carlos não pode viajar na mesma van que João.",
	"Cada van deve ter exatamente 1 monitor.",
	"Nenhuma van pode passar de 4 passageiros.",
	"Pedro passa mal na estrada: ele precisa ir na Van 1, a que tem ar-condicionado.",
	"A Monitora Beatriz não pode ir na mesma van que o Lucas (é tia dele e ele não para de pedir lanche).",
]
# Raciocínio: Pedro na Van 1 -> João na Van 2 -> Carlos na Van 1. Se Ana e Maria fossem na Van 1,
# ela teria Pedro, Carlos, Ana, Maria + monitor = 5. Então Ana e Maria vão na Van 2 e Lucas na Van 1.
# Beatriz não vai com Lucas -> Beatriz na Van 2 e Rafael na Van 1.
const VAN_SOLUTION: Dictionary = {
	"pedro": 1, "carlos": 1, "lucas": 1, "rafael": 1,
	"joao": 2, "ana": 2, "maria": 2, "beatriz": 2,
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
	if v.call("pedro") == 2:
		errors.append("Pedro passa mal na estrada: ele precisa ir na Van 1.")
	if v.call("beatriz") != 0 and v.call("beatriz") == v.call("lucas"):
		errors.append("A Monitora Beatriz não pode ir na mesma van que o Lucas.")
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
