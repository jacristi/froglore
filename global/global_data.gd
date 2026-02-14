extends Node


@export var palette_white : Array[Color]
@export var palette_red : Array[Color]
@export var palette_yellow : Array[Color]
@export var palette_blue : Array[Color]
@export var palette_green : Array[Color]
@export var palette_frog : Array[Color]
@export var palette_purple : Array[Color]

var input_type:= "keyboard"

var frog_palettes_dict : Dictionary
var frog_paletes_keys : Array

var base_resolution: Vector2

@export var base_room_size:= Vector2(256, 144)
@export var room_collision_margin:= Vector2(8, 8)



func _ready() -> void:
    frog_palettes_dict["red"] =     palette_red
    frog_palettes_dict["yellow"] =  palette_yellow
    frog_palettes_dict["frog"] =    palette_frog
    frog_palettes_dict["blue"] =    palette_blue
    frog_palettes_dict["purple"] =  palette_purple
    frog_palettes_dict["white"] =   palette_white
    frog_paletes_keys = frog_palettes_dict.keys()
    base_resolution = get_viewport().size


func _input(event: InputEvent) -> void:
    if event is not InputEventWithModifiers or event is not InputEventKey:
        return

    if event.shift_pressed and event.pressed and not event.is_echo():
        match event.keycode:
            KEY_1, KEY_KP_1:
                _apply_scale(Vector2(160, 90))
            KEY_2, KEY_KP_2:
                _apply_scale(Vector2(192, 108))
            KEY_3, KEY_KP_3:
                _apply_scale(Vector2(256, 144))
            KEY_4, KEY_KP_4:
                _apply_scale(Vector2(384, 216))


func _apply_scale(factor: Vector2) -> void:
    """ """
    get_viewport().set_content_scale_size(factor)
