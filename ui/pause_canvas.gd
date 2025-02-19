extends CanvasLayer

var is_paused := false
@onready var pause_texture: NinePatchRect = $PauseTexture
@onready var resume_button: Button = %ResumeButton
@onready var animation_component: AnimationComponent = $PauseTexture/AnimationComponent


func _ready() -> void:
    Events.pause_pressed.connect(show_hide_pause_menu)
    pause_texture.hide()
    animation_component.close()


func show_hide_pause_menu():
    if is_paused:
        animation_component.close()
        get_tree().paused = false
        await get_tree().create_timer(.15).timeout
        pause_texture.hide()
    else:
        pause_texture.show()
        animation_component.open()
        await get_tree().create_timer(.15).timeout
        get_tree().paused = true
        resume_button.grab_focus()

    is_paused = !is_paused


func _on_resume_button_pressed() -> void:
    animation_component.close()
    get_tree().paused = false
    is_paused = false
    await get_tree().create_timer(.15).timeout
    pause_texture.hide()


func _on_exit_button_pressed() -> void:
    Events.try_exit_game.emit()
