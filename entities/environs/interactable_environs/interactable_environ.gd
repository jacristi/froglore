extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var activate_once:= false

enum states {INACTIVE, ACTIVATING, ACTIVATED}
var state = states.INACTIVE


func _ready() -> void:
    animated_sprite_2d.play("inactive")


func try_activate() -> void:
    if state != states.INACTIVE: return
    state = states.ACTIVATING
    animated_sprite_2d.play("activating")
    await animated_sprite_2d.animation_finished
    if activate_once:
        state = states.ACTIVATED
        animated_sprite_2d.play("activated")
    else:
        state = states.INACTIVE
        animated_sprite_2d.play("inactive")
