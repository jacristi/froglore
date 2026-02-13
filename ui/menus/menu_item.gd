class_name MenuItem
extends MarginContainer

@onready var menu_item_label: Label = %MenuItemLabel

@onready var left_selected_texture_rect:  TextureRect = %LeftSelectedTextureRect
@onready var right_selected_texture_rect: TextureRect = %RightSelectedTextureRect
@onready var left_flicker_component: FlickerImageComponent = %LeftFlickerComponent
@onready var right_flicker_component: FlickerImageComponent = %RightFlickerComponent

@export var label_text: String

var is_selected_texture =  load("res://assets/spritesheets/ui/spr-ui-selected-indicator.png")
var not_selected_texture = load("res://assets/spritesheets/ui/spr-ui-empty-indicator.png")

var is_enabled:= true:
    set(value):
        if is_enabled == value: return
        is_enabled = value
        if is_enabled:
            menu_item_label.modulate.r = 1.0
            menu_item_label.modulate.g = 1.0
            menu_item_label.modulate.b = 1.0
        else:
            menu_item_label.modulate.r = .4
            menu_item_label.modulate.g = .4
            menu_item_label.modulate.b = .4

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

        left_flicker_component.is_flickering = is_selected
        right_flicker_component.is_flickering = is_selected

func _ready() -> void:
    is_selected = false
    menu_item_label.text = label_text
