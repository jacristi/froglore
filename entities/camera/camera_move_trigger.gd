extends Area2D

@export var is_active:= true
@export var scroll_left_val: int
@export var scroll_right_val: int
@export var y_offset: int
@export var show_water:= true
@export var show_stars:= true


func _on_body_entered(_body: Node2D) -> void:
    if !is_active: return
