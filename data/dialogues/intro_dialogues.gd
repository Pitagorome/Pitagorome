class_name IntroDialogues
extends RefCounted

# Diálogos oficiais do início do jogo e da Task 1 (Tour na Escola).
# Fonte: docs/Pitagorome_Roteiro_Completo.docx.pdf
# Marcadores ({player_name}, {diretor}, {masc|fem}...) explicados em fase1_dialogues.gd

static func get_intro_sequence() -> Array:
	return [
		{
			"speaker": "Coordenadora",
			"text": "Ah, você chegou! Eu sou a Coordenadora da Escola Pitagorome, estávamos realmente precisando de um novo diretor desde que o último foi embora. Os conflitos e os dilemas só têm aumentado."
		},
		{
			"speaker": "Coordenadora",
			"text": "Aqui na Escola Pitagorome nós vivemos um dia de cada vez. Seu papel como diretor será organizar a escola e solucionar problemas. Você deve estar se perguntando que tipos de problemas um diretor enfrentaria... só espero que você não vá embora como o último..."
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
