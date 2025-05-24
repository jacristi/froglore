extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var start_delat: float = -1.0
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
    add_child(start_delay_timer)
    start_delay_timer.one_shot = true
    start_delay_timer.wait_time = randf_range(0, 6)
    start_delay_timer.timeout.connect(animated_sprite_2d.play.bind(anim))
    Events.light_bug_collected.connect(start_animation)
    start_animation_with_delay()


func start_animation():
    animated_sprite_2d.stop()
    animated_sprite_2d.play(anim)
    await get_tree().create_timer(.75).timeout
    start_animation_with_delay()


func start_animation_with_delay():
    animated_sprite_2d.stop()
    animated_sprite_2d.play(anim)
    animated_sprite_2d.pause()
    start_delay_timer.start()
