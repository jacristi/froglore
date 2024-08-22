extends Area2D

enum states {inactive, ready, activating, active}
var state = states.inactive
var all_completed:= false
var all_purified:= false


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
    get_warp_statue_states()
    set_state()


func get_warp_statue_states():

    var count_completed = 0
    var count_purified = 0
    var total = get_tree().get_nodes_in_group("WarpStatues").size()

    for statue in get_tree().get_nodes_in_group("WarpStatues"):
        if statue.level_state == LevelManager.level_states.COMPLETED:
            count_completed += 1
        if statue.level_state == LevelManager.level_states.PURIFIED:
            count_purified += 1

    if count_completed == total:
        all_completed = true

    if count_purified == total:
        all_purified = true

func set_state():
    if all_purified:
        state = states.active
        animated_sprite_2d.play("ready")
    elif all_completed:
        animated_sprite_2d.play("inactive")
        state = states.inactive
    else:
        animated_sprite_2d.play("inactive")
        state = states.inactive


func try_activate():
    if state == states.inactive and all_completed:
        state = states.ready
        animated_sprite_2d.play("ready")
        Events.ready_world_statue.emit()
        print('ready state')

    if state == states.active:
        state = states.activating
        Events.activating_world_statue.emit()
        animated_sprite_2d.play("activating")
        await animated_sprite_2d.animation_finished
        print("THE FINAL CROAK!")
        state = states.active
        animated_sprite_2d.play("active")
        Events.activated_world_statue.emit()
