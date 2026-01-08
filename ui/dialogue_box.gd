extends CanvasLayer


@onready var box_texture: NinePatchRect = $BoxTexture
@onready var text_label: Label = $BoxTexture/MarginContainer/TextLabel

#@onready var animation_component: AnimationComponent = $BoxTexture/AnimationComponent

@export var y_pos_top:= 0.0
@export var y_pos_bottom:= 105.0

var is_showing:= false

func _ready() -> void:
    #animation_component.open()
    box_texture.show()
    Events.show_dialogue.connect(on_show_dialogue)
    Events.hide_dialogue.connect(on_hide_dialogue)
    Events.go_to_level.connect(on_hide_dialogue)
    Events.camera_change_scroll_vals.connect(func(_scroll_left_val, _scroll_right_val, y_offset):
        if y_offset < 0: box_texture.position.y = y_pos_top
        else: box_texture.position.y = y_pos_bottom
        )


func on_show_dialogue(text_to_show: String, _timer: float=2.0) -> void:
    is_showing = true
    box_texture.hide()
    text_label.text = text_to_show
    box_texture.show()


func on_hide_dialogue(_arg:String="N/A") -> void:
    text_label.text = ''
    box_texture.hide()
