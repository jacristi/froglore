@tool
extends Sprite2D

var start_pos:Vector2


func _ready() -> void:
    start_pos = position
    if not Engine.is_editor_hint():
        _zoom_changed()
        Events.room_entered.connect(room_changed)


func room_changed(
        room_pos: Vector2,
        show_water: bool,
        _show_stars:bool):
    """
        Move water with player viewport without being on canvas layer
        This makes it so its like being on a canvas layer
        and is configurable per screen
    """
    if show_water: show()
    else: hide()
    var x_left = room_pos.x * GlobalData.base_room_size.x
    var y_offset = room_pos.y * GlobalData.base_room_size.y
    position.x = start_pos.x + x_left
    position.y = start_pos.y + y_offset


func _process(_delta: float) -> void:
    _zoom_changed()


func _zoom_changed():
    material.set_shader_parameter("y_zoom", get_viewport_transform().get_scale().y)


func _on_item_rect_changed() -> void:
    material.set_shader_parameter("scale", scale)
