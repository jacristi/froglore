class_name Menu
extends MarginContainer

var is_active = true:
    set(value):
        if is_active == value: return
        is_active = value

var _menu_items: Dictionary[int, MenuItem]
@onready var menu_item_list: VBoxContainer = %MenuItemList
@onready var header: Label = %Header
@onready var menu_border: NinePatchRect = %MenuBorder

var max_idx:= 1
var selected_idx:= 0:
    set(value):
        if selected_idx == value: return
        selected_idx = value
        for k in _menu_items.keys():
            _menu_items[k].is_selected = k == selected_idx

var menu_item_scene = load("res://ui/menus/menu_item.tscn")

@export var show_background:= true
@export var header_text: String = "Header"
@export var menu_item_labels: Array[String]
@export var menu_item_signals: Array[String]


func _ready() -> void:
    """ """
    if !show_background: menu_border.hide()
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

    max_idx = count - 1


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

    if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed('ui_accept'):
        var sig = menu_item_signals[selected_idx]

        if not sig or 'disable' in sig.to_lower():
            Events.ui_error.emit()
        else:
            Events.ui_select.emit()
            on_item_selected(sig)


func on_item_selected(signal_name: String):
    match signal_name:
        'play_game':                start_play_game()
        'open_settings':            open_settings_menu()
        'open_credits':             open_credits_menu()
        'exit_game':                start_exit_game()
        'open_gameplay_settings':   open_gameplay_settings()
        'open_video_settings':      open_video_settings()
        'open_audio_settings':      open_audio_settings()
        'open_controls_settings':   open_controls_settings()
        'return_to_title':          return_to_title()


func start_play_game() -> void:
    print('play_game')

func start_exit_game() -> void:
    Events.try_exit_game.emit()

func open_settings_menu() -> void:
    print('open_settings')

func open_credits_menu() -> void:
    print('open_credits')

func open_gameplay_settings() -> void:
    print('open_gameplay_settings')

func open_video_settings() -> void:
    print('open_video_settings')

func open_audio_settings() -> void:
    print('open_audio_settings')

func open_controls_settings() -> void:
    print('open_controls_settings')

func return_to_title() -> void:
    print('return_to_title')
