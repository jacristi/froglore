class_name MenuItem
extends MarginContainer

@onready var menu_item_label: Label = %MenuItemLabel

@onready var left_selected_texture_rect:  TextureRect = %LeftSelectedTextureRect
@onready var right_selected_texture_rect: TextureRect = %RightSelectedTextureRect

@export var label_text: String

var is_selected_texture =  load("res://assets/spritesheets/ui/spr-ui-selected-indicator.png")
var not_selected_texture = load("res://assets/spritesheets/ui/spr-ui-notselected-indicator.png")


var is_selected:= true:
    set(value):
        if is_selected == value: return
        is_selected = value
        if is_selected:
            left_selected_texture_rect.texture = is_selected_texture
            right_selected_texture_rect.texture = is_selected_texture
        else:
            left_selected_texture_rect.texture = not_selected_texture
            right_selected_texture_rect.texture = not_selected_texture

func _ready() -> void:
    is_selected = false
    menu_item_label.text = label_text
