class_name Interacao
extends RefCounted

# Decide QUAL coisa responde ao [E] quando o jogador está perto de várias ao mesmo tempo.
#
# Bug (print do grupo, 24/11): parado entre dois NPCs, os dois "[E] Conversar" apareciam
# um em cima do outro e o E falava com qualquer um deles. Agora todo NPC/objeto com o
# jogador no alcance entra no grupo GRUPO e só o mais próximo do jogador mostra a dica
# e aceita o E.

const GRUPO: StringName = &"interagivel_perto"

static func entrou(no: Node) -> void:
	no.add_to_group(GRUPO)

static func saiu(no: Node) -> void:
	if no.is_in_group(GRUPO):
		no.remove_from_group(GRUPO)

static func eh_o_mais_proximo(no: Node2D) -> bool:
	if not no.is_inside_tree() or not no.is_in_group(GRUPO):
		return false
	var tree: SceneTree = no.get_tree()
	var jogador: Node2D = tree.get_first_node_in_group("player") as Node2D
	if jogador == null:
		return true
	var alvo: Vector2 = jogador.global_position
	var melhor: Node2D = null
	var melhor_d: float = INF
	for outro in tree.get_nodes_in_group(GRUPO):
		var n2d: Node2D = outro as Node2D
		if n2d == null or not n2d.is_visible_in_tree() or not n2d.can_process():
			continue
		var d: float = n2d.global_position.distance_squared_to(alvo)
		# Empate: ganha o de menor id, para a escolha não ficar piscando
		if melhor == null or d < melhor_d or (is_equal_approx(d, melhor_d) and n2d.get_instance_id() < melhor.get_instance_id()):
			melhor = n2d
			melhor_d = d
	return melhor == no
