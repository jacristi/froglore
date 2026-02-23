class_name ability
extends Collectable




func check_save_data(_lvl: String) -> void:
    """ """
    if !GameData.game_details.has(GameData.key_ability): return

    var c_name = collectable_name
    if GameData.game_details[GameData.key_ability].has(c_name):
        if GameData.game_details[GameData.key_ability][c_name]:
            collect_quietly()
