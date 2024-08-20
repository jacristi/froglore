extends Area2D


enum states {INACTIVE, READY, ACTIVE}
var state = states.INACTIVE
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
    Events.dark_bug_collected.connect(set_state_inactive)


func _process(_delta: float) -> void:
    if state == states.INACTIVE:
        animated_sprite_2d.play("inactive")
    if state == states.READY:
        animated_sprite_2d.play("ready")
    if state == states.ACTIVE:
        animated_sprite_2d.play("active")


func set_state_inactive():
    state = states.INACTIVE


func set_state_ready():
    state = states.READY


func set_state_active():
    animated_sprite_2d.play("activing")
    await animated_sprite_2d.animation_finished
    state = states.ACTIVE
    Events.frog_statue_activated.emit()
