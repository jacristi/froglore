extends Node

var current_level = ''

@export var levels_dict: Dictionary

enum level_states {NOT_COMPLETED, COMPLETED, PURIFIED}
var level_states_dict: Dictionary


func _ready() -> void:
    Events.level_completed.connect(update_level_state)
    Events.level_reset.connect(update_level_reset)
    Events.level_purified.connect(update_level_purified)
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


func update_level_state(level_key: String, new_state: level_states = level_states.COMPLETED):
    var cur_state = level_states_dict[level_key]

    # Do not update if purified
    if cur_state == level_states.PURIFIED: return
    if cur_state == new_state: return
    print("Update from " + str(cur_state) + " to " + str(new_state) + ": " + level_key)

    level_states_dict[level_key] = new_state


func get_level_state(level_key: String) -> level_states:
    return level_states_dict[level_key]


func update_level_reset(level_key: String):
    print("Update to not complete: " + level_key)
    update_level_state(level_key, level_states.NOT_COMPLETED)


func update_level_purified(level_key: String):
    print("Update to purified: " + level_key)
    update_level_state(level_key, level_states.PURIFIED)
