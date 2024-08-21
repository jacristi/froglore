extends Area2D

@export var level_key: String
var level_state

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
    level_state = LevelManager.get_level_state(level_key)
    if level_state == LevelManager.level_states.NOT_COMPLETED:
        animated_sprite_2d.play("inactive")
    if level_state == LevelManager.level_states.COMPLETED:
        animated_sprite_2d.play("active")
    if level_state == LevelManager.level_states.PURIFIED:
        animated_sprite_2d.play("purified")


func try_activate():
    if level_state == LevelManager.level_states.NOT_COMPLETED: return
    print("TRY ACTIVATE")
    Events.go_to_level.emit(level_key)
