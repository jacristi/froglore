extends Node


@export var current_player_color: = 'frog'

var game_data_file_path = "res://_data/"
var game_data_file_name = "game_data.json"

var level_states: Dictionary[String, int]
var level_details = {
    "level_1":
        {
            "state": 0,
            "portal_stones_unlocked":  [0],
            "light_bugs_collected":     [],
            "statues_collected":        [],
            "secrets_uncovered":        [],
        }
}
var game_details = {
    "last_level_played": "level_name",
}
var game_settings = {
    "audio_master_level": 7,
    "audio_music_level": 7,
    "audio_sfx_level": 7,
}


func _ready():
    """ """
    load_game_data()
    #save_game_data()
    Events.collectable_collected.connect(handle_collectable_collected)
    #Events.portal_stone_unlocked.connect(handle_portal_stone_unlocked)
    Events.should_save_game.connect(save_game_data)


func check_curr_level_in_details() -> void:
    """ """
    var lvl = LevelManager.current_level
    if !level_details.has(lvl):
        level_details[lvl] = {
            "state": 1,
            "portal_stones_unlocked":  [],
            "light_bugs_collected":     [],
            "statues_collected":        [],
            "secrets_uncovered":        [],
            }


func handle_collectable_collected(c_type: String, c_name: String, quiet) -> void:
    """ """
    # If quiet, then its already been collected
    if quiet:
        print('collecting quiety')
        return

    var lvl = LevelManager.current_level
    check_curr_level_in_details()
    var c_key = ""

    match c_type:
        "light_bug":
            c_key = "light_bugs_collected"
        "portal_stone":
            c_key = "portal_stones_unlocked"
        "secret":
            c_key = "secrets_uncovered"

    if c_key == "": return

    if !level_details[lvl].has(c_key):
        level_details[lvl][c_key] = [c_name]
    elif level_details[lvl][c_key].has(c_name):
        return
    else:
        level_details[lvl][c_key].append(c_name)

    save_game_data()



func load_game_data() -> void:
    """ """
    var full_path = game_data_file_path + "/" + game_data_file_name
    var file = FileAccess.open(full_path, FileAccess.READ)
    print(game_data_file_path)
    if !FileAccess.file_exists(full_path):
        level_details = {}
        return

    var json = file.get_as_text()
    var json_object = JSON.new()

    json_object.parse(json)

    level_details = json_object.data["level_details"]
    game_settings = json_object.data["game_settings"]
    print('loaded game data from file')
    file.close()


func save_game_data() -> void:
    """ """
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

    var data = {
        "level_details": level_details,
        "game_settings": game_settings
        }

    var json_text = JSON.stringify(data, "\t")
    file.store_string(json_text)
    print("saving data to file '%s'" % full_path)
    file.close()
