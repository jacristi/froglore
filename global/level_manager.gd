extends Node

var current_level = '':
    set(value):
        current_level = value
        Events.level_loaded.emit(current_level)


@export var levels_dict: Dictionary

enum level_states {
    LOCKED,     # Not available to view/play
    UNLOCKED,   # available to view/play
    STARTED,    # started but not gotten to end
    FINISHED,   # finished level but some items not collected
    COMPLETED,  # all items collected/completed
    }

var level_states_dict: Dictionary

var in_semi_pause_state:= false

var has_finished_all_completed:= false
var has_finished_all_purified:= false

var last_level:= "level_1"


func _ready() -> void:
    """ """
    Events.go_to_level.connect(go_to_level)
    Events.try_exit_game.connect(exit_game)

    ### Set Level Default States
    for level in levels_dict:
        level_states_dict[level] = level_states.LOCKED


func get_level_by_key(level_key: String):
    """ """
    return levels_dict[level_key]


func go_to_level(to_level_key: String, from_level_key: String) -> void:
    """ """
    # TODO if saved, find last loc and go there

    last_level = from_level_key

    get_tree().paused = true
    await get_tree().create_timer(.5).timeout
    await LevelTransition.fade_to_black()
    get_tree().change_scene_to_file(get_level_by_key(to_level_key))
    await LevelTransition.fade_from_black()
    get_tree().paused = false


func update_level_state(level_key: String, new_state: level_states):
    """ """
    var cur_state = level_states_dict[level_key]

    if cur_state == new_state: return

    level_states_dict[level_key] = new_state


func get_level_state(level_key: String) -> level_states:
    """ """
    return level_states_dict[level_key]



func exit_game():
    """ """
    await get_tree().create_timer(.5).timeout
    get_tree().quit()
