extends Area2D

var is_collected := false
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var point_light_2d: PointLight2D = $PointLight2D


func _ready() -> void:
    Events.dark_bug_collected.connect(collect_along_others)
    Events.level_purified.connect(collect_as_purified)


func _on_body_entered(_body: Node2D) -> void:
    if is_collected: return
    is_collected = true
    collect()


func collect():
    is_collected = true
    point_light_2d.enabled = false
    Events.dark_bug_collected.emit()
    animated_sprite_2d.play("collect")
    await animated_sprite_2d.animation_finished
    set_self_inactive()


func collect_along_others():
    animated_sprite_2d.play("collect")
    point_light_2d.enabled = false
    await animated_sprite_2d.animation_finished
    set_self_inactive()


func set_self_inactive():
    is_collected = true
    hide()


func set_self_active():
    show()
    animated_sprite_2d.play("spawn")
    point_light_2d.enabled = true
    await animated_sprite_2d.animation_finished
    animated_sprite_2d.play("idle")
    is_collected = false


func collect_as_purified(_level_key: String, _on_start: bool):
    is_collected = true
    animated_sprite_2d.play("purified")
    point_light_2d.enabled = false
    await animated_sprite_2d.animation_finished
    set_self_inactive()
