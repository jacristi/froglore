extends Camera2D

@export var camera_move_value = 100.0
@export var offset_x := 5.0
@export var offset_y := 0.0

var player
var _base_y_pos

func _ready():
    player = get_tree().get_nodes_in_group("Player")[0]
    Events.camera_change_scroll_vals.connect(change_scroll_limit)
    _base_y_pos = position.y


func _process(delta: float) -> void:
    var pos_x = offset_x if player.face_direction > 0 else -offset_x

    position.x = move_toward(
        pos_x,
        player.position.x,
        delta*camera_move_value
        )
    position.y =_base_y_pos + offset_y


func change_scroll_limit(left_val:int, right_val:int, y_offset:int):
    limit_left = left_val
    limit_right = right_val
    offset_y = y_offset
