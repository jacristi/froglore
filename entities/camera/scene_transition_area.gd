extends Area2D

@export var from_level_key:= "N/A"
@export var go_to_level_key:= "N/A"


func _on_body_entered(_body: Node2D) -> void:
    assert(from_level_key != "N/A")
    assert(go_to_level_key != "N/A")
    Events.go_to_level.emit(go_to_level_key, from_level_key)
