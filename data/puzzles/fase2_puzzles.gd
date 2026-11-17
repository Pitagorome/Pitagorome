class_name Fase2Puzzles
extends RefCounted

# Dados e validação dos desafios da Fase 2 (Equações, Proporções e Probabilidade).
# Fica separado da interface para poder ser testado sozinho (ver tests/test_4_logica_fase2.gd).

# ------------------------------------------------------------------
# Task 6 — O Troféu Desaparecido (equação de 1º grau)
# ------------------------------------------------------------------

# Bilhete: 2x + 6 = 36 -> x = 15 -> 15 - 3 = 12
const TROFEU_A: int = 2
const TROFEU_B: int = 6
const TROFEU_C: int = 36
const TROFEU_MENOS: int = 3
const TOTAL_ARMARIOS: int = 15

# Linha curta que fica no HUD enquanto a Task 6 não termina (para não precisar decorar o bilhete)
const BILHETE_HUD: String = "Bilhete do Zelador: 2x + 6 = 36. Pegue o x, diminua 3 e abra o armário com esse número."
const BILHETE: String = "Primeiro descubra o número escondido nesta equação:\n2x + 6 = 36\nDepois, pegue o resultado de x, diminua 3 e procure o armário com esse número."

@warning_ignore("integer_division")
static func trofeu_x() -> int:
	return (TROFEU_C - TROFEU_B) / TROFEU_A

static func trofeu_armario() -> int:
	return trofeu_x() - TROFEU_MENOS

# O que tem em cada armário errado (só para deixar a procura divertida)
const ARMARIO_CONTEUDO: Dictionary = {
	1: "uma meia perdida (só uma)",
	2: "47 provas sem nome",
	3: "uma vassoura do Zelador... reserva da reserva",
	4: "um guarda-chuva que ninguém lembra de quem é",
	5: "um sanduíche de 2019. Melhor fechar rápido",
	6: "caixas de giz colorido",
	7: "um uniforme de mascote (triângulo?!)",
	8: "bolas de futebol murchas",
	9: "a calculadora que o professor procura há meses",
	10: "cartazes da feira do ano passado",
	11: "um esfregão e um balde",
	13: "um gato de pelúcia olhando para você",
	14: "uma pilha de cadeiras dobráveis",
	15: "um mapa do tesouro desenhado por um aluno do 1º ano",
}

# Dica que aparece conforme o jogador erra (passo a passo da equação)
static func trofeu_hint(wrong_tries: int) -> String:
	if wrong_tries <= 1:
		return "Releia o bilhete: primeiro resolva 2x + 6 = 36."
	if wrong_tries == 2:
		return "Dica: tire 6 dos dois lados. Se 2x + 6 = 36, então 2x = 30."
	return "Dica: se 2x = 30, então x = 15. Agora é só diminuir 3."

# ------------------------------------------------------------------
# Task 7 — Figurinhas (proporção)
# ------------------------------------------------------------------

const MURAL_DOURADAS: int = 3
const MURAL_NORMAIS: int = 6

const CAIXAS: Array = [
	{"id": "A", "douradas": 4, "normais": 8},
	{"id": "B", "douradas": 5, "normais": 9},
	{"id": "C", "douradas": 6, "normais": 10},
]
const CAIXA_CERTA: String = "A"

# Mesma proporção que o mural? (comparação em produto cruzado, sem divisão)
static func caixa_tem_proporcao(caixa: Dictionary) -> bool:
	return int(caixa["douradas"]) * MURAL_NORMAIS == int(caixa["normais"]) * MURAL_DOURADAS

static func caixas_certas() -> Array[String]:
	var certas: Array[String] = []
	for c in CAIXAS:
		if caixa_tem_proporcao(c):
			certas.append(c["id"])
	return certas

static func caixa_texto(caixa: Dictionary) -> String:
	return "Caixa %s: %d douradas e %d normais" % [caixa["id"], caixa["douradas"], caixa["normais"]]

# ------------------------------------------------------------------
# Task 8 — O Gerador de Emergência (equação com potência e raiz)
# ------------------------------------------------------------------

const GERADOR_INICIAL: int = 8
const GERADOR_ALVO: int = 30

# O PDF perdeu o símbolo de raiz: "36(+6)" é √36 = 6, "25(+5)" é √25 = 5 etc.
const ALAVANCAS: Array = [
	{"rotulo": "√36", "valor": 6},
	{"rotulo": "√25", "valor": 5},
	{"rotulo": "3²", "valor": 9},
	{"rotulo": "2²", "valor": 4},
	{"rotulo": "√49", "valor": 7},
]

