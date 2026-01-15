extends Area2D

@export var level_key: String
var level_state

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var dialogue_text:= "Speak and you shall go"

func _ready() -> void:
    level_state = LevelManager.get_level_state(level_key)
    handle_initial_states()


func handle_initial_states():
    if level_state < LevelManager.level_states.FINISHED:
        animated_sprite_2d.play("inactive")
        dialogue_text = "..."
    if level_state == LevelManager.level_states.FINISHED:
        randomize()
        await get_tree().create_timer(randf_range(0, 1.5)).timeout
        animated_sprite_2d.play("active")
        dialogue_text = "Speak and you shall go"
    if level_state == LevelManager.level_states.COMPLETED:
        animated_sprite_2d.play("purified")
        dialogue_text = "Speak and you shall go"


func try_activate():
    if LevelManager.in_semi_pause_state: return
    if level_state < LevelManager.level_states.FINISHED: return
    Events.go_to_level.emit(level_key, LevelManager.current_level)
