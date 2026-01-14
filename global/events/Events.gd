extends Node

signal level_reset(level_key: String, on_start: bool)
signal level_completed(level_key: String, on_start: bool)
signal level_purified(level_key: String, on_start: bool)
signal level_new(level_key: String, on_start: bool)
signal level_purified_start
signal level_purified_done

signal collectable_collected(
    collectable_type: String,
    collectable_name: String,
    quiet: bool
    )
signal light_bug_collected
signal dark_bug_collected
signal light_bug_spawn
signal dark_bug_spawn

signal player_hit_hazard
signal player_has_respawned
signal player_hopped
signal player_hop_landed
signal player_croaked(color)
signal player_should_despawn
signal player_should_respawn
signal player_super_hop_prep()
signal player_change_color(color: String)
signal player_teleport

signal go_to_level(level_key: String)
signal try_go_to_next_level
signal try_go_to_prev_level
signal go_to_next_level
signal go_to_prev_level
signal cannot_go_to_level

signal try_exit_game

signal frog_statue_activating
signal frog_statue_activated

signal ready_world_statue
signal activating_world_statue
signal activated_world_statue

signal butterfly_statue_activated(color: String)
signal butterfly_statue_deactivated(color: String)

signal portal_stone_unlocked(stone_number: int, stone_pos: Vector2)

signal ui_play_button_clicked
signal ui_exit_button_clicked

signal camera_change_scroll_vals(scroll_left: int, scroll_right: int, y_offset: int)

signal should_show_dialogue
signal show_dialogue(text_to_show: String, timer: float)
signal hide_dialogue

signal pause_pressed

signal cutscene_start
signal cutscene_end

signal secret_found

signal grass_rustled

signal should_save_game
signal level_loaded(level_name: String)

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("pause"):
        pause_pressed.emit()
