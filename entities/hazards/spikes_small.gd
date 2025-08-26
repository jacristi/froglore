extends Node2D

var start_delay_timer:= Timer.new()
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
    add_child(start_delay_timer)
    start_delay_timer.one_shot = true
    start_delay_timer.wait_time = randf_range(0, 1.5)
    start_delay_timer.timeout.connect(animated_sprite_2d.play.bind("default"))
    start_animation_with_delay()


func start_animation_with_delay():
    animated_sprite_2d.stop()
    animated_sprite_2d.play("default")
    animated_sprite_2d.pause()
    start_delay_timer.start()
