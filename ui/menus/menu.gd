class_name Menu
extends MarginContainer

var is_active = true:
    set(value):
        if is_active == value: return
        is_active = value

var _menu_items: Dictionary[int, MenuItem]
@onready var menu_item_list: VBoxContainer = %MenuItemList
@onready var header: Label = %Header

var max_idx:= 1
var selected_idx:= 0:
    set(value):
        if selected_idx == value: return
        selected_idx = value
        for k in _menu_items.keys():
            _menu_items[k].is_selected = k == selected_idx

var menu_item_scene = load("res://ui/menus/menu_item.tscn")

@export var header_text: String = "Header"
@export var menu_item_labels: Array[String]
@export var menu_item_signals: Array[String]

func _ready() -> void:
    """ """
    header.text = header_text
    var count = 0
    for txt: String in menu_item_labels:
        var sig: String = menu_item_signals[count]
        var item: MenuItem = menu_item_scene.instantiate()
        item.label_text = txt
        menu_item_list.add_child(item)
        _menu_items[count] = item
        item.is_selected = count == 0
        item.is_enabled = (sig != '' and 'disable' not in sig.to_lower())
        count += 1

    max_idx = count-1


func _process(_delta: float) -> void:
    if not is_active: return
    if Input.is_action_just_pressed("up"):
        if selected_idx - 1 < 0:
            Events.ui_error.emit()
        else:
            selected_idx -= 1
            Events.ui_nav_up.emit()

    if Input.is_action_just_pressed("down"):
        if selected_idx + 1 > max_idx:
            Events.ui_error.emit()
        else:
            selected_idx += 1
            Events.ui_nav_down.emit()

    if Input.is_action_just_pressed("jump"):
        var txt = menu_item_labels[selected_idx]
        var sig = menu_item_signals[selected_idx]
        print(txt + ': ' + sig)
        if not sig or 'disable' in sig.to_lower():
            Events.ui_error.emit()
        else:
            Events.ui_select.emit()
