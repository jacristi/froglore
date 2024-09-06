extends Area2D


@export_multiline var dialogue_text:= 'No Text Defined'
@export var show_sprite:= true
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
    if not show_sprite:
        sprite_2d.hide()

func _on_body_entered(body: Node2D) -> void:
    Events.show_dialogue.emit(dialogue_text, 0)


func _on_body_exited(body: Node2D) -> void:
    Events.hide_dialogue.emit()
