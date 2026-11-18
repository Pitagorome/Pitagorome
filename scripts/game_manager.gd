extends Node

# Autoload: GameManager (Jogo no diagrama UML)
# Controla o estado global, fluxo narrativo, tarefas, transições e posições de spawn.

signal task_updated(task_id: int, task_name: String)
signal objective_updated(text: String)
signal phase_changed(new_phase: int)
signal player_info_updated(player_name: String, player_gender: String)
signal lights_changed(lights_out: bool)
signal note_updated(text: String)

# Aparências disponíveis para o jogador (sprites em assets/character_frames).
# Nenhuma é igual a um NPC: Bob = Professor, Alex = Zelador, Amelia = Coordenadora.
const APPEARANCES: Array = [
	"res://assets/character_frames/adam_frames.tres",
	"res://assets/character_frames/escoteiro1_frames.tres",
	"res://assets/character_frames/escoteiro2_frames.tres",
	"res://assets/character_frames/carteiro1_frames.tres",
	"res://assets/character_frames/carteiro2_frames.tres",
	# Personagens da arte "Obrigado!" do grupo (gerados por tools/gerar_personagens.py)
	"res://assets/character_frames/grupo1_frames.tres",
	"res://assets/character_frames/grupo2_frames.tres",
	"res://assets/character_frames/grupo3_frames.tres",
	"res://assets/character_frames/grupo4_frames.tres",
]
# Nome mostrado no seletor "Crie seu personagem" (mesma ordem de APPEARANCES)
const APPEARANCE_NAMES: Array[String] = [
	"Visual 1", "Visual 2", "Visual 3", "Visual 4", "Visual 5",
	"João", "Edu", "Guigas", "Ana",
]

func get_appearance_name(index: int = -1) -> String:
	var i: int = player_appearance if index < 0 else index
	return APPEARANCE_NAMES[i] if i < APPEARANCE_NAMES.size() else "Visual %d" % (i + 1)

# Dados do jogador (UML: Jogador)
var player_name: String = "Diretor"
var player_gender: String = "M"
var player_appearance: int = 0
# Fica true quando o jogador confirma o nome (antes disso o HUD não mostra o crachá)
var player_named: bool = false
var player_speed: float = 110.0

# Estado narrativo
var intro_dialogue_finished: bool = false
var seen_events: Dictionary = {}

# Progresso do Jogo (UML: Jogo)
var current_phase: int = 1
var current_task_id: int = 1
var current_task_name: String = "Tour na Escola"
var current_objective: String = ""
# Lembrete fixo no HUD (ex.: o bilhete do Zelador na Task 6). Vazio = não aparece.
var current_note: String = ""
var completed_tasks: Array[int] = []

# Estado do Tour na Escola (Task 1)
var tour_talked_zelador: bool = false
var tour_talked_professor: bool = false
var tour_completed: bool = false

# Depoimentos ouvidos na Task 4 (id do aluno -> true)
var testimonies_heard: Dictionary = {}

# Fase 2: escola sem luz (Task 8) e quantas vezes o jogador abriu o armário errado (Task 6)
var lights_out: bool = false
var wrong_lockers: int = 0
# Fase 3: salas escuras só por um tempo (Task 13 — a Sala de Matemática com as luzes apagadas)
var dark_rooms: Array[String] = []
# Fica true depois do encerramento (seção 6 do roteiro)
var game_finished: bool = false

# Sistema de Spawn entre salas
var target_spawn_id: String = ""

const TASK_NAMES: Dictionary = {
	1: "Tour na Escola",
	2: "Conflito no Horário",
	3: "O Cofre da Escola",
	4: "Quem Está Matando Aula?",
	5: "O Ônibus da Excursão",
	6: "O Troféu Desaparecido",
	7: "Figurinhas",
	8: "O Gerador de Emergência",
	9: "As Mesas do Refeitório",
	10: "O Cartaz da Feira",
	11: "A Máquina de Refrigerante",
	12: "As Equipes da Gincana",
	13: "As Luzes do Corredor",
	14: "O Lugar da Foto Oficial",
	15: "A Decoração do Pátio",
}

# Em que fase fica cada tarefa
const TASK_PHASE: Dictionary = {1: 1, 2: 1, 3: 1, 4: 1, 5: 1, 6: 2, 7: 2, 8: 2, 9: 2, 10: 2, 11: 3, 12: 3, 13: 3, 14: 3, 15: 3}
const LAST_PHASE: int = 3
const PHASE_NAMES: Dictionary = {
	1: "Lógica e Organização",
	2: "Equações, Proporções e Probabilidade",
	3: "Funções, Combinatória e Raciocínio Algébrico",
}

