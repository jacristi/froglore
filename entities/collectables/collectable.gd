class_name Collectable
extends Area2D

@export var collectable_name: String
@export var collectable_type: String
@export var inactive_on_collect:= true

var collectable_key
var is_collected:= false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
    match collectable_type:
        "light_bug":    collectable_key = GameData.key_light_bug
        "portal_stone": collectable_key = GameData.key_portal_stone

    assert(collectable_name != "")
    Events.level_loaded.connect(check_save_data)


func check_save_data(lvl: String) -> void:
    """ """
    if !GameData.level_details.has(lvl): return
    if !GameData.level_details[lvl].has(collectable_key): return

    var c_name = collectable_name

    if GameData.level_details[lvl][collectable_key].has(c_name):
        if GameData.level_details[lvl][collectable_key][c_name]:
            collect_quietly()


func play_anim(anim_name: String):
    if !animated_sprite_2d: return
    animated_sprite_2d.play(anim_name)


func collect() -> void:
    """ """
    if is_collected: return
    is_collected = true
    Events.collectable_collected.emit(
        collectable_type,
        collectable_name,
        false)
    play_anim("collect")
    await animated_sprite_2d.animation_finished

    if inactive_on_collect:
        set_as_inactive()
    else:
        set_as_active()


func collect_quietly() -> void:
    """ """
    if is_collected: return
    is_collected = true
    Events.collectable_collected.emit(
        collectable_type,
        collectable_name,
        true)

    if inactive_on_collect:
        set_as_inactive()
    else:
        set_as_active()


func set_as_active() -> void:
    """ """
    show()
    play_anim("spawn")
    await animated_sprite_2d.animation_finished
    play_anim("idle")
    set_collision_layer_value(7, true)
    is_collected = false


func set_as_inactive() -> void:
    """ """
    set_collision_layer_value(7, false)
    hide()
