extends CanvasLayer


@onready var box_texture: NinePatchRect = $BoxTexture
@onready var text_label: Label = $BoxTexture/TextLabel


var is_showing:= false

func _ready() -> void:
    box_texture.hide()
    Events.show_dialogue.connect(on_show_dialogue)
    Events.hide_dialogue.connect(on_hide_dialogue)
    Events.go_to_level.connect(on_hide_dialogue)


func on_show_dialogue(text_to_show: String, timer: float=2.0) -> void:
    if is_showing: return
    is_showing = true
    text_label.text = text_to_show
    box_texture.show()

    if timer > 0:
        await get_tree().create_timer(timer).timeout
        box_texture.hide()
        is_showing = false


func on_hide_dialogue(_arg:String="N/A") -> void:
    box_texture.hide()
    is_showing = false
