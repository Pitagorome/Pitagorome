extends Area2D

# Porta que leva para outra sala.
#
# Antes ela usava só o sinal body_entered + um cooldown de 0.5s. Isso dava um bug:
# se o jogador encostasse na porta durante o cooldown (ou nascesse em cima dela),
# o sinal era ignorado e, como ele já estava DENTRO da área, o sinal não vinha de novo.
# Aí ele andava pela passagem escura até a parte vazia do mapa sem trocar de sala.
#
# Agora a porta "arma" quando o jogador está FORA dela e, armada, confere a cada
# quadro se ele está em cima. Assim:
#   - quem nasce em cima da porta não volta na hora (precisa sair e entrar de novo);
#   - quem anda até a porta sempre entra, não importa quando encostou.
@export_file("*.tscn") var target_scene: String = "res://scenes/school/school_corridor.tscn"
@export var target_spawn_id: String = "from_door"

var can_teleport: bool = false # armada (o jogador já esteve fora da porta desde que a cena abriu)
var _usada: bool = false

func _ready() -> void:
	monitoring = true

func _physics_process(_delta: float) -> void:
	if _usada or target_scene == "" or Transition.is_transitioning:
		return
	var jogador_em_cima: bool = false
	for body in get_overlapping_bodies():
		if _eh_jogador(body):
			jogador_em_cima = true
			break
	if not can_teleport:
		# Só arma depois que a física já rodou (get_overlapping_bodies fica vazio no 1º quadro)
		if not jogador_em_cima and Engine.get_physics_frames() > _quadro_inicial + 2:
			can_teleport = true
		return
	if jogador_em_cima and not DialogueManager.is_busy():
		_usada = true
		Audio.tocar("porta")
		GameManager.change_scene(target_scene, target_spawn_id)

var _quadro_inicial: int = 0

func _enter_tree() -> void:
	_quadro_inicial = Engine.get_physics_frames()

func _eh_jogador(body: Node) -> bool:
	return body.is_in_group("player") or body.name == "Player" or body.name == "director"
