extends Node2D

@export var curr_level: String = "N/A"
@export var prev_level: String = "N/A"
@export var next_level: String = "N/A"

@onready var level_exit: Area2D = $LevelExit

var level_state = LevelManager.level_states.NOT_COMPLETED

var main_light: DirectionalLight2D
var initial_light_energy: float

var bugs_total: int
var bugs_collected: int

var light_incr_amt: float

var is_level_completed:= false


func _ready() -> void:
    level_exit.hide()
    level_exit.process_mode = 4
    Events.level_completed.connect(show_level_completed)
    Events.bug_collected.connect(handle_bug_collected)
    Events.go_to_next_level.connect(go_to_next_level)
    Events.go_to_prev_level.connect(go_to_prev_level)
    main_light = get_tree().get_nodes_in_group("MainLight")[0]
    initial_light_energy = main_light.energy

    bugs_total = get_tree().get_nodes_in_group("Bugs").size()
    light_incr_amt = initial_light_energy / bugs_total

    level_state = LevelManager.get_level_state(curr_level)


func show_level_completed(_level_key: String) -> void:
    level_exit.process_mode = 0
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


func handle_bug_collected():
    bugs_collected += 1
    main_light.energy -= light_incr_amt*.4

    if bugs_collected == bugs_total:
        Events.level_completed.emit(curr_level)
        main_light.energy = 0
        await get_tree().create_timer(.5).timeout
