class_name StarfallGhost
extends Sprite2D


func _ready() -> void:
    Events.player_starfall_ended.connect(queue_free)
    ghosting()


func set_props(tx_pos: Vector2, tx_scale: Vector2) -> void:
    """ """
    position = tx_pos
    scale = tx_scale


func ghosting():
    """ """
    var tween_fade = get_tree().create_tween()

    tween_fade.tween_property(self, "self_modulate", Color(1, 1, 1, 0), 0.5)
    await tween_fade.finished

    queue_free()
