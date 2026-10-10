extends Node

# Autoload: GameManager (Jogo no diagrama UML)
# Controla o estado global, fluxo narrativo, tarefas, transições e posições de spawn.

signal task_updated(task_id: int, task_name: String)
signal objective_updated(text: String)
signal phase_changed(new_phase: int)
signal player_info_updated(player_name: String, player_gender: String)

# Aparências disponíveis para o jogador (sprites em assets/character_frames)
const APPEARANCES: Array = [
	"res://assets/character_frames/adam_frames.tres",
	"res://assets/character_frames/bob_frames.tres",
	"res://assets/character_frames/alex_frames.tres",
	"res://assets/character_frames/amelia_frames.tres",
]

# Dados do jogador (UML: Jogador)
var player_name: String = "Diretor"
var player_gender: String = "M"
var player_appearance: int = 0
var player_speed: float = 110.0

# Estado narrativo
var intro_dialogue_finished: bool = false
var seen_events: Dictionary = {}

# Progresso do Jogo (UML: Jogo)
var current_phase: int = 1
var current_task_id: int = 1
var current_task_name: String = "Tour na Escola"
var current_objective: String = ""
var completed_tasks: Array[int] = []

# Estado do Tour na Escola (Task 1)
var tour_talked_zelador: bool = false
var tour_talked_professor: bool = false
var tour_completed: bool = false

# Depoimentos ouvidos na Task 4 (id do aluno -> true)
var testimonies_heard: Dictionary = {}

# Sistema de Spawn entre salas
var target_spawn_id: String = ""

const TASK_NAMES: Dictionary = {
	1: "Tour na Escola",
	2: "Conflito no Horário",
	3: "O Cofre da Escola",
	4: "Quem Está Matando Aula?",
	5: "O Ônibus da Excursão"
}

const TASK_OBJECTIVES: Dictionary = {
	1: "Fale com o Zelador no corredor e com o Professor na Sala de Matemática.",
	2: "Volte ao gabinete e reorganize a grade de horários.",
	3: "Vá ao Almoxarifado (corredor, porta de baixo à esquerda) e abra o armário com \"!\".",
	4: "Ouça João, Pedro e Lucas no corredor e conte à Coordenadora quem mentiu.",
	5: "Confira o calendário com \"!\" no seu gabinete."
}

func _ready() -> void:
	print("[GameManager] Inicializado. Tarefa atual: ", current_task_id)

# Volta tudo ao estado de um jogo novo (usado também pelos testes automatizados).
func reset_progress() -> void:
	player_name = "Diretor"
	player_gender = "M"
	player_appearance = 0
	intro_dialogue_finished = false
	seen_events.clear()
	current_phase = 1
	completed_tasks.clear()
	tour_talked_zelador = false
	tour_talked_professor = false
	tour_completed = false
	testimonies_heard.clear()
	target_spawn_id = ""
	start_task(1)

func set_player_info(new_name: String, new_gender: String = "", new_appearance: int = -1) -> void:
	if new_name.strip_edges() != "":
		player_name = new_name.strip_edges()
	if new_gender == "M" or new_gender == "F":
		player_gender = new_gender
	if new_appearance >= 0:
		player_appearance = new_appearance % APPEARANCES.size()
	player_info_updated.emit(player_name, player_gender)

func get_appearance_frames() -> SpriteFrames:
	return load(APPEARANCES[player_appearance]) as SpriteFrames

func get_director_title() -> String:
	return "Diretora" if player_gender == "F" else "Diretor"

func get_director_formal_title() -> String:
	return "Sra." if player_gender == "F" else "Sr."

func start_task(task_id: int) -> void:
	current_task_id = task_id
	current_task_name = TASK_NAMES.get(task_id, "Tarefa " + str(task_id))
	task_updated.emit(current_task_id, current_task_name)
	set_objective(TASK_OBJECTIVES.get(task_id, ""))
	print("[GameManager] Tarefa atualizada: ", current_task_id, " - ", current_task_name)

func set_objective(text: String) -> void:
	current_objective = text
	objective_updated.emit(text)

func is_task_completed(task_id: int) -> bool:
	return completed_tasks.has(task_id)

func complete_task(task_id: int) -> void:
	if completed_tasks.has(task_id):
		return
	completed_tasks.append(task_id)
	print("[GameManager] Tarefa concluída: ", task_id)

	var next_task: int = task_id + 1
	if TASK_NAMES.has(next_task):
		start_task(next_task)
	else:
		advance_phase()

func advance_phase() -> void:
	current_phase += 1
	current_task_id = 0
	current_task_name = "Fase %d concluída!" % (current_phase - 1)
	task_updated.emit(current_task_id, current_task_name)
	set_objective("A Fase %d está em desenvolvimento. Obrigado por testar!" % current_phase)
	phase_changed.emit(current_phase)

func check_tour_progress() -> bool:
	if tour_talked_zelador and tour_talked_professor and not tour_completed:
		tour_completed = true
		complete_task(1) # Ativa Task 2: Conflito no Horário
		print("[GameManager] Tour concluído! Task 2 desbloqueada.")
		return true
	if tour_talked_zelador and not tour_talked_professor:
		set_objective("Agora entre na Sala de Matemática (porta à direita do corredor).")
	elif tour_talked_professor and not tour_talked_zelador:
		set_objective("Agora fale com o Zelador no corredor.")
	return false

func mark_event(event_id: String) -> bool:
	# Retorna true só na primeira vez que o evento acontece.
	if seen_events.has(event_id):
		return false
	seen_events[event_id] = true
	return true

func change_scene(scene_path: String, spawn_id: String = "") -> void:
	Transition.change_scene(scene_path, spawn_id)
