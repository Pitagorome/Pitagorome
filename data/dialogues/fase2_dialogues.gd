class_name Fase2Dialogues
extends RefCounted

# Falas da Fase 2 (Tasks 6 a 10), tiradas de docs/Pitagorome_Roteiro_Completo.docx.pdf
# Marcadores: os mesmos da Fase 1 ({player_name}, {diretor}, {masc|fem}...)
# As linhas entre parênteses são narração (o que acontece na cena).

const COORD: String = "Coordenadora"
const ZELADOR: String = "Zelador"
const PROF: String = "Professor de Matemática"
const PROFESSORA: String = "Professora"
const ALUNO: String = "Aluno"
const CANTINEIRA: String = "Cantineira"
const PLAYER: String = "{player_name}"
const NARRADOR: String = ""

static func _l(speaker: String, text: String) -> Dictionary:
	return {"speaker": speaker, "text": text}

# ---------------- Início da Fase 2 ----------------

static func phase_start() -> Array:
	return [
		_l(PLAYER, "Novo trimestre, nova sala, mesmo café... O que será que vai dar errado hoje?"),
	]

# ---------------- Task 6 — O Troféu Desaparecido ----------------

static func task6_briefing() -> Array:
	return [
		_l(NARRADOR, "(A Coordenadora vem andando apressada pelo corredor.)"),
		_l(COORD, "{diretor}, temos um problema. Amanhã teremos uma inspeção e... o troféu principal da escola desapareceu."),
		_l(PLAYER, "Como alguém perde um troféu?"),
		_l(COORD, "Segundo o zelador, ele guardou em um armário para 'deixar em segurança' e depois esqueceu qual era."),
		_l(ZELADOR, "Eu não esqueci. Eu deixei duas pistas."),
		_l(NARRADOR, "(O Zelador entrega um papel.)"),
	] + bilhete() + [
		_l(COORD, "Os armários ficam na Sala dos Armários, na Ala do Refeitório. Te encontro lá!"),
	]

static func bilhete() -> Array:
	return [
		_l("Bilhete", "\"Primeiro descubra o número escondido nesta equação:  2x + 6 = 36\""),
		_l("Bilhete", "\"Depois, pegue o resultado de x, diminua 3 e procure o armário com esse número.\""),
	]

static func task6_arrival() -> Array:
	return [
		_l(COORD, "São 15 armários... Não dá para abrir um por um antes da inspeção."),
		_l(COORD, "Resolva a equação do bilhete e abra só o armário certo, {diretor}."),
	]

static func task6_reminder() -> Array:
	return [_l(COORD, "O bilhete dizia: 2x + 6 = 36. Depois é só pegar o x e diminuir 3.")]

static func task6_wrong(numero: int, conteudo: String, dica: String) -> Array:
	return [
		_l("Armário %d" % numero, "Você abre o armário %d... Dentro tem %s. Nada de troféu." % [numero, conteudo]),
		_l(COORD, dica),
	]

static func task6_done() -> Array:
	return [
		_l("Armário 12", "Você abre o armário 12... O troféu da escola está lá dentro, brilhando!"),
		_l(PLAYER, "2x + 6 = 36, então 2x = 30 e x = 15. 15 − 3 = 12. Armário 12!"),
		_l(COORD, "...e foi por isso que o diretor anterior desistiu."),
		_l(PLAYER, "Finalmente... nunca mais deixa esse zelador guardar um prêmio."),
		_l(NARRADOR, "(A Coordenadora ri.)"),
	]

# ---------------- Task 7 — Figurinhas ----------------

static func task7_briefing() -> Array:
	return [
		_l(NARRADOR, "(Vários alunos discutem em volta de um mural.)"),
		_l(PROFESSORA, "{diretor}, ainda bem que apareceu. Estamos terminando o mural da turma, mas acabamos misturando as figurinhas."),
		_l(ALUNO, "Agora ficou impossível descobrir quais eram nossas."),
		_l(NARRADOR, "(A professora aponta para três caixas.)"),
		_l(PROFESSORA, "O mural foi montado seguindo uma regra: para cada 3 figurinhas douradas, usamos 6 figurinhas normais. Só uma dessas caixas mantém essa mesma proporção."),
		_l(ALUNO, "Então precisamos descobrir qual está certa antes de colocar no mural."),
		_l(PROFESSORA, "Dê uma olhada nas caixas e depois me diga qual é a certa."),
	]

static func task7_reminder() -> Array:
	return [_l(PROFESSORA, "Lembre: 3 douradas para 6 normais. Qual caixa tem essa mesma proporção?")]

static func task7_done() -> Array:
	return [
		_l(ALUNO, "Obrigado, {diretor}! Agora a gente vai conseguir montar nosso mural."),
		_l(PROFESSORA, "Ainda bem. Eu já estava quase mandando fazer tudo de novo."),
		_l(ALUNO, "E eu já estava quase fingindo que não era da turma."),
	]

# ---------------- Task 8 — O Gerador de Emergência ----------------

static func task8_blackout() -> Array:
	return [
		_l(NARRADOR, "(De repente, a escola fica escura.)"),
		_l(COORD, "{diretor}... não entre em pânico."),
		_l(PLAYER, "...não era isso que eu queria ouvir."),
		_l(COORD, "O gerador de emergência fica na Sala do Gerador, na Ala do Refeitório. Vamos todos para lá!"),
	]

