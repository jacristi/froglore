extends Area2D


enum states {INACTIVE, READY, ACTIVATING, ACTIVE}
var state = states.INACTIVE
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var override_active_state:= false

func _ready() -> void:
    Events.dark_bug_collected.connect(set_state_inactive)
    handle_initial_states()


func handle_initial_states() -> void:
    randomize()
    await get_tree().create_timer(randf_range(0, 1.5)).timeout
    if state == states.INACTIVE:
        animated_sprite_2d.play("inactive")
    if state == states.READY:
        animated_sprite_2d.play("ready")
    if state == states.ACTIVE or override_active_state:
        animated_sprite_2d.play("active")


func set_state_inactive():
    state = states.INACTIVE
    animated_sprite_2d.play("inactive")


func set_state_ready():
    state = states.READY
    await get_tree().create_timer(randf_range(0, 1.5)).timeout
    animated_sprite_2d.play("ready")


func set_state_active():
    if state == states.ACTIVE or state == states.ACTIVATING: return
    state = states.ACTIVATING
    Events.frog_statue_activating.emit()
    animated_sprite_2d.play("activating")
    await animated_sprite_2d.animation_finished
    state = states.ACTIVE
    animated_sprite_2d.play("active")
    Events.frog_statue_activated.emit()


func set_state_active_start():
    state = states.ACTIVE
    await get_tree().create_timer(randf_range(0, 1.5)).timeout
    animated_sprite_2d.play("active")


func try_activate():
    if state != states.READY: return
    set_state_active()

