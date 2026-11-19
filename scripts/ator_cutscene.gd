extends CharacterBody2D

# Personagem "de mentira" da historinha do começo (scripts/historia_inicio.gd).
# Não tem colisão nem interação: só anda até um ponto com a animação certa e vira para os lados.
# É CharacterBody2D com npc_name para a caixa de diálogo achar o retrato de quem fala
# (scripts/dialogue_box.gd -> frames_de).

var npc_name: String = ""
var sprite: AnimatedSprite2D

func configurar(nome: String, frames: SpriteFrames, pos: Vector2, direcao: String = "down", cor: Color = Color.WHITE) -> void:
	npc_name = nome
	name = "Ator" + nome.replace(" ", "").replace("?", "")
	position = pos
	z_index = 1 # igual aos NPCs e móveis: ordena pelo y_sort da sala
	sprite = AnimatedSprite2D.new()
	sprite.name = "AnimatedSprite2D" # a caixa de diálogo procura o retrato por esse nome
	sprite.sprite_frames = frames
	sprite.position = Vector2(0, 15) # ordena pelos pés, como os NPCs
	sprite.offset = Vector2(0, -15)
	sprite.modulate = cor
	add_child(sprite)
	olhar(direcao)

func olhar(direcao: String) -> void:
	sprite.play("idle_" + direcao)

# Anda em linha reta até "alvo" (velocidade em pixels por segundo) e para virado para onde andou.
func andar_ate(alvo: Vector2, velocidade: float = 50.0) -> void:
	var delta: Vector2 = alvo - position
	if delta.length() < 0.5:
		return
	var direcao: String
	if absf(delta.x) > absf(delta.y):
		direcao = "right" if delta.x > 0 else "left"
	else:
		direcao = "down" if delta.y > 0 else "up"
	sprite.play("walk_" + direcao)
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", alvo, delta.length() / velocidade)
	await tween.finished
	sprite.play("idle_" + direcao)

# Anda por vários pontos seguidos.
func andar_por(pontos: Array, velocidade: float = 50.0) -> void:
	for p in pontos:
		await andar_ate(p, velocidade)
