extends Node2D

@export var curr_level: String = "N/A"
@export var prev_level: String = "N/A"
@export var next_level: String = "N/A"

@export_multiline var dialogue_new: String = "N/A"
@export_multiline var dialogue_completed: String = "N/A"
@export_multiline var dialogue_purified: String = "N/A"

@onready var dialogue_sign: Area2D = $Environs/DialogueSign
@onready var end_credits: Control = %EndCredits

var level_state = LevelManager.level_states.STARTED

@onready var pause_canvas: CanvasLayer = $PauseCanvas
var is_paused := false


func _ready() -> void:
    pause_canvas.visible = true
    Events.level_completed.connect(handle_level_completed)
    Events.level_purified.connect(handle_leveL_purified)
    Events.level_reset.connect(handle_level_reset)
    Events.light_bug_collected.connect(handle_light_bug_collected)
    Events.dark_bug_collected.connect(handle_dark_bug_collected)
    Events.frog_statue_activating.connect(handle_frog_statue_activating)
    Events.frog_statue_activated.connect(handle_frog_statue_activated)
    Events.try_go_to_next_level.connect(go_to_next_level)
    Events.try_go_to_prev_level.connect(go_to_prev_level)
    Events.ready_world_statue.connect(start_end_credits)
    Events.activated_world_statue.connect(start_end_credits)

    Events.cutscene_start.connect(cutscene_started)
    Events.cutscene_end.connect(cutscene_ended)

    LevelManager.current_level = curr_level
    level_state = LevelManager.get_level_state(curr_level)
    handle_on_start_level_state()



func handle_on_start_level_state():
    """ """


func respawn_light_bugs():
    """ """


func respawn_dark_bugs():
    """ """


func handle_level_completed(_level_key: String, _on_start: bool, _respawn_wait_time: float=5) -> void:
    """ """


func handle_leveL_purified(_level_key: String, _on_start: bool) -> void:
    """ """


func go_to_next_level() -> void:
    if LevelManager.in_semi_pause_state: return
    if next_level == "N/A":
        Events.cannot_go_to_level.emit()
        return
    Events.go_to_next_level.emit()
    Events.go_to_level.emit(next_level, curr_level)


func go_to_prev_level() -> void:
    if LevelManager.in_semi_pause_state: return
    if prev_level == "N/A":
        Events.cannot_go_to_level.emit()
        return

    Events.go_to_prev_level.emit()
    Events.go_to_level.emit(prev_level, curr_level)


func handle_light_bug_collected():
    """ """


func handle_dark_bug_collected():
    """ """


func handle_frog_statue_activating():
    """ """


func handle_frog_statue_activated():
    """ """


func handle_level_reset(_level_key: String, _on_start:bool):
    """ """


func cutscene_started():
    """ """
    LevelManager.in_semi_pause_state = true


func cutscene_ended():
    """ """
    LevelManager.in_semi_pause_state = false
    end_credits.hide()


func start_end_credits():
    end_credits.show()
    end_credits.show_credits()
