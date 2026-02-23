# A component that automatically destroys itself after playing an animation once.
class_name OneTimeAnimatedEffect
extends AnimatedSprite2D


@export var destroy_parent := true


func _ready() -> void:
    animation_finished.connect(_on_animation_done)
    animation_looped.connect(_on_animation_done)


func _on_animation_done() -> void:
    queue_free()

    if destroy_parent:
        get_parent().queue_free()
