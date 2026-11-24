extends Node

# Autoload: Audio
# Toca a música de fundo e os efeitos sonoros do jogo.
# Os arquivos ficam em assets/audio e são gerados por tools/gerar_sons.py
# (tudo sintetizado pelo próprio script: nenhuma música ou som de terceiros, sem copyright).
#
# O que ele faz sozinho, sem precisar mexer nas cenas:
#   - clique em QUALQUER botão (liga o sinal "pressed" de cada BaseButton que entra na árvore);
#   - "blip" a cada fala nova da caixa de diálogo;
#   - som de tarefa concluída, fase concluída, luz caindo / voltando;
#   - troca de música conforme a cena (historinha, escola, escola sem luz).
# Os outros sons (porta, interagir, acerto, erro) são chamados com Audio.tocar("nome").
#
# Tecla M liga/desliga a música.

const SFX: Dictionary = {
	"clique": "res://assets/audio/sfx/clique.wav",
	"dialogo": "res://assets/audio/sfx/dialogo.wav",
	"interagir": "res://assets/audio/sfx/interagir.wav",
	"porta": "res://assets/audio/sfx/porta.wav",
	"acerto": "res://assets/audio/sfx/acerto.wav",
	"erro": "res://assets/audio/sfx/erro.wav",
	"tarefa": "res://assets/audio/sfx/tarefa.wav",
	"fase": "res://assets/audio/sfx/fase.wav",
	"apagao": "res://assets/audio/sfx/apagao.wav",
	"energia": "res://assets/audio/sfx/energia.wav",
}
const MUSICAS: Dictionary = {
	"escola": "res://assets/audio/musica/escola.wav",
	"historia": "res://assets/audio/musica/historia.wav",
	"escuro": "res://assets/audio/musica/escuro.wav",
}
# Cenas que tocam a música da historinha (o resto usa "escola" ou "escuro")
const CENAS_HISTORIA: Array[String] = [
	"res://scenes/intro/historia_inicio.tscn",
	"res://scenes/intro/intro_scene.tscn",
]

const VOLUME_MUSICA_DB: float = -12.0
const VOLUME_SFX_DB: float = -4.0
const TEMPO_CROSSFADE: float = 1.0
const SILENCIO_DB: float = -60.0
const CANAIS_SFX: int = 8
# Ignora o mesmo efeito repetido mais rápido que isto (evita "metralhadora" de cliques)
const INTERVALO_MINIMO: float = 0.05

var musica_ligada: bool = true
var musica_atual: String = ""

var _sfx: Dictionary = {}          # nome -> AudioStream
var _ultimo_toque: Dictionary = {} # nome -> tempo (s) em que tocou pela última vez
var _canais: Array[AudioStreamPlayer] = []
var _proximo_canal: int = 0
var _musica_a: AudioStreamPlayer
var _musica_b: AudioStreamPlayer
var _musica_ativa: AudioStreamPlayer
var _tween_musica: Tween
var _cena_vista: Node = null
var _escuro_antes: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # continua tocando com o jogo pausado
	_criar_bus("Musica")
	_criar_bus("Efeitos")
	for nome in SFX:
		var s: AudioStream = load(SFX[nome]) as AudioStream
		if s:
			_sfx[nome] = s
	for i in CANAIS_SFX:
		var p := AudioStreamPlayer.new()
		p.bus = "Efeitos"
		p.volume_db = VOLUME_SFX_DB
		add_child(p)
		_canais.append(p)
	_musica_a = _novo_player_musica()
	_musica_b = _novo_player_musica()
	_musica_ativa = _musica_a

	# Clique em todos os botões, inclusive os que já existem
	get_tree().node_added.connect(_on_node_added)
	_ligar_botoes(get_tree().root)

	DialogueManager.dialogue_line_changed.connect(_on_dialogue_line_changed)
	GameManager.task_completed.connect(_on_task_completed)
	GameManager.phase_changed.connect(_on_phase_changed)
	GameManager.lights_changed.connect(_on_lights_changed)
	_escuro_antes = GameManager.lights_out

# ---------------- efeitos ----------------

# Toca um efeito pelo nome (veja SFX). pitch_variacao deixa repetições menos robóticas.
func tocar(nome: String, pitch_variacao: float = 0.0) -> void:
	var s: AudioStream = _sfx.get(nome)
	if s == null:
		return
	var agora: float = Time.get_ticks_msec() / 1000.0
	if agora - float(_ultimo_toque.get(nome, -1.0)) < INTERVALO_MINIMO:
		return
	_ultimo_toque[nome] = agora
	var p: AudioStreamPlayer = _canais[_proximo_canal]
	_proximo_canal = (_proximo_canal + 1) % _canais.size()
	p.stream = s
	p.pitch_scale = 1.0 + randf_range(-pitch_variacao, pitch_variacao) if pitch_variacao > 0.0 else 1.0
	p.play()

