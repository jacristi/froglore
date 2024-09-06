extends CanvasLayer

var is_paused := false
@onready var pause_texture: NinePatchRect = $PauseTexture
@onready var resume_button: Button = %ResumeButton


func _ready() -> void:
    Events.pause_pressed.connect(show_hide_pause_menu)
    pause_texture.hide()



func show_hide_pause_menu():
    if is_paused:
        pause_texture.hide()
        get_tree().paused = false
    else:
        pause_texture.show()
        get_tree().paused = true
        resume_button.grab_focus()

    is_paused = !is_paused


func _on_resume_button_pressed() -> void:
    pause_texture.hide()
    get_tree().paused = false
    is_paused = false


func _on_exit_button_pressed() -> void:
    Events.try_exit_game.emit()
