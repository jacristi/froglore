extends Area2D

var is_collected := false
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
    Events.dark_bug_collected.connect(collect_along_others)


func _on_body_entered(_body: Node2D) -> void:
    if is_collected: return
    is_collected = true
    collect()


func collect():
    is_collected = true
    Events.dark_bug_collected.emit()
    animated_sprite_2d.play("collect")
    await animated_sprite_2d.animation_finished
    set_self_inactive()


func collect_along_others():
    if is_collected: return
    animated_sprite_2d.play("collect")
    await animated_sprite_2d.animation_finished
    set_self_inactive()


func set_self_inactive():
    is_collected = true
    hide()


func set_self_active():
    show()
    animated_sprite_2d.play("spawn")
    await animated_sprite_2d.animation_finished
    animated_sprite_2d.play("idle")
    is_collected = false
