extends Area2D

var is_collected := false


func _on_body_entered(_body: Node2D) -> void:
    if is_collected: return

    collect()


func collect():
    Events.dark_bug_collected.emit()
    set_self_inactive()


func set_self_inactive():
    is_collected = true
    hide()


func set_self_active():
    is_collected = false
    show()
