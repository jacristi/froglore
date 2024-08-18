extends Node

var current_level = ''

@export var levels_dict: Dictionary

enum level_states {NOT_COMPLETED, COMPLETED, PURIFIED}
var level_states_dict: Dictionary


func _ready() -> void:
    Events.level_completed.connect(update_level_completed)
    Events.go_to_level.connect(go_to_level)

    ### LOAD LEVEL STATES
    for level in levels_dict:
        level_states_dict[level] = level_states.NOT_COMPLETED


func get_level_by_key(level_key: String):
    return levels_dict[level_key]


func go_to_level(level_key: String) -> void:
    get_tree().paused = true
    await get_tree().create_timer(1.0).timeout
    await LevelTransition.fade_to_black()
    get_tree().change_scene_to_file(get_level_by_key(level_key))
    await LevelTransition.fade_from_black()
    get_tree().paused = false


func update_level_completed(level_key: String):
    var curr_state = level_states_dict[level_key]
    if curr_state < level_states.COMPLETED:
        level_states_dict[level_key] = level_states.COMPLETED


func get_level_state(level_key: String) -> level_states:
    return level_states_dict[level_key]
