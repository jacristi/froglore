extends Node2D

@export var curr_level: String = "N/A"
@export var prev_level: String = "N/A"
@export var next_level: String = "N/A"

@onready var level_exit: Area2D = $LevelExit

var level_state = LevelManager.level_states.NOT_COMPLETED

var main_light: DirectionalLight2D
var initial_light_energy: float

var light_bugs_total: int
var light_bugs_collected: int

var light_incr_amt: float

var is_level_completed:= false

var count_total_statues: int
var count_statues_active: int = 0

func _ready() -> void:
    level_exit.hide()
    level_exit.process_mode = Node.PROCESS_MODE_DISABLED
    Events.level_completed.connect(handle_level_completed)
    Events.level_reset.connect(handle_level_reset)
    Events.light_bug_collected.connect(handle_light_bug_collected)
    Events.dark_bug_collected.connect(handle_dark_bug_collected)
    Events.frog_statue_activated.connect(handle_frog_statue_activated)
    Events.go_to_next_level.connect(go_to_next_level)
    Events.go_to_prev_level.connect(go_to_prev_level)
    main_light = get_tree().get_nodes_in_group("MainLight")[0]
    initial_light_energy = main_light.energy

    light_bugs_total = get_tree().get_nodes_in_group("LightBugs").size()
    light_incr_amt = initial_light_energy / light_bugs_total

    count_total_statues = get_tree().get_nodes_in_group("FrogStatues").size()

    level_state = LevelManager.get_level_state(curr_level)
    update_bug_state()
    update_statues_states()


func update_bug_state():
    if level_state == LevelManager.level_states.COMPLETED or level_state == LevelManager.level_states.PURIFIED:
        Events.level_completed.emit(curr_level)
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


func respawn_dark_bugs():
    for bug in get_tree().get_nodes_in_group("DarkBugs"):
        bug.set_self_active()
        await get_tree().create_timer(1.0).timeout


func handle_level_completed(_level_key: String) -> void:
    main_light.energy = 0
    level_exit.process_mode = Node.PROCESS_MODE_INHERIT
    level_exit.show()
    is_level_completed = true


func go_to_next_level() -> void:
    if next_level == "N/A":
        return
    Events.go_to_level.emit(next_level)


func go_to_prev_level() -> void:
    if prev_level == "N/A":
        return
    Events.go_to_level.emit(prev_level)


func handle_light_bug_collected():
    light_bugs_collected += 1
    main_light.energy -= light_incr_amt*.6

    if light_bugs_collected == light_bugs_total:
        Events.level_completed.emit(curr_level)


func handle_dark_bug_collected():
    Events.level_reset.emit(curr_level)
    main_light.energy = initial_light_energy


func handle_frog_statue_activated():

    count_statues_active += 1
    if count_statues_active == count_total_statues:
        print("PURIFY LEVEL!!!")
        Events.level_purified.emit(curr_level)


func handle_level_reset(_level_key: String):
    level_state = LevelManager.level_states.NOT_COMPLETED
    level_exit.process_mode = Node.PROCESS_MODE_DISABLED
    level_exit.hide()
    await get_tree().create_timer(5.0).timeout
    respawn_light_bugs()
