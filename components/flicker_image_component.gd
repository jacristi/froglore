class_name FlickerImageComponent
extends Node

@export var sprite: CanvasItem
@export var hold_time := 0.5
@export var fade_time := .25
@export var min_alpha := 0.0
@export var max_alpha := 1.0

var tween: Tween
var is_flickering := false :
    set(value):
        is_flickering = value
        if value:
            sprite.modulate.a = 1.0
            await get_tree().create_timer(hold_time/2).timeout
            tween.play()
        else:
            tween.stop()
            sprite.modulate.a = 1.0


func _ready() -> void:
    assert(sprite, "Sprite is not set")

    tween = get_tree().create_tween().set_loops()

    # Modulate between fully transparent and opaque
    tween.tween_property(sprite, "modulate:a", min_alpha, fade_time)
    tween.tween_property(sprite, "modulate:a", max_alpha, fade_time)

    # Add the hold time (if any) to the tween before looping
    if hold_time > 0:
        tween.tween_interval(hold_time)

    tween.stop()
