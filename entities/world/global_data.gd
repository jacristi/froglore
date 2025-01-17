extends Node


@export var palette_white : Array[Color]
@export var palette_red : Array[Color]
@export var palette_yellow : Array[Color]
@export var palette_blue : Array[Color]
@export var palette_green : Array[Color]
@export var palette_frog : Array[Color]
@export var palette_purple : Array[Color]


var frog_palettes_dict : Dictionary
var frog_paletes_keys : Array


func _ready() -> void:
    frog_palettes_dict["red"] =     palette_red
    frog_palettes_dict["yellow"] =  palette_yellow
    frog_palettes_dict["frog"] =    palette_frog
    frog_palettes_dict["blue"] =    palette_blue
    frog_palettes_dict["purple"] =  palette_purple
    frog_palettes_dict["white"] =   palette_white
    frog_paletes_keys = frog_palettes_dict.keys()
