class_name PortalStone
extends Area2D

@export var stone_number: int
@export var is_unlocked: bool

var _is_unlocked:= false:
    set(value):
        _is_unlocked = value
        if _is_unlocked:
            Events.portal_stone_unlocked.emit(stone_number, position)


func _ready() -> void:
    _is_unlocked = is_unlocked
