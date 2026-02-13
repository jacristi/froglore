class_name Menu
extends MarginContainer

var is_active = true:
    set(value):
        if is_active == value: return
        is_active = value

var _menu_items: Dictionary[int, MenuItem]
@onready var menu_item_list: VBoxContainer = $MenuItemList
@onready var header: Label = $MenuItemList/Header

var max_idx:= 1
var selected_idx:= 0:
    set(value):
        if selected_idx == value: return
        selected_idx = value
        for k in _menu_items.keys():
            _menu_items[k].is_selected = k == selected_idx

var menu_item_scene = load("res://ui/menus/menu_item.tscn")
@export var header_text: String = "Header"
@export var menu_items_dict: Dictionary[String, String]

func _ready() -> void:
    """ """
    header.text = header_text
    var count = 0
    for txt in menu_items_dict.keys():
        var item: MenuItem = menu_item_scene.instantiate()
        item.label_text = txt
        menu_item_list.add_child(item)
        _menu_items[count] = item
        item.is_selected = count == 0
        count += 1

    max_idx = count-1


func _process(_delta: float) -> void:
    if not is_active: return
    if Input.is_action_just_pressed("up"):
        selected_idx = clamp(selected_idx-1, 0, max_idx)
    if Input.is_action_just_pressed("down"):
        selected_idx = clamp(selected_idx+1, 0, max_idx)
    if Input.is_action_just_pressed("jump"):
        var txt = _menu_items[selected_idx].label_text
        print(menu_items_dict[txt])
