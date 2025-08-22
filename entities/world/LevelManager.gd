extends Node

var current_level = ''

var should_save_load:= false

const SAVE_PATH = "user://froglore_save.cfg"
const DEBUG_SAVE_PATH = "res://_data/froglore_save.cfg"
var save_path = SAVE_PATH

@export var levels_dict: Dictionary

enum level_states {NOT_COMPLETED, COMPLETED, PURIFIED}
var level_states_dict: Dictionary

@export var purified_overrides: Array[String]

var in_semi_pause_state:= false

var has_finished_all_completed:= false
var has_finished_all_purified:= false

var last_level:= "level_1"

func _ready() -> void:
    Events.level_completed.connect(update_leveL_completed)
    Events.level_reset.connect(update_level_reset)
    Events.level_purified.connect(update_level_purified)
    Events.go_to_level.connect(go_to_level)
    Events.try_exit_game.connect(exit_game)

    ### Set Level Default States
    for level in levels_dict:
        level_states_dict[level] = level_states.NOT_COMPLETED

    load_level_states()
    load_bool_vars()

    for level in purified_overrides:
        level_states_dict[level] = level_states.PURIFIED


func get_level_by_key(level_key: String):
    return levels_dict[level_key]


func go_to_level(level_key: String) -> void:
    if current_level == "title_scene" and should_save_load:
        level_key = last_level

    last_level = level_key
    save_data()

    get_tree().paused = true
    await get_tree().create_timer(1.0).timeout
    await LevelTransition.fade_to_black()
    get_tree().change_scene_to_file(get_level_by_key(level_key))
    await LevelTransition.fade_from_black()
    get_tree().paused = false


func update_level_state(level_key: String, new_state: level_states):
    var cur_state = level_states_dict[level_key]

    # Do not update if purified
    if cur_state == level_states.PURIFIED: return
    if cur_state == new_state: return

    level_states_dict[level_key] = new_state


func get_level_state(level_key: String) -> level_states:
    return level_states_dict[level_key]

func update_leveL_completed(level_key:String, _on_start: bool):
     update_level_state(level_key, level_states.COMPLETED)

func update_level_reset(level_key: String, _on_start: bool):
    update_level_state(level_key, level_states.NOT_COMPLETED)

func update_level_purified(level_key: String, _on_start: bool):
    update_level_state(level_key, level_states.PURIFIED)

func exit_game():
    save_data()
    await get_tree().create_timer(.5).timeout
    get_tree().quit()


func load_level_states():
    if not should_save_load: return

    var config = ConfigFile.new()
    var error = config.load(DEBUG_SAVE_PATH)
    if error != OK: return

    for level in level_states_dict:
        if (level == 'level_0' || level == "title_scene"):
            continue

        if not config.has_section_key("level_states", level):
            continue

        var state = config.get_value("level_states", level)

        if state == null:
            continue

        level_states_dict[level] = state as level_states


func save_data():
    if not should_save_load: return

    var config = ConfigFile.new()
    for level in level_states_dict:
        if (level == 'level_0' || level == "title_scene"):
            continue
        config.set_value("level_states", level, level_states_dict[level])

    config.set_value("bool_vars", "last_level", last_level)
    config.save(DEBUG_SAVE_PATH)


func load_bool_vars():
    if not should_save_load: return

    var config = ConfigFile.new()
    var error = config.load(DEBUG_SAVE_PATH)
    if error != OK: return
    if config.has_section_key("bool_vars", "last_level"):
        last_level = config.get_value("bool_vars", "last_level")
