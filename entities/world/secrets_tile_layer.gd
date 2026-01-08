extends TileMapLayer


@export var reveal_area: Area2D

var is_revealed:= false:
    set(value):
        is_revealed = value
        if is_revealed:
            hide()

func _ready() -> void:
    reveal_area.body_entered.connect(_on_reveal_body_entered)


func _on_reveal_body_entered(_body: Node2D) -> void:
    """ """
    if is_revealed: return

    is_revealed = true
    Events.secret_found.emit()