# ligadas: um bool por alavanca (mesma ordem de ALAVANCAS)
static func gerador_carga(ligadas: Array) -> int:
	var total: int = GERADOR_INICIAL
	for i in ALAVANCAS.size():
		if i < ligadas.size() and ligadas[i]:
			total += int(ALAVANCAS[i]["valor"])
	return total

# Lista vazia = carga exata. Senão, diz o que está errado.
static func validate_gerador(ligadas: Array) -> Array[String]:
	var carga: int = gerador_carga(ligadas)
	if carga == GERADOR_ALVO:
		return []
	if carga > GERADOR_ALVO:
		return ["A carga ficou em %d: passou de %d! O gerador reiniciou (e o Zelador finge que não viu)." % [carga, GERADOR_ALVO]]
	return ["A carga está em %d. Ainda faltam %d unidades para chegar a %d." % [carga, GERADOR_ALVO - carga, GERADOR_ALVO]]

# Força bruta das 2^5 combinações — usada nos testes e na explicação.
static func gerador_all_solutions() -> Array[Array]:
	var found: Array[Array] = []
	for mask in range(1 << ALAVANCAS.size()):
		var ligadas: Array = []
		for i in ALAVANCAS.size():
			ligadas.append(((mask >> i) & 1) == 1)
		if validate_gerador(ligadas).is_empty():
			found.append(ligadas)
	return found

static func gerador_descricao(ligadas: Array) -> String:
	var partes: PackedStringArray = [str(GERADOR_INICIAL)]
	for i in ALAVANCAS.size():
		if i < ligadas.size() and ligadas[i]:
			partes.append("%s(%d)" % [ALAVANCAS[i]["rotulo"], ALAVANCAS[i]["valor"]])
	if partes.size() == 1:
		return str(GERADOR_INICIAL) # nenhuma alavanca ligada
	return " + ".join(partes) + " = %d" % gerador_carga(ligadas)

# ------------------------------------------------------------------
# Task 9 — As Mesas do Refeitório (equação simples)
# ------------------------------------------------------------------

const REFEITORIO_LUGARES: int = 56
# [quantidade de mesas, cadeiras por mesa]
const MESAS_PRONTAS: Array = [[4, 8], [2, 6]]

static func cadeiras_ja_montadas() -> int:
	var total: int = 0
	for m in MESAS_PRONTAS:
		total += int(m[0]) * int(m[1])
	return total

static func cadeiras_mesa_final() -> int:
	return REFEITORIO_LUGARES - cadeiras_ja_montadas()

# ------------------------------------------------------------------
# Task 10 — O Cartaz da Feira (proporção)
# ------------------------------------------------------------------

const MODELO_LARGURA: int = 18
const MODELO_ALTURA: int = 24
const NOVA_LARGURA: int = 45

# ATENÇÃO: no roteiro os cartazes são A 27x36, B 30x40 e C 36x50. Com esses números
# A e B mantêm a proporção (os dois dão 3:4) e nenhum mede 45x60, que é a resposta
# do roteiro. Para ter UMA resposta, o B virou 45x60 e o A virou 27x40.
# Ver Explicacoes/fase2_implementacao.md (precisa da aprovação do grupo).
const CARTAZES_ROTEIRO: Array = [
	{"id": "A", "largura": 27, "altura": 36},
	{"id": "B", "largura": 30, "altura": 40},
	{"id": "C", "largura": 36, "altura": 50},
]
const CARTAZES: Array = [
	{"id": "A", "largura": 27, "altura": 40},
	{"id": "B", "largura": 45, "altura": 60},
	{"id": "C", "largura": 36, "altura": 50},
]
const CARTAZ_CERTO: String = "B"

# Regra de três: 18/24 = 45/h -> h = 24 * 45 / 18
@warning_ignore("integer_division")
static func cartaz_nova_altura() -> int:
	return MODELO_ALTURA * NOVA_LARGURA / MODELO_LARGURA

static func cartaz_tem_proporcao(cartaz: Dictionary) -> bool:
	return int(cartaz["largura"]) * MODELO_ALTURA == int(cartaz["altura"]) * MODELO_LARGURA

static func cartazes_certos(lista: Array = CARTAZES) -> Array[String]:
	var certos: Array[String] = []
	for c in lista:
		if cartaz_tem_proporcao(c) and int(c["largura"]) == NOVA_LARGURA:
			certos.append(c["id"])
	return certos

static func cartazes_proporcionais(lista: Array = CARTAZES) -> Array[String]:
	var certos: Array[String] = []
	for c in lista:
		if cartaz_tem_proporcao(c):
			certos.append(c["id"])
	return certos

static func cartaz_texto(cartaz: Dictionary) -> String:
	return "Cartaz %s: %d x %d cm" % [cartaz["id"], cartaz["largura"], cartaz["altura"]]
