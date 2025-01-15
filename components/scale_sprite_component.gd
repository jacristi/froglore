class_name ScaleSpriteComponent
extends Node


@export var sprite: Node2D

@export_group("Scale Values")
@export var scale_amount = Vector2(1.5, 1.5)
@export var scale_duration: = 0.4


func tween_scale() -> void:
    var tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

    # Scale to 'scale_amount' for first 1/10 of duration
    tween.tween_property(sprite, "scale", scale_amount, scale_duration * 0.1).from_current()

    # Ease back to original size over the remaining 9/10 duration
    tween.tween_property(sprite, "scale", Vector2.ONE, scale_duration * 0.9).from(scale_amount)
