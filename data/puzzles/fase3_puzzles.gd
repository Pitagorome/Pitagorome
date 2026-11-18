class_name Fase3Puzzles
extends RefCounted

# Dados e validação dos desafios da Fase 3 (Funções, Combinatória e Raciocínio Algébrico).
# Fica separado da interface para poder ser testado sozinho (ver tests/test_6_logica_fase3.gd).
# Os números vêm de docs/Pitagorome_Roteiro_Completo.docx.pdf (Tasks 11 a 15).

# ------------------------------------------------------------------
# Task 11 — A Máquina de Refrigerante (função afim)
# ------------------------------------------------------------------

# Registros da máquina: [quantidade de refrigerantes, preço em R$]
const MAQUINA_REGISTROS: Array = [[2, 9], [4, 15]]
const MAQUINA_PERGUNTA: int = 6 # quanto custam 6 refrigerantes?

# Passo 1: qual regra a máquina usa (as 3 opções aparecem nessa ordem)
const MAQUINA_REGRAS: Array = [
	{"texto": "y = 4,5x  (regra de três: R$ 4,50 cada)", "a": 4.5, "b": 0.0},
	{"texto": "y = 3x + 3", "a": 3.0, "b": 3.0},
	{"texto": "y = 2x + 5", "a": 2.0, "b": 5.0},
]
const MAQUINA_REGRA_CERTA: int = 1

# Coeficientes da função afim que passa pelos dois registros: y = a·x + b
static func maquina_funcao() -> Vector2:
	var p1: Array = MAQUINA_REGISTROS[0]
	var p2: Array = MAQUINA_REGISTROS[1]
	var a: float = float(p2[1] - p1[1]) / float(p2[0] - p1[0])
	var b: float = float(p1[1]) - a * float(p1[0])
	return Vector2(a, b)

static func maquina_preco(quantidade: int) -> int:
	var f: Vector2 = maquina_funcao()
	return int(round(f.x * quantidade + f.y))

# Uma regra "serve" se bate com TODOS os registros da máquina
static func regra_bate_com_registros(a: float, b: float) -> bool:
	for r in MAQUINA_REGISTROS:
		if not is_equal_approx(a * float(r[0]) + b, float(r[1])):
			return false
	return true

static func maquina_registros_texto() -> String:
	var linhas: Array[String] = []
	for r in MAQUINA_REGISTROS:
		linhas.append("%d refrigerantes = R$ %d" % [r[0], r[1]])
	return "\n".join(linhas)

# ------------------------------------------------------------------
# Task 12 — As Equipes da Gincana (combinação: a ordem NÃO importa)
# ------------------------------------------------------------------

const GINCANA_REPRESENTANTES: Array[String] = ["Ana", "Bruno", "Caio", "Duda", "Enzo", "Fê"]
const GINCANA_EQUIPE: int = 3

# Conta de verdade todos os grupos diferentes (sem fórmula), para conferir a resposta
static func grupos_possiveis(pessoas: Array, tamanho: int) -> Array:
	var grupos: Array = []
	_combinar(pessoas, tamanho, 0, [], grupos)
	return grupos

static func _combinar(pessoas: Array, tamanho: int, inicio: int, atual: Array, saida: Array) -> void:
	if atual.size() == tamanho:
		saida.append(atual.duplicate())
		return
	for i in range(inicio, pessoas.size()):
		atual.append(pessoas[i])
		_combinar(pessoas, tamanho, i + 1, atual, saida)
		atual.pop_back()

static func gincana_resposta() -> int:
	return grupos_possiveis(GINCANA_REPRESENTANTES, GINCANA_EQUIPE).size()

# ------------------------------------------------------------------
# Task 13 — As Luzes do Corredor (raciocínio algébrico)
# ------------------------------------------------------------------

const LUZES_TOTAL: int = 20
const LUZES_DIFERENCA: int = 4 # o interruptor B controla 4 lâmpadas a mais que o A

# Passo 1: qual equação representa o problema
const LUZES_EQUACOES: Array[String] = [
	"x + 4 = 20",
	"x + (x + 4) = 20",
	"2x = 20 + 4",
]
const LUZES_EQUACAO_CERTA: int = 1

