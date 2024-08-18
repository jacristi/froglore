extends Node

var current_level = ''

@export var levels_dict: Dictionary


func _ready() -> void:
    Events.go_to_level.connect(go_to_level)


func get_level_by_key(level_key: String):
    return levels_dict[level_key]


func go_to_level(level_key: String) -> void:
    get_tree().paused = true
    await get_tree().create_timer(1.0).timeout
    await LevelTransition.fade_to_black()
    get_tree().change_scene_to_file(get_level_by_key(level_key))
    await LevelTransition.fade_from_black()
    get_tree().paused = false
