extends Area2D

var is_collected := false
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _on_body_entered(_body: Node2D) -> void:
    if is_collected: return
    is_collected = true
    collect()


func collect():
    is_collected = true
    Events.dark_bug_collected.emit()
    animated_sprite_2d.play("collect")
    print(">>> PLAY COLLECT ANIM")
    await animated_sprite_2d.animation_finished
    set_self_inactive()


func set_self_inactive():
    print(">>> SET INACTIVE")
    is_collected = true
    hide()


func set_self_active():
    show()
    animated_sprite_2d.play("spawn")
    await animated_sprite_2d.animation_finished
    animated_sprite_2d.play("idle")
    is_collected = false
