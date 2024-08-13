extends Node2D

@export var next_level: PackedScene

@onready var level_complete: ColorRect = $CanvasLayer/LevelComplete


func _ready() -> void:
    Events.level_completed.connect(show_level_completed)


func show_level_completed() -> void:
    level_complete.show()
    go_to_next_level()


func go_to_next_level() -> void:
    get_tree().paused = true
    await get_tree().create_timer(1.0).timeout
    if not next_level is PackedScene: return
    await LevelTransition.fade_to_black()
    get_tree().paused = false
    get_tree().change_scene_to_packed(next_level)
    await LevelTransition.fade_from_black()
