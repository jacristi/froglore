class_name FlashSpriteComponent
extends Node


var timer: Timer = Timer.new()
var original_sprite_material: Material

var continuous_timer: Timer = Timer.new()

@export var sprite: CanvasItem
@export var flash_duration: = 0.2
@export var flash_material: Material = preload("res://effects/white_flash_material.tres")

var is_flashing := false
var is_flashing_continuous := false

func _ready() -> void:
    add_child(timer)
    add_child(continuous_timer)
    original_sprite_material = sprite.material

    continuous_timer.autostart = false
    continuous_timer.one_shot = false
    continuous_timer.timeout.connect(flash)


func flash() -> void:
    """
        1. Set sprite material to flash material
        2. Wait for timer to complete
        3. Reset sprite material to original
    """
    if is_flashing: return

    sprite.material = flash_material
    is_flashing = true

    timer.start(flash_duration)
    await timer.timeout

    sprite.material = original_sprite_material
    is_flashing = false


func start_flash_continuous_intervals(interval_length: float):
    if is_flashing_continuous:
        stop_flash_continuous_intervals()

    is_flashing_continuous = true
    continuous_timer.wait_time = interval_length
    continuous_timer.start()

func stop_flash_continuous_intervals():
    if not is_flashing_continuous: return

    is_flashing_continuous = false
    continuous_timer.stop()
