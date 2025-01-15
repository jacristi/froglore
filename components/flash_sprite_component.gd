class_name FlashSpriteComponent
extends Node


var timer: Timer = Timer.new()
var original_sprite_material: Material

@export var sprite: CanvasItem
@export var flash_duration: = 0.2
@export var flash_material: Material = preload("res://effects/white_flash_material.tres")


func _ready() -> void:
    add_child(timer)
    original_sprite_material = sprite.material


func flash() -> void:
    """
        1. Set sprite material to flash material
        2. Wait for timer to complete
        3. Reset sprite material to original
    """

    sprite.material = flash_material

    timer.start(flash_duration)
    await timer.timeout

    sprite.material = original_sprite_material
