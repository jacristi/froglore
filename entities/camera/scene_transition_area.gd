extends Area2D

@export var go_to_level_key:= "N/A"


func _on_body_entered(_body: Node2D) -> void:
    if go_to_level_key == "N/A": return
    Events.go_to_level.emit(go_to_level_key)
