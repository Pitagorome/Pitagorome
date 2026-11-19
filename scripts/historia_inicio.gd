extends Node2D

# Historinha do começo do jogo (cena principal: scenes/intro/historia_inicio.tscn).
# Ideia do grupo (18/11): antes de cair no gabinete, mostrar
#   1. o diretor antigo sendo demitido (no gabinete de verdade),
#   2. o novo diretor procurando emprego nos classificados do jornal,
#   3. o novo diretor chegando no portão da escola.
# Depois disso vai para o gabinete (entrando pela porta) e o jogo segue como antes:
# a Coordenadora diz "Ah, você chegou!" e pergunta o nome/visual.
#
# Os cenários são as próprias salas do jogo (gabinete e portão) carregadas SEM o script da
# sala (não dispara a história), sem jogador, sem NPCs e sem HUD. Os personagens são
# "atores" (scripts/ator_cutscene.gd) que só andam e viram.
# O novo diretor aparece como silhueta escura ("???"), porque o jogador ainda não escolheu
# o nome nem o visual.
# Falas: data/dialogues/intro_dialogues.gd (historia_*). Pular: botão no canto ou Esc.

const CENA_GABINETE: String = "res://scenes/intro/intro_scene.tscn"
const CENA_PORTAO: String = "res://scenes/school/portao_scene.tscn"
const ATOR: Script = preload("res://scripts/ator_cutscene.gd")
const FRAMES_DIRETOR_ANTIGO: SpriteFrames = preload("res://assets/character_frames/diretor_antigo_frames.tres")
const FRAMES_COORDENADORA: SpriteFrames = preload("res://assets/character_frames/amelia_frames.tres")
const FRAMES_NOVO_DIRETOR: SpriteFrames = preload("res://assets/character_frames/adam_frames.tres")
const COR_SILHUETA: Color = Color(0.1, 0.1, 0.14)

# Nomes dos nós das salas que não entram na cutscene (jogador, interface, NPCs, coisas de tarefa)
const NOS_REMOVIDOS: Array[String] = ["HUD", "DialogueBox", "ChallengeModal", "Excursao", "Vans"]

@onready var palco: Node2D = $Palco
@onready var camera: Camera2D = $Camera2D
@onready var jornal_layer: CanvasLayer = $JornalLayer
@onready var circulo: Panel = $JornalLayer/Jornal/Circulo
@onready var botao_pular: Button = $UI/BotaoPular

var sala: Node2D = null
# Atores da cena atual (membros, porque lambdas do GDScript copiam variáveis locais)
var otavio: Node = null
var coord: Node = null
var novo: Node = null
var pulando: bool = false
var saindo: bool = false

func _ready() -> void:
	Transition.escurecer_ja()
	camera.make_current()
	botao_pular.pressed.connect(pular)
	_rodar.call_deferred()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		pular()

# ------------------------------------------------------------------
# Roteiro
# ------------------------------------------------------------------

func _rodar() -> void:
	# Se a cena foi aberta por uma transição (ex.: testes), espera ela acabar antes de começar
	while Transition.is_transitioning:
		await Transition.transition_finished
	await _cena_demissao()
	if pulando: return
	await _cena_jornal()
	if pulando: return
	await _cena_chegada()
	if pulando: return
	_ir_para_gabinete()

# 1. Gabinete: a Coordenadora entra com a carta e o Diretor Otávio é demitido
func _cena_demissao() -> void:
	await Transition.trocar_quadro([["Alguns meses atrás...", "Escola Pitagórica, gabinete do diretor", 2.2]], func():
		_montar_sala(CENA_GABINETE)
		otavio = _ator("Diretor Otávio", FRAMES_DIRETOR_ANTIGO, Vector2(-40, -40), "right")
		coord = _ator("Coordenadora", FRAMES_COORDENADORA, Vector2(0, 112), "up")
		camera.position = Vector2(0, -10)
	)
	if pulando: return
	await coord.andar_ate(Vector2(0, 8), 45.0)
	coord.olhar("left")
	otavio.olhar("down")
	if pulando: return
	await _falar(IntroDialogues.historia_demissao())
	if pulando: return
	# O diretor sai pela porta, contornando a mesa; a Coordenadora acompanha com o olhar
	await otavio.andar_por([Vector2(-40, 40)], 60.0)
	if pulando: return
	coord.olhar("down")
	await otavio.andar_por([Vector2(0, 50), Vector2(0, 118)], 60.0)
	if pulando: return
	otavio.visible = false
	await _esperar(0.4)
	if pulando: return
	coord.olhar("down")
	await _falar(IntroDialogues.historia_coordenadora_sozinha())

