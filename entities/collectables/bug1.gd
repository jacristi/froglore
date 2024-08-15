extends Area2D



func _ready() -> void:
    pass
    ### Get total bugs in level
    ### on

func _on_body_entered(area: CharacterBody2D):
    var bugs = get_tree().get_nodes_in_group("Bugs")
    if bugs.size() == 1:
        Events.level_completed.emit()
    queue_free()