static func task8_briefing() -> Array:
	return [
		_l(ZELADOR, "O sistema trava sozinho quando a carga fica baixa."),
		_l("Painel do gerador", "\"Para reiniciar, atinja exatamente 30 unidades de carga.\""),
		_l(ZELADOR, "A carga atual é 8. Cada alavanca soma um valor... mas o fabricante escreveu tudo em potência e raiz."),
		_l(ZELADOR, "Puxa as certas. Se passar de 30, ele reinicia e eu finjo que não vi."),
	]

static func task8_reminder() -> Array:
	return [_l(ZELADOR, "Ainda está escuro. Precisa dar exatamente 30, começando do 8.")]

static func task8_done() -> Array:
	return [
		_l(NARRADOR, "(As luzes voltam a acender.)"),
		_l(ZELADOR, "Até que é bom enxergar de novo."),
		_l(COORD, "Ufa! Obrigada, {diretor}. Vou ver se ninguém aproveitou o escuro para sair mais cedo..."),
	]

# ---------------- Task 9 — As Mesas do Refeitório ----------------

static func task9_overheard() -> Array:
	return [
		_l(NARRADOR, "(Do refeitório vêm as vozes da Coordenadora e da Cantineira discutindo...)"),
	]

static func task9_briefing() -> Array:
	return [
		_l(COORD, "{diretor}, temos um problema. Amanhã teremos almoço especial e as mesas foram reorganizadas..."),
		_l(CANTINEIRA, "Eu contei tudo direitinho! Quer dizer... quase."),
		_l(COORD, "Temos 56 lugares disponíveis. Algumas mesas já foram organizadas: são 4 mesas com 8 cadeiras cada e mais 2 mesas com 6 cadeiras cada."),
		_l(COORD, "Quantas cadeiras precisamos colocar na mesa final para completar todos os lugares?"),
	]

static func task9_reminder() -> Array:
	return [_l(COORD, "São 56 lugares no total: 4 mesas de 8 e 2 mesas de 6 já estão prontas. Quantas cadeiras faltam na mesa final?")]

static func task9_done() -> Array:
	return [
		_l(CANTINEIRA, "Sabia que tinha contado certo. Só não sabia onde."),
		_l(COORD, "Ótimo trabalho. Agora só falta impedir os alunos de juntar todas as mesas."),
		_l(COORD, "Ah, o Professor de Matemática estava te procurando. Acho que ele foi para a biblioteca."),
	]

# ---------------- Task 10 — O Cartaz da Feira ----------------

static func task10_briefing() -> Array:
	return [
		_l(NARRADOR, "(O Professor de Matemática está com uma cara séria.)"),
		_l(PROF, "{diretor}, tragédia..."),
		_l(PLAYER, "...o que aconteceu?"),
		_l(PROF, "Os alunos imprimiram o cartaz da feira em tamanhos diferentes. Precisamos descobrir qual deles mantém exatamente a proporção do modelo original."),
		_l(PROF, "O modelo original tem 18 cm de largura e 24 cm de altura. Para descobrir o tamanho correto, precisamos aumentar a largura para 45 cm sem alterar a proporção."),
		_l(PROF, "Qual deve ser a nova altura?"),
	]

static func task10_reminder() -> Array:
	return [_l(PROF, "Modelo: 18 x 24. Nova largura: 45. Qual a altura, e qual cartaz tem essas medidas?")]

static func task10_height_ok() -> Array:
	return [_l(PROF, "Isso! Agora olhe os cartazes que os alunos imprimiram. Qual deles é o certo?")]

static func task10_done() -> Array:
	return [
		_l(PROF, "Excelente. Então o cartaz correto deve medir 45x60. Agora sim podemos imprimir sem transformar a feira em um anúncio de estacionamento."),
		_l(NARRADOR, "(A feira foi um sucesso! Alunos e servidores se despedem e vão para casa.)"),
	]

# ---------------- Falas soltas ----------------

# Roteiro, seção 7 — falas aleatórias de alunos
const FALAS_ALUNOS: Array[String] = [
	"{diretor}, você acha que chegar exatamente quando o portão fecha conta como atraso ou precisão?",
	"Eu estudei por 5 horas. O problema é que 4 horas e 50 foram escolhendo música.",
	"Tem gente que cola na prova. Eu só... consulto fontes externas.",
	"Eu não tô dormindo na aula. Tô processando o conteúdo de olhos fechados.",
	"Pergunta rápida: se eu acertar todas as alternativas erradas, tecnicamente eu fui consistente?",
	"Eu trouxe calculadora pra prova. Era prova de história.",
]

static func cantineira_idle() -> Array:
	return [_l(CANTINEIRA, "Todo dia alguém pergunta se pode pagar amanhã. Nunca vi esse amanhã.")]

static func professora_idle() -> Array:
	return [_l(PROFESSORA, "O mural ficou lindo. Proporção perfeita: 1 dourada para cada 2 normais!")]

static func hint_for_task(task_id: int) -> String:
	match task_id:
		6:
			return "O troféu está em um dos armários da Sala dos Armários (Ala do Refeitório). Use o bilhete do Zelador!"
		7:
			return "Ouvi uma confusão na Sala de Artes, na Ala do Refeitório."
		8:
			return "Precisamos religar o gerador! A Sala do Gerador fica na Ala do Refeitório, porta da esquerda."
		9:
			return "Me encontre no Refeitório (Ala do Refeitório, porta da direita)."
		10:
			return "O Professor de Matemática está na biblioteca te esperando."
	return "Sempre que se sentir {perdido|perdida}, é só me procurar!"
