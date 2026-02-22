@tool
class_name Room
extends Area2D


enum room_sizes {
    TINY,
    SMALL,
    MEDIUM,
    LARGE,
}

var _room_size_dict = {
    room_sizes.TINY:    Vector2(64, 36),
    room_sizes.SMALL:   Vector2(160, 90),
    room_sizes.MEDIUM:  Vector2(256, 144),
    room_sizes.LARGE:   Vector2(384, 216),
}

@export var room_size: room_sizes = room_sizes.MEDIUM:
    set(value):
        if room_size == value: return
        room_size = value
        set_room_shape_from_room_size()

@export var room_pos: Vector2:
    set(value):
        room_pos = value

@export var is_active:= true
@export var show_water:= true
@export var show_stars:= true
@export var keep_override_pos:= false
@export var room_objects: PackedScene
var _loaded_objects: Node2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _on_body_entered(_body: Node2D) -> void:
    if !is_active: return
    if room_objects != null and _loaded_objects == null:
        print('loading room objects')
        _loaded_objects = room_objects.instantiate()
        get_tree().current_scene.add_child.call_deferred(_loaded_objects)

    Events.room_entered.emit(
        position,
        _room_size_dict[room_size],
        show_water,
        show_stars
        )

func _ready() -> void:
    set_room_shape_from_room_size()


func get_collision_shape():
    for ch in get_children():
        if ch is CollisionShape2D:
            collision_shape_2d = ch

func set_room_shape_from_room_size():
    """ """
    if collision_shape_2d == null: get_collision_shape()
    if collision_shape_2d == null: return
    collision_shape_2d.shape.size = Vector2(
        _room_size_dict[room_size].x - GlobalData.room_collision_margin.x,
        _room_size_dict[room_size].y - GlobalData.room_collision_margin.y,
        )


func _on_body_exited(_body: Node2D) -> void:
    if _loaded_objects != null:
        print('unloading room objects')
        _loaded_objects.queue_free()
