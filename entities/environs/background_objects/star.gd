extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var start_delat: float = -1.0

var start_pos: Vector2

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
    """ """
    start_pos = position
    Events.light_bug_collected.connect(start_animation)
    Events.camera_change_scroll_vals.connect(camera_scroll_changed)
    set_up()


func camera_scroll_changed(
        x_left,
        _x_right,
        y_offset,
        _show_water: bool,
        show_stars: bool):
    """
        Move stars with player viewport without being on canvas layer
        This makes it so its like being on a canvas layer
        but can preoperly hide behind ground and show in water relfection
        and is configurable on/off per screen
    """
    if show_stars: show()
    else: hide()
    position.x = start_pos.x + x_left
    position.y = start_pos.y + y_offset

    set_up()


func set_up() -> void:
    anim = animation_names.pick_random()
    start_delay_timer = Timer.new()
    add_child(start_delay_timer)
    start_delay_timer.one_shot = true
    start_delay_timer.wait_time = randf_range(0, 6)
    start_delay_timer.timeout.connect(animated_sprite_2d.play.bind(anim))
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
