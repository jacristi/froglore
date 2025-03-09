extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


var start_delay_timer:= Timer.new()
var anim = "star_1"
var animation_names = [
        "star_1",
        "star_2",
        "star_3",
        #"star_4",
        "star_5",
        "none"
    ]

func _ready() -> void:
    anim = animation_names.pick_random()
    animated_sprite_2d.play(anim)
    animated_sprite_2d.pause()
    add_child(start_delay_timer)
    start_delay_timer.one_shot = true
    start_delay_timer.wait_time = randf_range(0, 6)
    start_delay_timer.timeout.connect(animated_sprite_2d.play.bind(anim))
    start_delay_timer.start()
