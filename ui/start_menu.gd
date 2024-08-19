extends CenterContainer

@onready var play_button: Button = %PlayButton


func _ready() -> void:
    RenderingServer.set_default_clear_color(Color.CADET_BLUE)
    play_button.grab_focus()


func _on_play_pressed() -> void:
    await LevelTransition.fade_to_black()
    get_tree().change_scene_to_file("res://entities/world/levels/level_1.tscn")
    await LevelTransition.fade_from_black()


func _on_exit_pressed() -> void:
    get_tree().quit()

