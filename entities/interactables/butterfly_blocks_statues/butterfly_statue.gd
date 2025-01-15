extends Area2D


enum states {INACTIVE, ACTIVATING, ACTIVE, DEACTIVATING}
var state = states.INACTIVE
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var activate_cooldown_timer: Timer = $ActivateCooldownTimer

@export var starts_active := false
@export var butterfly_color := "blue"

var last_activated_time: float = 0

func _ready() -> void:
    if starts_active:
        state = states.ACTIVE
    handle_initial_states()


func handle_initial_states() -> void:
    if state == states.INACTIVE:
        animated_sprite_2d.play("inactive")
    if state == states.ACTIVE:
        animated_sprite_2d.play("active")


func set_state_active():
    if state == states.ACTIVE or state == states.ACTIVATING: return
    state = states.ACTIVATING
    Events.butterfly_statue_activated.emit(butterfly_color)
    animated_sprite_2d.play("activating")
    await animated_sprite_2d.animation_finished

    if state != states.ACTIVATING: return
    state = states.ACTIVE
    animated_sprite_2d.play("active")


func set_state_inactive():
    if state == states.DEACTIVATING: return
    state = states.DEACTIVATING
    Events.butterfly_statue_deactivated.emit(butterfly_color)
    if state != states.INACTIVE:
        animated_sprite_2d.play("deactivating")
        await animated_sprite_2d.animation_finished

    if state != states.DEACTIVATING: return

    state = states.INACTIVE
    animated_sprite_2d.play("inactive")


func try_activate():
    if LevelManager.in_semi_pause_state: return
    if not _can_try_activate(): return

    activate_cooldown_timer.start()
    if state == states.INACTIVE:
        set_state_active()
    if state == states.ACTIVE:
        set_state_inactive()


func _can_try_activate() -> bool: return activate_cooldown_timer.time_left < .01
