extends Node2D

@export var curr_level: String = "N/A"
@export var prev_level: String = "N/A"
@export var next_level: String = "N/A"

@export_multiline var dialogue_new: String = "N/A"
@export_multiline var dialogue_completed: String = "N/A"
@export_multiline var dialogue_purified: String = "N/A"

@onready var level_exit: Area2D = $LevelExit
@onready var dialogue_sign: Area2D = $DialogueSign

var level_state = LevelManager.level_states.NOT_COMPLETED

var dark_bugs_total: int
var light_bugs_total: int
var light_bugs_collected: int

var count_total_statues: int
var count_statues_active: int = 0

var can_respawn_dark_bugs := false

@onready var end_credits: Control = $EndCredits


func _ready() -> void:
    level_exit.hide()
    level_exit.process_mode = Node.PROCESS_MODE_DISABLED
    Events.level_completed.connect(handle_level_completed)
    Events.level_purified.connect(handle_leveL_purified)
    Events.level_reset.connect(handle_level_reset)
    Events.light_bug_collected.connect(handle_light_bug_collected)
    Events.dark_bug_collected.connect(handle_dark_bug_collected)
    Events.frog_statue_activated.connect(handle_frog_statue_activated)
    Events.try_go_to_next_level.connect(go_to_next_level)
    Events.try_go_to_prev_level.connect(go_to_prev_level)
    Events.ready_world_statue.connect(start_end_credits)
    Events.activated_world_statue.connect(start_end_credits)

    LevelManager.current_level = curr_level
    level_state = LevelManager.get_level_state(curr_level)
    handle_on_start_level_state()

    light_bugs_total = get_tree().get_nodes_in_group("LightBugs").size()

    dark_bugs_total = get_tree().get_nodes_in_group("DarkBugs").size()

    count_total_statues = get_tree().get_nodes_in_group("FrogStatues").size()

    update_bug_state()
    update_statues_states()

func handle_on_start_level_state():
    if level_state == LevelManager.level_states.NOT_COMPLETED:
        Events.level_new.emit(curr_level, true)
        if dialogue_new != 'N/A': dialogue_sign.set_text(dialogue_new)
    if level_state == LevelManager.level_states.COMPLETED:
        Events.level_completed.emit(curr_level, true)
        if dialogue_completed != 'N/A': dialogue_sign.set_text(dialogue_completed)
    if level_state == LevelManager.level_states.PURIFIED:
        Events.level_purified.emit(curr_level, true)
        if dialogue_purified != 'N/A': dialogue_sign.set_text(dialogue_purified)


func update_bug_state():
    if level_state == LevelManager.level_states.COMPLETED or level_state == LevelManager.level_states.PURIFIED:
        for bug in get_tree().get_nodes_in_group("LightBugs"):
            bug.set_self_inactive()
    if level_state == LevelManager.level_states.NOT_COMPLETED or level_state == LevelManager.level_states.PURIFIED:
        for bug in get_tree().get_nodes_in_group("DarkBugs"):
            bug.set_self_inactive()


func update_statues_states():
    for statue in get_tree().get_nodes_in_group("FrogStatues"):
        if level_state == LevelManager.level_states.NOT_COMPLETED:
            statue.set_state_inactive()
        if level_state == LevelManager.level_states.COMPLETED:
            statue.set_state_ready()
        if level_state == LevelManager.level_states.PURIFIED:
            statue.set_state_active_start()


func respawn_light_bugs():
    for bug in get_tree().get_nodes_in_group("LightBugs"):
        bug.set_self_active()
        await get_tree().create_timer(1.0).timeout
    update_statues_states()


func respawn_dark_bugs():
    level_state = LevelManager.level_states.COMPLETED
    for bug in get_tree().get_nodes_in_group("DarkBugs"):
        if level_state == LevelManager.level_states.NOT_COMPLETED:
            return
        bug.set_self_active()
        Events.dark_bug_spawn.emit()
        await get_tree().create_timer(0.5).timeout
    update_statues_states()


func handle_level_completed(_level_key: String, _on_start: bool) -> void:

    level_exit.process_mode = Node.PROCESS_MODE_INHERIT
    level_exit.show()
    if can_respawn_dark_bugs:
        await get_tree().create_timer(5.0).timeout
        respawn_dark_bugs()


func handle_leveL_purified(_level_key: String, _on_start: bool) -> void:
    level_exit.process_mode = Node.PROCESS_MODE_INHERIT
    level_exit.show()


func go_to_next_level() -> void:
    if LevelManager.in_semi_pause_state: return
    if next_level == "N/A":
        Events.cannot_go_to_level.emit()
        return
    Events.go_to_next_level.emit()
    Events.go_to_level.emit(next_level)


func go_to_prev_level() -> void:
    if LevelManager.in_semi_pause_state: return
    if prev_level == "N/A":
        Events.cannot_go_to_level.emit()
        return

    Events.go_to_prev_level.emit()
    Events.go_to_level.emit(prev_level)


func handle_light_bug_collected():
    light_bugs_collected += 1

    if light_bugs_collected == light_bugs_total:
        Events.level_completed.emit(curr_level, false)


func handle_dark_bug_collected():
    Events.level_reset.emit(curr_level, false)


func handle_frog_statue_activated():
    count_statues_active += 1
    if count_statues_active == count_total_statues:
        Events.level_purified.emit(curr_level, false)


func handle_level_reset(_level_key: String, _on_start:bool):
    level_state = LevelManager.level_states.NOT_COMPLETED
    light_bugs_collected = 0
    count_statues_active = 0
    level_exit.process_mode = Node.PROCESS_MODE_DISABLED
    level_exit.hide()
    await get_tree().create_timer(5.0).timeout
    respawn_light_bugs()
    can_respawn_dark_bugs = true


func start_end_credits():
    end_credits.show()
    LevelManager.in_semi_pause_state = true
    level_exit.hide()
    level_exit.process_mode = Node.PROCESS_MODE_DISABLED
    await get_tree().create_timer(10.0).timeout
    LevelManager.in_semi_pause_state = false
    end_credits.hide()
    level_exit.process_mode = Node.PROCESS_MODE_INHERIT
    level_exit.show()
