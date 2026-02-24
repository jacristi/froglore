class_name RandomStartAnimatedSprite
extends AnimatedSprite2D

@export var start_animation_name:= "default"
@export var start_delay_max:= 1.0

var _start_delay

func _ready() -> void:
    _start_delay = randf_range(0.0, start_delay_max)
    start_animation_with_delay(_start_delay)

func start_animation_with_delay(delay_amt: float):
    await get_tree().create_timer(delay_amt).timeout
    play(start_animation_name)
