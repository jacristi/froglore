extends Node

@export var should_save_load:= true
@export var current_player_color: = 'frog'

var game_data_file_path     = "res://_data/"
var game_data_file_name     = "game_data.json"
var game_settings_file_name = "game_settings.json"

# Game Data keys
var key_game_details    = "game_details"
var key_level_details   = "level_details"
var key_state           = "state"
var key_light_bug       = "light_bug"
var key_portal_stone    = "portal_stone"
var key_secret          = "secret"
var key_statue          = "statue"
var key_last_level      = "last_level_played"

# Game Settings Keys
var key_game_settings   = "game_settings"
var key_audio_master    = "audio_master_level"
var key_audio_music     = "audio_music_level"
var key_audio_sfx       = "audio_music_level"

var level_details = {}
var game_details = {}
var game_settings = {
    key_audio_master:   7,
    key_audio_music:    7,
    key_audio_sfx:      7,
}


func _ready():
    """ """
    load_data()
    Events.should_save_game_data.connect(save_game_data)
    Events.should_save_game_settings.connect(save_game_settings)
    Events.collectable_collected.connect(handle_collectable_collected)
    Events.secret_found.connect(handle_secret_found)


func check_curr_level_in_details() -> void:
    """ """
    var lvl = LevelManager.current_level
    if !level_details.has(lvl):
        level_details[lvl] = {
            key_state: 1,
            key_light_bug:      {},
            key_portal_stone:   {},
            key_statue:         {},
            key_secret:         {},
            }


func handle_secret_found(secret_name: String) -> void:
    """ """
    var lvl = LevelManager.current_level
    check_curr_level_in_details()

    if !level_details[lvl].has(key_secret):
        level_details[lvl][key_secret] = {secret_name: true}
    else:
        level_details[lvl][key_secret][secret_name] = true

    save_data()


func handle_collectable_collected(c_type: String, c_name: String, quiet) -> void:
    """ """
    # If quiet, then its already been collected
    if quiet: return

    var lvl = LevelManager.current_level
    check_curr_level_in_details()
    var c_key = ""

    match c_type:
        "light_bug":    c_key = key_light_bug
        "portal_stone": c_key = key_portal_stone

    if c_key == "": return

    if !level_details[lvl].has(c_key):
        level_details[lvl][c_key] = {c_name: true}
    else:
        level_details[lvl][c_key][c_name] = true

    save_data()


func load_game_data() -> void:
    """ """
    if !should_save_load: return

    var full_path = game_data_file_path + "/" + game_data_file_name
    var file = FileAccess.open(full_path, FileAccess.READ)

    if !FileAccess.file_exists(full_path):
        level_details = {}
        return

    var json = file.get_as_text()
    var json_object = JSON.new()

    json_object.parse(json)

    level_details = json_object.data[key_level_details]
    game_details  = json_object.data[key_game_details]
    print('loaded level details from file')

    file.close()


func load_game_settings() -> void:
    """ """
    var full_path = game_data_file_path + "/" + game_settings_file_name
    var file = FileAccess.open(full_path, FileAccess.READ)

    if !FileAccess.file_exists(full_path):
        return

    var json = file.get_as_text()
    var json_object = JSON.new()

    json_object.parse(json)

    game_settings = json_object.data[key_game_settings]
    print('loaded game settings from file')
    file.close()


func save_game_data() -> void:
    """ """
    if !should_save_load: return
    # Check if the save dir exists, create if not
    var dir = DirAccess.open(game_data_file_path)
    if !dir:
        DirAccess.make_dir_absolute(game_data_file_path)

    # Open/Create save file
    var full_path = game_data_file_path + "/" + game_data_file_name
    var file = FileAccess.open(full_path, FileAccess.WRITE)

    if !file:
        print("Unable to save data to file")
        return

    # Save new last level played as long as its a level scene
    if LevelManager.current_level != "title_scene":
        game_details[key_last_level] = LevelManager.current_level

    var data = {
        key_level_details: level_details,
        key_game_details:  game_details,
        }


    var json_text = JSON.stringify(data, "\t")
    file.store_string(json_text)
    print("saving data to file '%s'" % full_path)
    file.close()


func save_game_settings() -> void:
    """ """
    # Check if the save dir exists, create if not
    var dir = DirAccess.open(game_data_file_path)
    if !dir:
        DirAccess.make_dir_absolute(game_data_file_path)

    # Open/Create save file
    var full_path = game_data_file_path + "/" + game_settings_file_name
    var file = FileAccess.open(full_path, FileAccess.WRITE)

    if !file:
        print("Unable to save data to file")
        return

    var data = {
        key_game_settings: game_settings,
        }

    var json_text = JSON.stringify(data, "\t")
    file.store_string(json_text)
    print("saving data to file '%s'" % full_path)
    file.close()


func save_data() -> void:
    """ """
    save_game_settings()
    save_game_data()


func load_data() -> void:
    """ """
    load_game_settings()
    load_game_data()
