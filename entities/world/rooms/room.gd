@tool
extends Area2D


@export var room_pos: Vector2:
    set(value):
        room_pos = value
        set_position_from_room_pos()

@export var is_active:= true
@export var show_water:= true
@export var show_stars:= true
@export var keep_override_pos:= false
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _on_body_entered(_body: Node2D) -> void:
    if !is_active: return
    Events.room_entered.emit(
        room_pos,
        show_water,
        show_stars
        )

func set_position_from_room_pos():
    """ """
    if keep_override_pos: return
    var x_pos = (room_pos.x * GlobalData.room_size.x) + (GlobalData.room_size.x/2)
    var y_pos = (room_pos.y * GlobalData.room_size.y) + (GlobalData.room_size.y/2)
    position = Vector2(x_pos, y_pos)


func set_collision_shape_size():
    """ """
    collision_shape_2d.shape.size = Vector2(
        GlobalData.room_size.x - GlobalData.room_collision_margin.x,
        GlobalData.room_size.y - GlobalData.room_collision_margin.y)


func _ready() -> void:
    """ """
    set_collision_shape_size()
    set_position_from_room_pos()
