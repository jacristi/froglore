extends StaticBody2D


enum states {INACTIVE, ACTIVATING, ACTIVE, DEACTIVATING}
var state = states.INACTIVE
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var starts_active := false
@export var block_color := "blue"

func _ready() -> void:
    set_collision_layer_value(1, false)
    if starts_active:
        state = states.ACTIVE
        set_collision_layer_value(1, true)
    Events.butterfly_statue_activated.connect(change_state)
    Events.butterfly_statue_deactivated.connect(change_state)
    handle_initial_states()


func handle_initial_states() -> void:
    if state == states.INACTIVE:
        animated_sprite_2d.play("inactive")
    if state == states.ACTIVE or starts_active:
        animated_sprite_2d.play("active")


func set_state_active():
    if state == states.ACTIVE or state == states.ACTIVATING: return
    state = states.ACTIVATING
    set_collision_layer_value(1, true)
    animated_sprite_2d.play("activating")
    await animated_sprite_2d.animation_finished

    state = states.ACTIVE
    animated_sprite_2d.play("active")


func set_state_inactive():
    if state == states.INACTIVE or state == states.DEACTIVATING: return

    set_collision_layer_value(1, false)
    if state != states.INACTIVE:
        animated_sprite_2d.play("deactivating")
        await animated_sprite_2d.animation_finished

    state = states.INACTIVE
    animated_sprite_2d.play("inactive")


func change_state(butterfly_color: String):
    if butterfly_color != block_color: return

    if state == states.ACTIVE or state == states.ACTIVATING:
        set_state_inactive()
    elif state == states.INACTIVE or state == states.DEACTIVATING:
        set_state_active()
