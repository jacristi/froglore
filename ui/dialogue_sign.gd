extends Area2D


@export_multiline var dialogue_text := ''
@export var show_sprite := true
@export var show_once := false
@onready var sprite_2d: Sprite2D = $Sprite2D

var player_in_range:= false
var has_shown := false

func _ready() -> void:
    Events.should_show_dialogue.connect(show_dialogue_if_player_in_range)
    if not show_sprite:
        sprite_2d.hide()

func _on_body_entered(_body: Node2D) -> void:
    if show_once and has_shown: return
    has_shown = true
    if dialogue_text == '': return
    player_in_range = true

func _on_body_exited(_body: Node2D) -> void:
    Events.hide_dialogue.emit()
    player_in_range = false

func show_dialogue_if_player_in_range():
    if player_in_range:
        Events.show_dialogue.emit(dialogue_text, 0)

func set_text(text_to_set: String):
    dialogue_text = text_to_set
