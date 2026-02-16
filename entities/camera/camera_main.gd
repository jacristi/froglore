extends Camera2D

@export var camera_move_value = 100.0
@export var offset_x := 5.0
@export var offset_y := 0.0

var player
var _base_y_pos

func _ready():
    player = get_tree().get_nodes_in_group("Player")[0]
    _base_y_pos = position.y
    Events.room_entered.connect(adjust_for_new_room)


func _process(delta: float) -> void:
    var pos_x = offset_x if player.face_direction > 0 else -offset_x

    position.x = move_toward(
        pos_x,
        player.position.x,
        delta*camera_move_value
        )
    position.y =_base_y_pos + offset_y


func adjust_for_new_room(
    room_pos: Vector2,
    room_size: Vector2,
    _show_water:bool,
    _show_stars:bool
    ) -> void:
    """ """

    # calc limits based on room pos + room size
    var x = room_pos.x - (room_size.x/2.0)
    var y = room_pos.y - (room_size.y/2.0)

    limit_left   = int(x)
    limit_right  = int(x + room_size.x)
    limit_top    = int(y)
    limit_bottom = int(y + room_size.y)
    get_viewport().set_content_scale_size(room_size)
    #print("room_pos:     " + str(room_pos))
    #print("room_size:    " + str(room_size))
    #print("limit_left:   " + str(limit_left))
    #print("limit_right:  " + str(limit_right))
    #print("limit_top:    " + str(limit_top))
    #print("limit_bottom: " + str(limit_bottom))


#func change_scroll_limit(
        #_left_val:int,
        #_right_val:int,
        #_y_offset:int,
        #_show_water:bool,
        #_show_stars:bool):
    #""" """
    #pass
    #limit_left = left_val
    #limit_right = right_val
    #offset_y = y_offset
