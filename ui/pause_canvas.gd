extends CanvasLayer

var is_paused := false
@onready var pause_texture: NinePatchRect = $PauseTexture
@onready var animation_component: AnimationComponent = $PauseTexture/AnimationComponent
@onready var resume_button: Button = %ResumeButton
@onready var controls_texture: NinePatchRect = $ControlsTexture
@onready var controls_animation_component: AnimationComponent = $ControlsTexture/ControlsAnimationComponent


func _ready() -> void:
    Events.pause_pressed.connect(show_hide_pause_menu)
    pause_texture.hide()
    animation_component.close()
    controls_texture.hide()
    controls_animation_component.close()


func show_hide_pause_menu():
    if is_paused:
        animation_component.close()
        controls_animation_component.close()
        get_tree().paused = false

        await get_tree().create_timer(.15).timeout
        pause_texture.hide()
        controls_texture.hide()
    else:
        resume_button.grab_focus()
        pause_texture.show()
        animation_component.open()
        #controls_texture.show()
        controls_animation_component.open()
        await get_tree().create_timer(.15).timeout
        get_tree().paused = true


    is_paused = !is_paused


func _on_resume_button_pressed() -> void:
    animation_component.close()
    controls_animation_component.close()
    get_tree().paused = false
    is_paused = false
    await get_tree().create_timer(.15).timeout
    pause_texture.hide()
    controls_texture.hide()


func _on_exit_button_pressed() -> void:
    Events.try_exit_game.emit()


func _on_controls_button_pressed() -> void:
    if controls_texture.visible:
        controls_animation_component.close()
        controls_texture.hide()
    else:
        controls_texture.show()
        controls_animation_component.open()
