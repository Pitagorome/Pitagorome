class_name Fase3Dialogues
extends RefCounted

# Falas da Fase 3 (Tasks 11 a 15) e do Encerramento, tiradas de docs/Pitagorome_Roteiro_Completo.docx.pdf
# Marcadores: os mesmos das outras fases ({player_name}, {diretor}, {masc|fem}...)
# As linhas entre parênteses são narração (o que acontece na cena).

const COORD: String = "Coordenadora"
const ZELADOR: String = "Zelador"
const PROF: String = "Professor de Matemática"
const ALUNO: String = "Aluno"
const OUTRO_ALUNO: String = "Outro aluno"
const CANTINEIRA: String = "Cantineira"
const SECRETARIA: String = "Secretária"
const PLAYER: String = "{player_name}"
const NARRADOR: String = ""

static func _l(speaker: String, text: String) -> Dictionary:
	return {"speaker": speaker, "text": text}

# ---------------- Task 11 — A Máquina de Refrigerante ----------------

static func task11_chamado() -> Array:
	return [
		_l(NARRADOR, "(Primeiro dia do 3º trimestre. Tudo parecia calmo... até um aluno entrar correndo no gabinete.)"),
		_l(ALUNO, "{DIRETOR|DIRETORA}! Temos um problema muito sério na cantina. Me acompanha!"),
	]

static func task11_briefing() -> Array:
	return [
		_l(NARRADOR, "(Os dois chegam com pressa ao Refeitório e encontram... uma máquina de refrigerante.)"),
		_l(PLAYER, "Uma máquina de refrigerante... sério?"),
		_l(ALUNO, "Isso é de extrema importância."),
		_l(CANTINEIRA, "{diretor}, instalaram essa máquina ontem e ela tá cobrando de um jeito estranho. O técnico disse que segue uma função, mas ninguém entendeu."),
		_l(ALUNO, "Eu tentei fazer uma regra de três. Não funcionou."),
		_l(COORD, "Se descobrirmos o padrão, conseguimos configurar o preço correto."),
		_l(COORD, "Os registros estão no visor da máquina. Dá uma olhada, {diretor}."),
	]

static func task11_reminder() -> Array:
	return [_l(COORD, "O visor da máquina mostra os preços que ela já cobrou. Descubra a regra e o preço de 6 refrigerantes.")]

static func task11_regra_ok() -> Array:
	return [_l(CANTINEIRA, "Então ela cobra R$ 3 por refrigerante, mais R$ 3 fixos? Que máquina esquisita... E quanto ficam 6?")]

static func task11_done() -> Array:
	return [
		_l(CANTINEIRA, "Perfeito. Agora o problema voltou a ser só o preço."),
		_l(ALUNO, "Então eu não estava sem dinheiro... eu estava sem função."),
	]

# ---------------- Task 12 — As Equipes da Gincana ----------------

static func task12_gabinete() -> Array:
	return [
		_l(NARRADOR, "(De volta ao gabinete, a Coordenadora já está esperando.)"),
		_l(COORD, "Para o início do 3º trimestre, os alunos terão uma gincana. Vamos comigo até o pátio."),
	]

static func task12_briefing() -> Array:
	return [
		_l(NARRADOR, "(No pátio, os alunos estão com coletes coloridos.)"),
		_l(ALUNO, "Essa equipe tá roubada!"),
		_l(OUTRO_ALUNO, "Se trocasse uma pessoa já ficava diferente!"),
		_l(COORD, "Os professores já montaram algumas equipes para a primeira prova, mas os alunos começaram a reclamar que existem poucas combinações e que algumas pessoas estão aparecendo em todos os grupos."),
		_l(PLAYER, "Então o que eles querem?"),
		_l(COORD, "Querem saber quantas equipes diferentes de 3 alunos realmente poderiam ser formadas com os alunos inscritos. Se tivermos muitas possibilidades, vamos fazer sorteio."),
		_l(COORD, "São 6 representantes, os nomes estão no quadro da gincana. Só 3 vão para a final."),
	]

static func task12_reminder() -> Array:
	return [_l(COORD, "São 6 representantes e a equipe da final tem 3. Quantas equipes diferentes dá para formar?")]