# Quantos segundos faz que o efeito tocou (INF se nunca tocou)
func tempo_desde(nome: String) -> float:
	if not _ultimo_toque.has(nome):
		return INF
	return Time.get_ticks_msec() / 1000.0 - float(_ultimo_toque[nome])

func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		_ligar_botao(node as BaseButton)

func _ligar_botoes(raiz: Node) -> void:
	if raiz is BaseButton:
		_ligar_botao(raiz as BaseButton)
	for filho in raiz.get_children():
		_ligar_botoes(filho)

func _ligar_botao(botao: BaseButton) -> void:
	if not botao.pressed.is_connected(_on_botao_pressed):
		botao.pressed.connect(_on_botao_pressed)

func _on_botao_pressed() -> void:
	tocar("clique", 0.05)

func _on_dialogue_line_changed(_speaker: String, _text: String) -> void:
	# Logo depois do "interagir" o blip fica embolado: deixa só o primeiro
	if tempo_desde("interagir") < 0.15:
		return
	tocar("dialogo", 0.08)

func _on_task_completed(_task_id: int) -> void:
	# Quem resolveu um desafio já ouviu o "acerto"; o jingle de tarefa entra logo depois
	if tempo_desde("acerto") < 1.0:
		get_tree().create_timer(0.55).timeout.connect(tocar.bind("tarefa"))
	else:
		tocar("tarefa")

func _on_phase_changed(_fase: int) -> void:
	get_tree().create_timer(0.8).timeout.connect(tocar.bind("fase"))

func _on_lights_changed(sem_luz: bool) -> void:
	if sem_luz and not _escuro_antes:
		tocar("apagao")
	elif not sem_luz and _escuro_antes:
		tocar("energia")
	_escuro_antes = sem_luz
	_atualizar_musica()

# ---------------- música ----------------

func _process(_delta: float) -> void:
	var cena: Node = get_tree().current_scene
	if cena != _cena_vista:
		_cena_vista = cena
		_atualizar_musica()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_M:
		set_musica_ligada(not musica_ligada)

func set_musica_ligada(ligada: bool) -> void:
	musica_ligada = ligada
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Musica"), not ligada)

func escolher_musica() -> String:
	var cena: Node = get_tree().current_scene
	if cena == null:
		return musica_atual
	if CENAS_HISTORIA.has(cena.scene_file_path):
		return "historia"
	var local = cena.get("location_id")
	if GameManager.lights_out or (local != null and GameManager.is_room_dark(str(local))):
		return "escuro"
	return "escola"

func _atualizar_musica() -> void:
	tocar_musica(escolher_musica())

# Troca a música com crossfade. Se já for a mesma, não reinicia.
func tocar_musica(nome: String) -> void:
	if nome == musica_atual or not MUSICAS.has(nome):
		return
	var stream: AudioStream = load(MUSICAS[nome]) as AudioStream
	if stream == null:
		return
	_preparar_loop(stream)
	musica_atual = nome
	var sai: AudioStreamPlayer = _musica_ativa
	var entra: AudioStreamPlayer = _musica_b if _musica_ativa == _musica_a else _musica_a
	_musica_ativa = entra
	entra.stream = stream
	entra.volume_db = SILENCIO_DB
	entra.play()
	if _tween_musica and _tween_musica.is_valid():
		_tween_musica.kill()
	_tween_musica = create_tween().set_parallel(true)
	_tween_musica.tween_property(entra, "volume_db", VOLUME_MUSICA_DB, TEMPO_CROSSFADE)
	if sai.playing:
		_tween_musica.tween_property(sai, "volume_db", SILENCIO_DB, TEMPO_CROSSFADE)
		_tween_musica.chain().tween_callback(sai.stop)

func _preparar_loop(stream: AudioStream) -> void:
	if stream is AudioStreamWAV:
		var wav := stream as AudioStreamWAV
		if wav.loop_mode != AudioStreamWAV.LOOP_FORWARD:
			wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
			wav.loop_begin = 0
			wav.loop_end = int(wav.get_length() * wav.mix_rate)

func _novo_player_musica() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = "Musica"
	p.volume_db = SILENCIO_DB
	add_child(p)
	return p

func _criar_bus(nome: String) -> void:
	if AudioServer.get_bus_index(nome) != -1:
		return
	AudioServer.add_bus()
	var idx: int = AudioServer.bus_count - 1
	AudioServer.set_bus_name(idx, nome)
	AudioServer.set_bus_send(idx, "Master")
