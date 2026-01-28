@tool
extends Sprite2D

var start_pos:Vector2

func _ready() -> void:
    start_pos = position
    _zoom_changed()
    Events.camera_change_scroll_vals.connect(camera_scroll_changed)


func camera_scroll_changed(
        x_left: int,
        _x_right: int,
        y_offset: int,
        show_water: bool,
        _show_stars:bool):
    """
        Move water with player viewport without being on canvas layer
        This makes it so its like being on a canvas layer
        and is configurable per screen
    """
    if show_water: show()
    else: hide()
    position.x = start_pos.x + x_left
    position.y = start_pos.y + y_offset


func _process(_delta: float) -> void:
    _zoom_changed()


func _zoom_changed():
    material.set_shader_parameter("y_zoom", get_viewport_transform().get_scale().y)


func _on_item_rect_changed() -> void:
    material.set_shader_parameter("scale", scale)
