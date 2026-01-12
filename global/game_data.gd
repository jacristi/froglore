extends Node


@export var current_player_color: = 'frog'

var game_data_file_path = "res://_data/"
var game_data_file_name = "game_data.json"

var level_states: Dictionary[String, int]
var level_details = {
    "level_name":
        {
            "state": 0,
            "portal_stones_collected":  [1],
            "light_bugs_collected":     ["bug_1", "bug_2"],
            "statues_collected":        ["statues_1"],
            "secrets_uncovered":        ["secret_1", "secret_2"],
        }
}

var game_settings = {
    "audio_master_level": 7,
    "audio_music_level": 7,
    "audio_sfx_level": 7,
}


func _ready():
    """ """
    #load_game_data()
    save_game_data()
    Events.should_save_game.connect(save_game_data)


func load_game_data() -> void:
    """ """
    var file = FileAccess.open(game_data_file_path, FileAccess.READ)

    if !FileAccess.file_exists(game_data_file_path):
        level_details = {}
        return

    var json = file.get_as_text()
    var json_object = JSON.new()

    json_object.parse(json)

    #print(json_object.data)
    print(json_object.data["level_details"])
    level_details = json_object.data["level_details"]
    game_settings = json_object.data["game_settings"]
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
