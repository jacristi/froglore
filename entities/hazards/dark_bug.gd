extends Area2D

var is_collected := false
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _on_body_entered(_body: Node2D) -> void:
    if is_collected: return
    collect()


func collect():
    if is_collected: return
    is_collected = true
    Events.dark_bug_collected.emit()
    animated_sprite_2d.play("collect")
    await animated_sprite_2d.animation_finished


func collect_along_others():
    animated_sprite_2d.play("collect")
    is_collected = true
    await animated_sprite_2d.animation_finished


func set_self_inactive():
    hide()
    is_collected = true


func set_self_active():
    show()
    animated_sprite_2d.play("spawn")
    await animated_sprite_2d.animation_finished
    animated_sprite_2d.play("idle")
    is_collected = false


func collect_as_purified(_level_key: String, _on_start: bool):
    is_collected = true
    animated_sprite_2d.play("purified")
    await animated_sprite_2d.animation_finished
    Events.level_purified_done.emit()
