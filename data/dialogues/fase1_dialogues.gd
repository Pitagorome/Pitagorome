class_name Fase1Dialogues
extends RefCounted

# Falas da Fase 1 (Tasks 1 a 5), tiradas de docs/Pitagorome_Roteiro_Completo.docx.pdf
# Marcadores aceitos pelo DialogueManager:
#   {player_name}  -> nome do jogador
#   {player_title} -> Sr. / Sra.
#   {diretor}      -> Diretor / Diretora
#   {masc|fem}     -> escolhe o texto pelo gênero do jogador

const COORD: String = "Coordenadora"
const ZELADOR: String = "Zelador"
const PROF: String = "Professor de Matemática"
const PLAYER: String = "{player_name}"

static func _l(speaker: String, text: String) -> Dictionary:
	return {"speaker": speaker, "text": text}

# ---------------- Task 1 — Tour na Escola ----------------

static func tour_complete() -> Array:
	return [
		_l(COORD, "Pronto! Esses são os principais servidores e espaços da escola. O resto você vai conhecendo no dia a dia."),
		_l(COORD, "Vou te deixar descansar um pouco no seu gabinete. Já já eu passo lá."),
	]

static func zelador_idle() -> Array:
	return [_l(ZELADOR, "Não sei como conseguem sujar o chão sem sair da cadeira.")]

static func professor_idle() -> Array:
	return [_l(PROF, "Lembre-se, {diretor}: minha ajuda tem um preço... muahaha.")]

# ---------------- Task 2 — Conflito no Horário ----------------

static func task2_briefing() -> Array:
	return [
		_l(COORD, "{diretor}, temos um problema! Marcaram duas aulas no mesmo horário usando a mesma sala."),
		_l(COORD, "Reorganize a grade respeitando as regras: um professor não pode estar em duas turmas, nenhuma turma pode perder aula e cada sala, inclusive o laboratório, só comporta uma turma por vez."),
	]

static func task2_reminder() -> Array:
	return [_l(COORD, "A grade de horários ainda está com conflito. Vamos resolver?")]

static func task2_done() -> Array:
	return [
		_l(COORD, "Você conseguiu! Agora as duas turmas poderão ter aula."),
		_l(COORD, "Até que você se saiu bem para a sua primeira resolução de problema."),
		_l(COORD, "Aproveitando a situação, queria te falar que chegou uma encomenda de materiais novos."),
		_l(COORD, "Só tem um problema... o zelador guardou no almoxarifado, mas esqueceu a senha do cadeado..."),
		_l(COORD, "O almoxarifado fica no corredor, na porta de baixo à esquerda. Te encontro lá!"),
	]

# ---------------- Task 3 — O Cofre da Escola ----------------

static func task3_arrival() -> Array:
	return [
		_l(COORD, "É aquele armário com a exclamação. Zelador, você lembra de alguma coisa da senha?"),
		_l(ZELADOR, "...O cadeado tem 3 dígitos. O primeiro número é par e a soma dos três dá 12."),
		_l(ZELADOR, "Nenhum dígito se repete e eles estão em ordem crescente."),
		_l(ZELADOR, "Ah... e todos eram pares. Nenhum era zero, disso eu tenho certeza."),
		_l(COORD, "Com essas pistas dá pra descobrir. Examine o armário quando tiver a resposta, {diretor}."),
	]

static func task3_reminder() -> Array:
	return [_l(COORD, "Use as pistas do zelador para abrir o armário com a exclamação.")]

static func task3_done() -> Array:
	return [
		_l(ZELADOR, "Ugh. Eu sabia que a senha era essa."),
		_l(COORD, "Finalmente vamos poder distribuir o material aos alunos."),
		_l(COORD, "Vamos voltar pelo corredor. Acho que ouvi uma confusão por lá..."),
	]

# ---------------- Task 4 — Quem Está Matando Aula? ----------------

static func task4_briefing() -> Array:
	return [
		_l(COORD, "{diretor}, que bom que chegou. Alguém faltou à aula sem autorização."),
		_l(PROF, "Um desses três estava fora da minha aula. E eu vou descobrir quem!"),
		_l(COORD, "João, Pedro e Lucas deram depoimentos, mas apenas UM deles está mentindo."),
		_l(COORD, "Converse com os três e depois me diga quem faltou à aula."),
	]

static func task4_need_testimonies(heard: int) -> Array:
	return [_l(COORD, "Você ainda não ouviu todos os alunos (%d de 3). Converse com João, Pedro e Lucas." % heard)]

static func task4_ready() -> Array:
	return [_l(COORD, "Ouviu todos? Então me diga: quem está mentindo e matou aula?")]

static func task4_done() -> Array:
	return [
		_l(COORD, "Não acredito que você estava mentindo, Pedro... Vá para a coordenação agora!"),
		_l(PROF, "Ele vai se ver comigo na prova."),
		_l(COORD, "Bom trabalho, {diretor}. Pode voltar para o seu gabinete, o dia ainda não acabou."),
	]

# ---------------- Task 5 — O Ônibus da Excursão ----------------

static func task5_calendar() -> Array:
	return [
		_l(PLAYER, "Já estamos no último dia do trimestre! O tempo passou rápido..."),
		_l(PLAYER, "O QUÊ?! A escola tem uma excursão marcada para hoje???"),
		_l(PLAYER, "Preciso ir até o portão da escola agora!"),
	]

static func task5_briefing() -> Array:
	return [
		_l(COORD, "{diretor}, precisamos organizar os alunos nas vans da excursão, mas algumas combinações podem causar problemas durante a viagem."),
		_l(COORD, "São 2 vans com no máximo 4 passageiros cada, e cada van precisa de exatamente 1 monitor."),
	]

static func task5_reminder() -> Array:
	return [_l(COORD, "As vans ainda não estão organizadas. Vamos tentar de novo?")]

static func task5_done() -> Array:
	return [
		_l(COORD, "Espero que eles se cuidem e os monitores saibam cuidar dos alunos."),
		_l(COORD, "Mais um trimestre acabou, o seu primeiro. Você se saiu muito bem para alguém que nunca foi {diretor}."),
		_l(PLAYER, "{Obrigado|Obrigada}."),
		_l(COORD, "Bom... nos vemos amanhã no novo bimestre."),
	]

# ---------------- Dicas gerais da Coordenadora ----------------

static func hint_for_task(task_id: int) -> String:
	match task_id:
		1:
			return "Vamos continuar o tour! Fale com o Zelador no corredor e depois entre na Sala de Matemática."
		2:
			return "A grade de horários está com conflito. Volte ao seu gabinete para resolver."
		3:
			return "O material novo está trancado no almoxarifado: porta de baixo, à esquerda do corredor."
		4:
			return "Teve uma confusão no corredor com uns alunos. Vá dar uma olhada!"
		5:
			return "Já olhou o calendário do seu gabinete hoje?"
	return "Sempre que se sentir {perdido|perdida}, é só me procurar!"