# 2. Jornal: o futuro diretor procura emprego nos classificados
func _cena_jornal() -> void:
	await Transition.trocar_quadro([["Enquanto isso, do outro lado da cidade...", "", 2.0]], func():
		_limpar_palco()
		jornal_layer.visible = true
		circulo.visible = false
	)
	if pulando: return
	await _esperar(0.5)
	if pulando: return
	await _falar(IntroDialogues.historia_jornal_vagas())
	if pulando: return
	# Círculo vermelho de caneta em volta do anúncio da escola
	circulo.visible = true
	circulo.scale = Vector2(1.25, 1.25)
	circulo.modulate.a = 0.0
	var tween: Tween = create_tween().set_parallel()
	tween.tween_property(circulo, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(circulo, "modulate:a", 1.0, 0.25)
	await tween.finished
	if pulando: return
	await _falar(IntroDialogues.historia_jornal_achou())

# 3. Portão: na manhã seguinte, a silhueta chega na escola
func _cena_chegada() -> void:
	await Transition.trocar_quadro([["Na manhã seguinte...", "", 1.8]], func():
		jornal_layer.visible = false
		_montar_sala(CENA_PORTAO)
		novo = _ator("???", FRAMES_NOVO_DIRETOR, Vector2(-150, 62), "right", COR_SILHUETA)
		camera.position = Vector2(0, -10)
	)
	if pulando: return
	await novo.andar_por([Vector2(0, 62), Vector2(0, -30)], 45.0)
	if pulando: return
	novo.olhar("up")
	await _esperar(0.5)
	if pulando: return
	await _falar(IntroDialogues.historia_chegada())
	if pulando: return
	await novo.andar_ate(Vector2(0, -92), 45.0)

# ------------------------------------------------------------------
# Fim / pular
# ------------------------------------------------------------------

func pular() -> void:
	if pulando or saindo:
		return
	pulando = true
	if DialogueManager.is_active:
		DialogueManager.end_dialogue()
	_ir_para_gabinete()

func _ir_para_gabinete() -> void:
	if saindo:
		return
	saindo = true
	botao_pular.disabled = true
	while Transition.is_transitioning:
		await Transition.transition_finished
	# Entra pela porta do gabinete; lá a Coordenadora começa o diálogo de boas-vindas
	Transition.change_scene(CENA_GABINETE, "SpawnFromCorridor")

# ------------------------------------------------------------------
# Utilitários
# ------------------------------------------------------------------

func _falar(linhas: Array) -> void:
	DialogueManager.start_dialogue(linhas)
	if DialogueManager.is_active:
		await DialogueManager.dialogue_ended

func _esperar(segundos: float) -> void:
	await get_tree().create_timer(segundos).timeout

func _limpar_palco() -> void:
	for filho in palco.get_children():
		filho.queue_free()
	sala = null

# Carrega uma sala do jogo só como cenário
func _montar_sala(caminho: String) -> void:
	_limpar_palco()
	sala = (load(caminho) as PackedScene).instantiate() as Node2D
	sala.set_script(null) # sem school_room.gd: não avisa o Fase1Flow, não dispara falas
	var remover: Array[Node] = []
	for nome in NOS_REMOVIDOS:
		var n: Node = sala.get_node_or_null(nome)
		if n:
			remover.append(n)
	for n in sala.find_children("*", "", true, false):
		if n is CharacterBody2D or n.name in ["ExclamationMarker", "DoorLabel"] or n.name.begins_with("Marca"):
			remover.append(n)
	for n in remover:
		if is_instance_valid(n) and n.get_parent():
			n.get_parent().remove_child(n)
			n.queue_free()
	for area in sala.find_children("*", "Area2D", true, false):
		(area as Area2D).monitoring = false # portas e objetos não reagem aos atores
	palco.add_child(sala)

func _ator(nome: String, frames: SpriteFrames, pos: Vector2, direcao: String, cor: Color = Color.WHITE) -> Node:
	var ator: Node = ATOR.new()
	sala.add_child(ator)
	ator.configurar(nome, frames, pos, direcao, cor)
	return ator
