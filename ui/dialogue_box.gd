extends CanvasLayer


@onready var box_texture: NinePatchRect = $BoxTexture
@onready var text_label: Label = $BoxTexture/TextLabel
@onready var animation_component: AnimationComponent = $BoxTexture/AnimationComponent


var is_showing:= false

func _ready() -> void:
    animation_component.close()
    Events.show_dialogue.connect(on_show_dialogue)
    Events.hide_dialogue.connect(on_hide_dialogue)
    Events.go_to_level.connect(on_hide_dialogue)


func on_show_dialogue(text_to_show: String, timer: float=2.0) -> void:
    if is_showing: return
    is_showing = true
    text_label.text = text_to_show
    animation_component.open()

    if timer > 0:
        await get_tree().create_timer(timer).timeout
        animation_component.close()
        is_showing = false


func on_hide_dialogue(_arg:String="N/A") -> void:
    animation_component.close()
    is_showing = false
