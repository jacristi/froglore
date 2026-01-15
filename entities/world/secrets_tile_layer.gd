extends TileMapLayer

@export var secret_name:= ""
@export var reveal_area: Area2D

var is_revealed:= false:
    set(value):
        is_revealed = value
        if is_revealed:
            hide()


func _ready() -> void:
    assert(secret_name != "")
    Events.level_loaded.connect(check_save_data)
    reveal_area.body_entered.connect(_on_reveal_body_entered)


func _on_reveal_body_entered(_body: Node2D) -> void:
    """ """
    if is_revealed: return

    is_revealed = true
    Events.secret_found.emit(secret_name)


func check_save_data(lvl: String) -> void:
    """ """
    var s_key = "secrets_found"

    if !GameData.level_details.has(lvl): return
    if !GameData.level_details[lvl].has(s_key): return

    if GameData.level_details[lvl][s_key].has(secret_name):
        is_revealed = true