static func task12_done() -> Array:
	return [
		_l(COORD, "20 possibilidades... então realmente não fazia sentido insistir sempre nas mesmas equipes."),
		_l(ALUNO, "...ok, o sorteio parece menos suspeito agora."),
	]

# ---------------- Task 13 — As Luzes do Corredor ----------------

static func task13_briefing() -> Array:
	return [
		_l(NARRADOR, "(No corredor, a Coordenadora está em frente à Sala de Matemática, que está toda escura, olhando as lâmpadas.)"),
		_l(COORD, "{diretor}, temos um problema."),
		_l(PLAYER, "O que é dessa vez?"),
		_l(COORD, "As luzes desta sala foram divididas entre dois interruptores, mas precisamos descobrir quantas lâmpadas cada um controla."),
		_l(NARRADOR, "(Um aluno se aproxima.)"),
		_l(ALUNO, "A professora disse que o segundo interruptor controla 4 lâmpadas a mais que o primeiro. Juntos, eles controlam 20 lâmpadas."),
		_l(COORD, "Os interruptores estão no painel ao lado da porta."),
	]

static func task13_reminder() -> Array:
	return [_l(COORD, "O interruptor A controla x lâmpadas. O B controla 4 a mais. Juntos são 20. Monte a equação!")]

static func task13_equacao_ok() -> Array:
	return [_l(COORD, "Isso, essa é a equação. Agora resolva: quantas lâmpadas o interruptor A controla?")]

static func task13_done() -> Array:
	return [
		_l(NARRADOR, "(Click! Click! As 20 lâmpadas da Sala de Matemática acendem.)"),
		_l(ALUNO, "Agora só falta descobrir quem trocou os interruptores de lugar."),
	]

# ---------------- Task 14 — O Lugar da Foto Oficial ----------------

static func task14_briefing() -> Array:
	return [
		_l(NARRADOR, "(A escola vai participar de uma feira educacional e precisa de uma equipe para a foto oficial do evento.)"),
		_l(COORD, "{diretor}, temos 5 professores disponíveis, mas a organização pediu que apenas 3 participem da foto."),
		_l(PLAYER, "Então é só escolher três deles."),
		_l(COORD, "Não é tão simples. Dois professores ficarão na fila de trás e um ficará na frente. Precisamos descobrir de quantas formas diferentes podemos montar essa equipe."),
		_l(COORD, "Os 3 lugares estão marcados no chão. Cada lugar é diferente na foto, então trocar duas pessoas de lugar já dá outra foto."),
	]

static func task14_reminder() -> Array:
	return [_l(COORD, "5 professores, 3 lugares marcados (atrás à esquerda, atrás à direita e na frente). De quantas formas dá para montar a foto?")]

static func task14_done() -> Array:
	return [
		_l(NARRADOR, "(Click! A foto oficial fica pronta.)"),
		_l(COORD, "Tenho certeza que vamos arrebentar nessa feira."),
	]

# ---------------- Task 15 — A Decoração do Pátio ----------------

static func task15_briefing() -> Array:
	return [
		_l(NARRADOR, "(No fim do dia, a Coordenadora, o Professor de Matemática e o Zelador estão organizando materiais no pátio.)"),
		_l(COORD, "{diretor}, precisamos terminar a decoração do pátio antes que todo mundo vá embora."),
		_l(PROF, "Temos 6 placas diferentes, mas só podemos colocar 3 delas no mural."),
		_l(ZELADOR, "E não basta escolher as placas. A posição de cada uma também muda o resultado."),
		_l(COORD, "Então precisamos descobrir quantas formas diferentes podemos organizar 3 das 6 placas."),
	]

static func task15_reminder() -> Array:
	return [_l(PROF, "6 placas, 3 posições no mural, e a ordem importa. Quantas organizações diferentes existem?")]

static func task15_done() -> Array:
	return [
		_l(PROF, "120 possibilidades? Para escolher três placas?"),
		_l(ZELADOR, "Eu falei que era melhor não fazer isso."),
		_l(COORD, "Não. A gente precisa decorar o pátio para a despedida dos alunos amanhã."),
		_l(NARRADOR, "(Você observa os três continuarem organizando o pátio enquanto os últimos alunos deixam a escola.)"),
	]

