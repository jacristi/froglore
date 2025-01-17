@tool
extends Sprite2D


func _ready() -> void:
    _zoom_changed()


func _process(_delta: float) -> void:
    _zoom_changed()


func _zoom_changed():
    material.set_shader_parameter("y_zoom", get_viewport_transform().get_scale().y)


func _on_item_rect_changed() -> void:
    material.set_shader_parameter("scale", scale)
