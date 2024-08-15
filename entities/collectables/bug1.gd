extends Area2D



func _ready() -> void:
    pass

func _on_body_entered(area: CharacterBody2D):
    Events.bug_collected.emit()
    queue_free()