@warning_ignore("integer_division")
static func luzes_a() -> int:
	return (LUZES_TOTAL - LUZES_DIFERENCA) / 2

static func luzes_b() -> int:
	return luzes_a() + LUZES_DIFERENCA

# ------------------------------------------------------------------
# Task 14 — O Lugar da Foto Oficial (arranjo: cada lugar é diferente)
# ------------------------------------------------------------------

const FOTO_PROFESSORES: Array[String] = ["Prof. Matemática", "Prof.ª Artes", "Prof. História", "Prof.ª Português", "Prof. Ed. Física"]
# Os 3 lugares marcados no chão. Cada lugar é diferente na foto, então trocar duas
# pessoas de lugar dá uma foto diferente (por isso a resposta do roteiro é 60, e não 30).
const FOTO_LUGARES: Array[String] = ["Atrás, à esquerda", "Atrás, à direita", "Na frente"]

# Conta de verdade todas as formações (pessoa em cada lugar, sem repetir ninguém)
static func formacoes_possiveis(pessoas: Array, lugares: int) -> Array:
	var formacoes: Array = []
	_arranjar(pessoas, lugares, [], formacoes)
	return formacoes

static func _arranjar(pessoas: Array, lugares: int, atual: Array, saida: Array) -> void:
	if atual.size() == lugares:
		saida.append(atual.duplicate())
		return
	for p in pessoas:
		if not atual.has(p):
			atual.append(p)
			_arranjar(pessoas, lugares, atual, saida)
			atual.pop_back()

static func foto_resposta() -> int:
	return formacoes_possiveis(FOTO_PROFESSORES, FOTO_LUGARES.size()).size()

# ------------------------------------------------------------------
# Task 15 — A Decoração do Pátio (arranjo: a ordem das placas importa)
# ------------------------------------------------------------------

const PLACAS: Array[String] = ["Bem-vindos", "Obrigado!", "Boas férias", "Pitagórica", "Até 2027", "Turma 3º ano"]
const PLACAS_NO_MURAL: int = 3

static func mural_resposta() -> int:
	return formacoes_possiveis(PLACAS, PLACAS_NO_MURAL).size()

# ------------------------------------------------------------------
# Dicas para respostas erradas "esperadas" (o erro mais comum de cada conta)
# ------------------------------------------------------------------

static func gincana_dicas() -> Dictionary:
	return {
		"120": "Você contou a ORDEM das pessoas. Numa equipe, Ana-Bruno-Caio é a mesma equipe que Caio-Bruno-Ana. Cada equipe apareceu 6 vezes na sua conta (3 × 2 × 1).",
		"18": "Quase! Experimente listar: Ana-Bruno-Caio, Ana-Bruno-Duda, Ana-Bruno-Enzo... Comece todas com a Ana, depois todas com o Bruno sem a Ana, e assim por diante.",
		"6": "6 é o número de representantes. A pergunta é quantas EQUIPES de 3 dá para formar com eles.",
	}

static func foto_dicas() -> Dictionary:
	return {
		"10": "Você contou só QUEM vai para a foto. Mas o lugar de cada professor também muda a foto: trocar dois professores de lugar dá outra formação.",
		"30": "Os dois lugares de trás também são diferentes (esquerda e direita)! Trocar os dois de lugar dá outra foto.",
		"15": "Pense lugar por lugar: quantos professores podem ir no 1º lugar? E no 2º (sem repetir)? E no 3º?",
	}

static func mural_dicas() -> Dictionary:
	return {
		"20": "Você contou só QUAIS placas vão no mural. Mas o Zelador disse que a posição de cada placa muda o resultado: a ordem importa!",
		"18": "Não é 6 × 3. Pense posição por posição: quantas placas podem ir na 1ª posição? E na 2ª (sem repetir a 1ª)? E na 3ª?",
		"216": "Assim a mesma placa poderia aparecer duas vezes. Depois de colocar uma placa, sobram 5 para a próxima posição, e depois 4.",
	}
