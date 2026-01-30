extends CanvasLayer


@onready var box_texture: NinePatchRect = $BoxTexture
@onready var text_label: Label = $BoxTexture/MarginContainer/TextLabel

#@onready var animation_component: AnimationComponent = $BoxTexture/AnimationComponent

@export var y_pos_top:= 0.0
@export var y_pos_bottom:= 105.0
var start_y_pos
var is_showing:= false

func _ready() -> void:
    #animation_component.open()
    box_texture.show()
    start_y_pos = box_texture.position.y
    Events.show_dialogue.connect(on_show_dialogue)
    Events.hide_dialogue.connect(on_hide_dialogue)
    Events.go_to_level.connect(on_hide_dialogue)
    Events.room_entered.connect(handle_camera_move)


func handle_camera_move(room_pos:Vector2, _show_water:bool, _show_stars:bool):
    """ """
    if room_pos.y < 0: box_texture.position.y = y_pos_top
    else: box_texture.position.y = start_y_pos


func on_show_dialogue(text_to_show: String, _timer: float=2.0) -> void:
    is_showing = true
    box_texture.hide()
    text_label.text = text_to_show
    box_texture.show()


func on_hide_dialogue(_arg1:String="N/A", _arg2: String="N/A") -> void:
    text_label.text = ''
    box_texture.hide()
