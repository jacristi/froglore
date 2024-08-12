extends Node2D


@onready var collision_polygon_2d: CollisionPolygon2D = $StaticBody2D/CollisionPolygon2D
@onready var polygon_2d: Polygon2D = $StaticBody2D/CollisionPolygon2D/Polygon2D
@onready var level_complete: ColorRect = $CanvasLayer/LevelComplete


func _ready() -> void:
    polygon_2d.polygon = collision_polygon_2d.polygon
    Events.level_completed.connect(show_level_completed)


func show_level_completed():
    level_complete.show()
    get_tree().paused = true
