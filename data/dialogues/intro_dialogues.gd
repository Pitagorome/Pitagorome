class_name IntroDialogues
extends RefCounted

# Diálogos oficiais do início do jogo e da Task 1 (Tour na Escola).
# Fonte: docs/Pitagorome_Roteiro_Completo.docx.pdf
# Marcadores ({player_name}, {diretor}, {masc|fem}...) explicados em fase1_dialogues.gd

static func get_intro_sequence() -> Array:
	return [
		{
			"speaker": "Coordenadora",
			"text": "Ah, você chegou! Eu sou a Coordenadora da Escola Pitagórica, estávamos realmente precisando de um novo diretor desde que o último foi embora. Os conflitos e os dilemas só têm aumentado."
		},
		{
			"speaker": "Coordenadora",
			"text": "Aqui na Escola Pitagórica nós vivemos um dia de cada vez. Seu papel como diretor será organizar a escola e solucionar problemas. Você deve estar se perguntando que tipos de problemas um diretor enfrentaria... só espero que você não vá embora como o último..."
		},
		{
			"speaker": "Coordenadora",
			"text": "Mas não se preocupe! Sempre que se sentir perdido ou precisar de ajuda, é só me procurar!"
		},
		{
			"speaker": "Coordenadora",
			"text": "Oh! Eu falei demais... me fale um pouco sobre você.",
			"event": "ask_name"
		},
		{
			"speaker": "Coordenadora",
			"text": "{Seja bem-vindo|Seja bem-vinda}, é um prazer te conhecer, {player_name}! Seremos bons amigos a partir de agora."
		},
		{
			"speaker": "Coordenadora",
			"text": "Vamos! Preciso fazer um tour com você pela escola. Saia pela porta ao sul da sua sala para irmos ao corredor!"
		}
	]

static func get_zelador_sequence() -> Array:
	return [
		{
			"speaker": "Coordenadora",
			"text": "Zelador, {esse é o novo diretor|essa é a nova diretora} da nossa escola, {player_title} {player_name}."
		},
		{
			"speaker": "Zelador",
			"text": "Bom dia. *continua a limpar o chão*"
		},
		{
			"speaker": "Coordenadora",
			"text": "Ele é sempre assim... vamos indo. A Sala de Matemática fica na porta à direita do corredor."
		}
	]

static func get_professor_matematica_sequence() -> Array:
	return [
		{
			"speaker": "Professor de Matemática",
			"text": "Olá! Você deve ser {o novo diretor|a nova diretora}, muito prazer. Eu sou o responsável pela parte matemática. Se precisar da minha ajuda, pode pedir... mas terá um preço... muahaha."
		},
		{
			"speaker": "Coordenadora",
			"text": "E aí está o professor de matemática. *Cochicho* ele não é muito agradável. Depois vocês se acertam, vamos indo."
		}
	]

# ------------------------------------------------------------------
# Historinha do começo (18/11, ideia do grupo) — scenes/intro/historia_inicio.tscn
# Não está no roteiro do PDF: só mostra por que a escola precisa de um novo diretor
# (o antigo é demitido) e como {o jogador|a jogadora} acha a vaga no jornal.
# "???" é o jogador: ainda não sabemos o nome dele (ele se apresenta para a Coordenadora).
# ------------------------------------------------------------------

static func historia_demissao() -> Array:
	return [
		{"speaker": "Coordenadora", "text": "Diretor Otávio, chegou uma carta da Secretaria de Educação. Disseram que era urgente..."},
		{"speaker": "Diretor Otávio", "text": "Deixa eu adivinhar: mais um prêmio de \"Melhor Diretor do Ano\"?"},
		{"speaker": "Coordenadora", "text": "Não exatamente... Os pais reclamam, os horários não fecham, ninguém acha nada no almoxarifado. Nenhum problema da escola foi resolvido este ano."},
		{"speaker": "Coordenadora", "text": "O senhor foi... demitido."},
		{"speaker": "Diretor Otávio", "text": "DEMITIDO?! Mas eu ia resolver tudo! Um dia... talvez... com calma..."},
	]

static func historia_coordenadora_sozinha() -> Array:
	return [
		{"speaker": "Coordenadora", "text": "*suspiro* E agora? Quem vai cuidar da Escola Pitagórica?"},
		{"speaker": "Coordenadora", "text": "Vou colocar um anúncio no jornal. Alguém que goste de lógica e matemática há de aparecer..."},
	]

static func historia_jornal_vagas() -> Array:
	return [
		{"speaker": "???", "text": "Vaga de malabarista... já preenchida. Astronauta... preenchida também."},
		{"speaker": "???", "text": "Assim fica difícil arrumar um emprego!"},
	]

static func historia_jornal_achou() -> Array:
	return [
		{"speaker": "???", "text": "Espera... \"Procura-se diretor(a) para a Escola Pitagórica. Requisitos: gostar de lógica, de matemática e de resolver problemas.\""},
		{"speaker": "???", "text": "Resolver problemas com lógica e matemática? Isso é comigo! Amanhã cedo eu vou até lá."},
	]

static func historia_chegada() -> Array:
	return [
		{"speaker": "???", "text": "Escola Pitagórica... é aqui."},
		{"speaker": "???", "text": "\"Muitos problemas\", dizia o anúncio. Quantos problemas uma escola pode ter, afinal?"},
	]