# ---------------- Encerramento (seção 6 do roteiro) ----------------

static func final_parte1() -> Array:
	return [
		_l(NARRADOR, "(Você entra no gabinete no fim do dia. O ambiente está silencioso. Ao olhar o calendário na parede, percebe algo.)"),
		_l(PLAYER, "...espera."),
		_l(PLAYER, "Já acabaram os 3 trimestres?"),
		_l(PLAYER, "...o tempo passou rápido."),
		_l(NARRADOR, "(Uma batida na porta. A Coordenadora entra.)"),
		_l(COORD, "{diretor}... ou melhor, quase ex-{diretor|diretora}."),
		_l(PLAYER, "Então chegou o dia."),
		_l(COORD, "Seu contrato era temporário. Hoje ele acaba oficialmente."),
		_l(NARRADOR, "(Silêncio.)"),
		_l(PLAYER, "Engraçado... quando eu cheguei aqui eu só aceitei pelo café grátis."),
		_l(COORD, "E ficou pelos problemas?"),
		_l(PLAYER, "...acho que sim."),
		_l(NARRADOR, "(A Coordenadora abre a porta. Lá fora estão os servidores e alguns alunos.)"),
	]

static func final_parte2() -> Array:
	return [
		_l(CANTINEIRA, "Você ainda me deve um refrigerante."),
		_l(SECRETARIA, "Pela primeira vez esse semestre ninguém perdeu documento."),
		_l(ZELADOR, "...bom trabalho."),
		_l(PROF, "Parabéns. Sobreviveu mais tempo que o diretor anterior."),
		_l(ALUNO, "{diretor}, você volta ano que vem?"),
		_l(NARRADOR, "(Você fica em silêncio. A Coordenadora sorri.)"),
		_l(COORD, "Bom..."),
		_l(NARRADOR, "(Ela entrega um envelope.)"),
		_l(COORD, "Talvez a Escola Pitagórica precise de {um|uma} {diretor|diretora} de novo."),
		_l(PLAYER, "Isso é uma renovação?"),
		_l(COORD, "Isso é um 'talvez'. Não quero que você fique {convencido|convencida}."),
		_l(NARRADOR, "(Você olha pela janela da escola.)"),
		_l(PLAYER, "...acho que eu aceitaria."),
		_l(COORD, "Nos vemos por aí, {diretor|diretora}."),
	]

const MENSAGEM_FINAL: Array = [
	["Obrigado por cuidar da Escola Pitagórica.", "", 3.0],
	["Talvez alguns problemas tenham sido resolvidos.", "", 2.5],
	["Talvez outros tenham acabado de começar.", "", 2.5],
	["Fim.", "Pitagorome", 3.0],
]

static func depois_do_fim() -> Array:
	return [_l(COORD, "Ainda por aqui, {diretor} {player_name}? Vá descansar. O envelope pode esperar até amanhã.")]

# ---------------- Falas soltas ----------------

const FALAS_GINCANA: Array[String] = [
	"Meu colete é amarelo, então eu já sou o favorito. É ciência.",
	"Se eu cair na mesma equipe do Bruno de novo, eu peço transferência.",
	"Gincana boa é gincana com sorteio. Gincana com o professor escolhendo é... suspeita.",
	"Eu treinei a semana inteira. Treinei a desculpa caso a gente perca.",
]

const FALAS_PROFESSORES: Array[String] = [
	"Foto oficial? Ainda bem que eu vim com a camisa boa.",
	"Se eu ficar na frente, eu sorrio. Se ficar atrás, ninguém vai ver mesmo.",
	"Eu topo qualquer lugar, desde que não seja do lado do sol.",
]

static func hint_for_task(task_id: int) -> String:
	match task_id:
		11:
			return "A máquina de refrigerante fica no Refeitório (Ala do Refeitório, porta da direita)."
		12:
			return "Vamos ao pátio! Fica na porta de baixo, no meio do corredor principal."
		13:
			return "As luzes da Sala de Matemática apagaram. Me encontra no corredor, perto da porta dela."
		14:
			return "A foto oficial vai ser no Portão (corredor, porta de baixo à direita)."
		15:
			return "Estamos decorando o pátio. Vem ajudar!"
	return "Mais um trimestre, {diretor} {player_name}."
