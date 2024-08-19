extends Area2D


var is_collected := false


func _on_body_entered(_area: CharacterBody2D):
    if is_collected: return

    collect()


func collect():
    Events.light_bug_collected.emit()
    set_self_inactive()


func set_self_inactive():
    is_collected = true
    hide()


func set_self_acive():
    is_collected = false
    show()
