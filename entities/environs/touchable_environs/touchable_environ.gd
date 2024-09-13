extends Area2D


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var is_touched := false

func _ready() -> void:
    animated_sprite_2d.play("idle")


func _on_body_entered(_body: Node2D) -> void:
    if is_touched: return
    is_touched = true
    animated_sprite_2d.play("touched")
    Events.grass_rustled.emit()
    await animated_sprite_2d.animation_finished
    animated_sprite_2d.play("idle")
    is_touched = false