const TASK_OBJECTIVES: Dictionary = {
	1: "Fale com o Zelador no corredor e com o Professor na Sala de Matemática.",
	2: "Volte ao gabinete e reorganize a grade de horários.",
	3: "Vá ao Almoxarifado (corredor, porta de baixo à esquerda) e abra o armário com \"!\".",
	4: "Ouça João, Pedro e Lucas no corredor e conte à Coordenadora quem mentiu.",
	5: "Confira o calendário com \"!\" no seu gabinete.",
	6: "A Coordenadora está te procurando no corredor.",
	7: "Passe pela Sala de Artes (corredor, porta de cima à esquerda → Ala do Refeitório).",
	8: "Vá até a Sala do Gerador (Ala do Refeitório, porta da esquerda).",
	9: "Vá ao Refeitório (Ala do Refeitório, porta da direita).",
	10: "Encontre o Professor de Matemática na Biblioteca (corredor, porta de cima no meio).",
	11: "Um aluno entrou correndo no seu gabinete. Fale com ele.",
	12: "Volte ao seu gabinete: a Coordenadora quer falar com você.",
	13: "Volte ao corredor principal (porta de cima do Pátio).",
	14: "A Coordenadora te espera no Portão para a foto oficial (corredor, porta de baixo à direita).",
	15: "No fim do dia, passe pelo Pátio (corredor, porta de baixo no meio).",
}

func _ready() -> void:
	print("[GameManager] Inicializado. Tarefa atual: ", current_task_id)

# Volta tudo ao estado de um jogo novo (usado também pelos testes automatizados).
func reset_progress() -> void:
	player_name = "Diretor"
	player_gender = "M"
	player_appearance = 0
	player_named = false
	intro_dialogue_finished = false
	seen_events.clear()
	current_phase = 1
	completed_tasks.clear()
	tour_talked_zelador = false
	tour_talked_professor = false
	tour_completed = false
	testimonies_heard.clear()
	wrong_lockers = 0
	dark_rooms.clear()
	game_finished = false
	set_lights_out(false)
	set_note("")
	target_spawn_id = ""
	start_task(1)

# Pula direto para o começo de uma fase (usado pelo atalho tests/comecar_fase2.tscn e pelos testes).
func jump_to_phase(phase: int) -> void:
	reset_progress()
	intro_dialogue_finished = true
	tour_talked_zelador = true
	tour_talked_professor = true
	tour_completed = true
	if player_name == "Diretor":
		set_player_info("Diretor", "M", 0)
	for task in TASK_PHASE:
		if TASK_PHASE[task] < phase:
			completed_tasks.append(task)
			seen_events["t%d_briefing" % task] = true
	current_phase = phase
	start_task(first_task_of_phase(phase))

func first_task_of_phase(phase: int) -> int:
	var first: int = 0
	for task in TASK_PHASE:
		if TASK_PHASE[task] == phase and (first == 0 or task < first):
			first = task
	return first

func set_note(text: String) -> void:
	current_note = text
	note_updated.emit(text)

func set_lights_out(value: bool) -> void:
	lights_out = value
	lights_changed.emit(value)

# Apaga/acende só uma sala (location_id). A escola inteira continua com luz.
func set_room_dark(location: String, dark: bool) -> void:
	if dark and not dark_rooms.has(location):
		dark_rooms.append(location)
	elif not dark:
		dark_rooms.erase(location)
	lights_changed.emit(lights_out)

func is_room_dark(location: String) -> bool:
	return lights_out or dark_rooms.has(location)

func set_player_info(new_name: String, new_gender: String = "", new_appearance: int = -1) -> void:
	if new_name.strip_edges() != "":
		player_name = new_name.strip_edges()
		player_named = true
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
	# A próxima tarefa só começa sozinha se for da mesma fase.
	# Na virada de fase o roteiro da fase (Fase1Flow/Fase2Flow) mostra o cartão e chama start_task.
	if TASK_NAMES.has(next_task) and TASK_PHASE.get(next_task, 0) == current_phase:
		start_task(next_task)
	else:
		advance_phase()

func advance_phase() -> void:
	current_phase += 1
	current_task_id = 0
	current_task_name = "Fase %d concluída!" % (current_phase - 1)
	if current_phase > LAST_PHASE:
		current_task_name = "Jogo concluído!"
	task_updated.emit(current_task_id, current_task_name)
	if current_phase > LAST_PHASE:
		set_objective("")
	elif first_task_of_phase(current_phase) == 0:
		set_objective("A Fase %d está em desenvolvimento. Obrigado por testar!" % current_phase)
	else:
		set_objective("")
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
