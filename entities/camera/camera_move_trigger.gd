extends Area2D

@export var scroll_left_val: int
@export var scroll_right_val: int


func _on_body_entered(body: Node2D) -> void:
    Events.camera_change_scroll_vals.emit(scroll_left_val, scroll_right_val)

