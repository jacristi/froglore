extends CenterContainer

@onready var play_button: Button = %PlayButton

var play_pressed:= false

func _ready() -> void:
    RenderingServer.set_default_clear_color(Color.CADET_BLUE)
    play_button.grab_focus()


func _on_play_pressed() -> void:
    if play_pressed: return
    play_pressed = true

    Events.ui_play_button_clicked.emit()
    await LevelTransition.fade_to_black()
    get_tree().change_scene_to_file("res://entities/world/levels/level_1.tscn")
    await LevelTransition.fade_from_black()


func _on_exit_pressed() -> void:
    Events.ui_exit_button_clicked.emit()
    Events.try_exit_game.emit()

