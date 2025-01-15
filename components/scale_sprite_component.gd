class_name ScaleSpriteComponent
extends Node


@export var sprite: Node2D

@export_group("Scale Values")
@export var scale_amount = Vector2(1.5, 1.5)
@export var scale_duration: = 0.4

var is_scaling_continuous := false
var continuous_timer: Timer = Timer.new()

func _ready() -> void:
    add_child(continuous_timer)
    continuous_timer.autostart = false
    continuous_timer.one_shot = false
    continuous_timer.timeout.connect(tween_scale)

func tween_scale() -> void:

    var tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

    # Scale to 'scale_amount' for first 1/10 of duration
    tween.tween_property(sprite, "scale", scale_amount, scale_duration * 0.1).from_current()

    # Ease back to original size over the remaining 9/10 duration
    tween.tween_property(sprite, "scale", Vector2.ONE, scale_duration * 0.9).from(scale_amount)


func start_scale_continuous_intervals(interval_length: float):
    if is_scaling_continuous:
        stop_scale_continuous_intervals()

    is_scaling_continuous = true
    continuous_timer.wait_time = interval_length
    continuous_timer.start()

func stop_scale_continuous_intervals():
    if not is_scaling_continuous: return

    is_scaling_continuous = false
    continuous_timer.stop()
