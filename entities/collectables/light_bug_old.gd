extends Area2D

var is_collected := false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collect_light_bug_effect: CPUParticles2D = $CollectLightBugEffect


func _on_body_entered(_area: CharacterBody2D):
    if is_collected: return
    is_collected = true
    collect()


func collect():
    is_collected = true
    collect_light_bug_effect.emitting = true
    animated_sprite_2d.play("collect")
    Events.light_bug_collected.emit()
    await animated_sprite_2d.animation_finished
    set_self_inactive()


func set_self_inactive():
    is_collected = true
    hide()


func set_self_active():
    show()
    animated_sprite_2d.play("spawn")
    Events.light_bug_spawn.emit()
    await animated_sprite_2d.animation_finished
    animated_sprite_2d.play("idle")
    is_collected = false
