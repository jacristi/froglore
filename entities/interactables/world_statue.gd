extends Area2D

enum states {inactive, ready, activating, active}
var state = states.inactive
var all_completed:= false
var all_purified:= false

@onready var ready_label: Label = $ReadyLabel

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var dialogue_text:= "..."

func _ready() -> void:
    get_warp_statue_states()
    set_state()


func get_warp_statue_states():

    var count_completed = 0
    var count_purified = 0
    var total = get_tree().get_nodes_in_group("WarpStatues").size()

    for statue in get_tree().get_nodes_in_group("WarpStatues"):
        if statue.level_state == LevelManager.level_states.FINISHED:
            count_completed += 1
        if statue.level_state == LevelManager.level_states.COMPLETED:
            count_completed += 1
            count_purified += 1

    if count_completed == total:
        all_completed = true

    if count_purified == total:
        all_purified = true


func set_state():
    if all_purified:
        state = states.active
        animated_sprite_2d.play("ready")
        dialogue_text = "I am listening little one"
        if not LevelManager.has_finished_all_purified:
            ready_label.show()
        else:
            dialogue_text = "Well done little one"

    elif all_completed:
        animated_sprite_2d.play("inactive")
        state = states.inactive
        dialogue_text = "I am listening little one"
        if not LevelManager.has_finished_all_completed:
            ready_label.show()
        else:
            dialogue_text = "There is more to do"

    else:
        animated_sprite_2d.play("inactive")
        state = states.inactive
        dialogue_text = "..."


func try_activate():
    if LevelManager.in_semi_pause_state: return
    if state == states.inactive and all_completed and not LevelManager.has_finished_all_completed:
        state = states.ready
        animated_sprite_2d.play("ready")
        Events.ready_world_statue.emit()
        ready_label.hide()
        LevelManager.has_finished_all_completed = true
        dialogue_text = "There is more to do"
        Events.hide_dialogue.emit()

    if state == states.active and not LevelManager.has_finished_all_purified:
        state = states.activating
        Events.activating_world_statue.emit()
        animated_sprite_2d.play("activating")
        dialogue_text = "Well done little one"
        Events.hide_dialogue.emit()
        await animated_sprite_2d.animation_finished
        print("THE FINAL CROAK!")
        state = states.active
        animated_sprite_2d.play("active")
        LevelManager.has_finished_all_purified = true
        Events.activated_world_statue.emit()
        ready_label.hide()
