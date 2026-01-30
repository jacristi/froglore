extends Node2D

@export var this_level: String = "N/A"
@export var prev_level: String = "N/A"
@export var next_level: String = "N/A"

@onready var dialogue_sign: Area2D = $Environs/DialogueSign
@onready var end_credits: Control = %EndCredits

var level_state = LevelManager.level_states.STARTED

@onready var pause_canvas: CanvasLayer = $PauseCanvas
var is_paused := false


func _ready() -> void:
    pause_canvas.visible = true
    Events.frog_statue_activating.connect(handle_frog_statue_activating)
    Events.frog_statue_activated.connect(handle_frog_statue_activated)
    Events.try_go_to_next_level.connect(go_to_next_level)
    Events.try_go_to_prev_level.connect(go_to_prev_level)
    Events.ready_world_statue.connect(start_end_credits)
    Events.activated_world_statue.connect(start_end_credits)

    Events.cutscene_start.connect(cutscene_started)
    Events.cutscene_end.connect(cutscene_ended)

    LevelManager.current_level = this_level
    level_state = LevelManager.get_level_state(this_level)
    handle_on_start_level_state()


func handle_on_start_level_state():
    """ """
    # check if level is in game data level details
    if !GameData.level_details.has(this_level):
        GameData.level_details[this_level] = {}

    check_update_collectable_details(GameData.key_light_bug, "LightBug")
    check_update_collectable_details(GameData.key_portal_stone, "PortalStone")
    check_update_secrets_details()
    Events.should_save_game_data.emit()


func check_update_collectable_details(data_key: String, grp_name: String):
    if !GameData.level_details[this_level].has(data_key):
        GameData.level_details[this_level][data_key] = {}

    var collectables = get_tree().get_nodes_in_group(grp_name)
    for col: Collectable in collectables:
        if GameData.level_details[this_level][data_key].has(col.collectable_name): continue
        GameData.level_details[this_level][data_key][col.collectable_name] = false


func check_update_secrets_details() -> void:
    if !GameData.level_details[this_level].has(GameData.key_secret):
        GameData.level_details[this_level][GameData.key_secret] = {}

    var secrets = get_tree().get_nodes_in_group("SecretLayer")
    for sl: SecretsLayer in secrets:
        if GameData.level_details[this_level][GameData.key_secret].has(sl.secret_name): continue
        GameData.level_details[this_level][GameData.key_secret][sl.secret_name] = false

func go_to_next_level() -> void:
    if LevelManager.in_semi_pause_state: return
    if next_level == "N/A":
        Events.cannot_go_to_level.emit()
        return
    Events.go_to_next_level.emit()
    Events.go_to_level.emit(next_level, this_level)


func go_to_prev_level() -> void:
    if LevelManager.in_semi_pause_state: return
    if prev_level == "N/A":
        Events.cannot_go_to_level.emit()
        return

    Events.go_to_prev_level.emit()
    Events.go_to_level.emit(prev_level, this_level)


func handle_frog_statue_activating():
    """ """


func handle_frog_statue_activated():
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
