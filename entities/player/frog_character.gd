class_name PlayerCharacter
extends CharacterBody2D

@export var move_speed := 55.0
@export var hop_height := 120.0
@export var hop_cooldown := .35
@export var dash_velocity_x = 192.0
@export var dash_velocity_y = 10.0
@export var dash_duration = 0.1
@export var dash_cooldown_duration := 1.0
@export var wall_cling_cooldown := 0.3
@export var big_hop_buffer_time := 0.075

@onready var move_hop_timer: Timer = $MoveHopTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hazard_detector: Area2D = $HazardDetector
@onready var interact_detector: Area2D = $InteractDetector
@onready var dialogue_detector: Area2D = $DialogueDetector
@onready var collectable_detector: Area2D = $CollectableDetector
@onready var starting_position := global_position
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var wall_cling_timer: Timer = $WallClingTimer
@onready var big_hop_buffer_timer: Timer = $BigHopBufferTimer

@onready var hop_land_effect: CPUParticles2D = $HopLandEffect
@onready var flash_sprite_component: FlashSpriteComponent = $FlashSpriteComponent
@onready var scale_sprite_component: ScaleSpriteComponent = $ScaleSpriteComponent

@onready var dash_unlocked:= true
@onready var wall_cling_unlocked:= true
@onready var super_hop_unlocked:= true

var portal_stones_unlocked = {}

var current_color : String = "frog"
var current_interactable: Area2D
var current_dialogue: Area2D

var h_direction: float
var v_direction: float
var face_direction := 1
var dash_direction := 1
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var has_big_fall_velocity:= false
var can_big_hop:= false
var has_buffered_big_hop:= false

var respawn_position: Vector2

enum states {
    IDLE,
    HOP_START,
    FALLING,
    HOP_LAND,
    HIT_HAZARD,
    RESPAWNING,
    CROAKING,
    DASHING,
    WALL_CLINGING,
    WALL_CLING_CROAKING
    }
var state = states.IDLE

var is_idle := true
var is_falling := false
var prep_jump := false
var is_climbing := false
var dash_used:= false
var wall_cling_used_count:= 0
var wall_cling_used_max:= 1

var curr_velocity: Vector2
var button_down_held_time: float = 0
var idle_timer: float = 0

var super_hop_prep_reached := false

var _is_paused:= false

func _ready() -> void:
    hazard_detector.area_entered.connect(hit_hazard_despawn_and_respawn)
    hazard_detector.body_entered.connect(hit_hazard_despawn_and_respawn_body)
    interact_detector.area_entered.connect(enter_interactable)
    interact_detector.area_exited.connect(exit_interactable)
    dialogue_detector.area_entered.connect(enter_dialogue)
    dialogue_detector.area_exited.connect(exit_dialogue)
    collectable_detector.area_entered.connect(enter_collectable)
    dash_cooldown_timer.wait_time = dash_cooldown_duration
    big_hop_buffer_timer.wait_time = big_hop_buffer_time
    big_hop_buffer_timer.timeout.connect(func(): can_big_hop = false)
    Events.player_should_despawn.connect(despawn_player)
    Events.player_should_respawn.connect(respawn_player)
    Events.level_purified_start.connect(pause_unpause_player_actions.bind(true))
    Events.level_purified_done.connect(pause_unpause_player_actions.bind(false))
    Events.frog_statue_activated.connect(func():
        if current_interactable != null: enter_interactable(current_interactable))
    Events.portal_stone_unlocked.connect(func(stone_num:int, stone_pos:Vector2):
        portal_stones_unlocked[stone_num] = stone_pos)

    current_color = GameData.current_player_color


func _physics_process(delta: float) -> void:
    prep_jump = false
    handle_face_direction()
    handle_move_directions()
    apply_gravity(delta)

    handle_interacts_with_up_down()
    handle_buttons_held()

    handle_croaking()
    handle_dashing()
    handle_hopping(delta)
    handle_h_movement()
    handle_wall_cling()
    handle_swtich_pressed()

    if not velocity.is_zero_approx():
        move_and_slide()

    handle_states_animations()

    get_wall_direction()


func get_wall_direction() -> int:
    if is_on_wall() and get_slide_collision_count() > 0:
        for i in range (0,get_slide_collision_count()):
            var norm = get_slide_collision(i).get_normal()
            if norm.x != 0: return norm.x
    return 0


func pause_unpause_player_actions(should_pause: bool) -> void:
    _is_paused = should_pause


func hop(_delta: float, hop_mod: float = 1.0) -> void:
    velocity.y = -hop_height * hop_mod
    Events.player_hopped.emit()
    if has_buffered_big_hop: return
    can_big_hop = true
    big_hop_buffer_timer.start()


func hop_landed() -> void:
    move_hop_timer.wait_time = hop_cooldown
    move_hop_timer.start()
    dash_used = false
    has_buffered_big_hop = false
    wall_cling_used_count = 0

    if has_big_fall_velocity:
        hop_land_effect.emitting = true

    if not has_control(): return
    animated_sprite_2d.play("hop_land")
    Events.player_hop_landed.emit()
    await animated_sprite_2d.animation_finished

    if not has_control(): return
    animated_sprite_2d.play("idle")


func handle_hopping(delta):
    if not has_control(): return

    # use is pressed so the input can be held down
    if Input.is_action_pressed("jump"):
        if (can_hop() and is_on_floor()) or (can_big_hop and !has_buffered_big_hop):

            # Reset dash cooldown for big hops (feels bad otherwise)
            dash_cooldown_timer.stop()
            can_big_hop = false
            has_buffered_big_hop = true
            big_hop_buffer_timer.stop()

            if super_hop_prep_reached:
                hop(delta, 1.5 * 2 * .8)
            else:
                hop(delta, 1.5)
            return

        # use just pressed so it requires a fresh jump input
        elif Input.is_action_just_pressed("jump") and can_hop() and _is_wall_clinging():
            hop(delta, 1.5)
            wall_cling_used_count += 1
            wall_cling_timer.wait_time = wall_cling_cooldown
            wall_cling_timer.start()
            return

    if h_direction and can_hop() and is_on_floor():
        var amt = 1.5 if super_hop_prep_reached else 1.0
        hop(delta, amt)
        return


func handle_h_movement():
    if not has_control(): return

    if h_direction and (can_hop() or !is_on_floor()) and state != states.DASHING and not _is_wall_clinging():
        velocity.x = h_direction * move_speed
    elif state != states.DASHING:
        velocity.x = move_toward(velocity.x, 0, move_speed)


func handle_face_direction():
    if velocity.x != 0:
        face_direction = -1 if velocity.x < 0 else 1
        animated_sprite_2d.flip_h = (velocity.x < 0)

    if Input.is_action_just_pressed("up") and _can_turn_face():
        face_direction = -face_direction
        animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h


func handle_move_directions():
    h_direction = Input.get_axis("move_left", "move_right")
    v_direction = Input.get_axis("down", "up")


func _input(event: InputEvent) -> void:
    # Track most recent input types
    if event is InputEventJoypadButton: GlobalData.input_type = 'controller'
    if event is InputEventKey: GlobalData.input_type = 'keyboard'


func apply_gravity(delta):
    if is_on_floor(): return
    if _is_dashing(): return
    if _is_wall_clinging(): return
    if _is_hazard_respawning(): return

    velocity.y += gravity * delta


func hit_hazard_despawn_and_respawn_body(_body) -> void:
    hit_hazard_despawn_and_respawn(null)


func hit_hazard_despawn_and_respawn(_area: Area2D):
    Events.player_hit_hazard.emit()
    state = states.HIT_HAZARD
    despawn_player(true)
    await animated_sprite_2d.animation_finished
    respawn_player()


func hit_hazard_despawn():
    Events.player_hit_hazard.emit()
    state = states.HIT_HAZARD
    animated_sprite_2d.play("despawn")
    velocity.x = 0
    velocity.y = 0


func teleport_player(teleport_to_pos: Vector2):
    """ """
    state = states.HIT_HAZARD
    Events.player_teleport.emit()
    despawn_player(false)
    await animated_sprite_2d.animation_finished
    position = teleport_to_pos
    await get_tree().create_timer(.01).timeout
    state = states.RESPAWNING
    animated_sprite_2d.play("respawn")
    Events.player_has_respawned.emit()
    await animated_sprite_2d.animation_finished

    if state == states.RESPAWNING:
        state = states.IDLE
        animated_sprite_2d.play("idle")


func despawn_player(hit_hazard:bool=true):
    state = states.HIT_HAZARD
    if hit_hazard:
        animated_sprite_2d.play("hit_hazard")
    else:
        animated_sprite_2d.play("despawn")
    velocity.x = 0
    velocity.y = 0


func respawn_player():
    state = states.RESPAWNING
    global_position = respawn_position
    animated_sprite_2d.play("respawn")
    Events.player_has_respawned.emit()
    await animated_sprite_2d.animation_finished

    if state == states.RESPAWNING:
        state = states.IDLE
        animated_sprite_2d.play("idle")


func enter_interactable(area: Area2D):
    current_interactable = area
    if area.is_in_group("FrogStatues"):
        Events.show_dialogue.emit(area.dialogue_text, 0)
    if area.is_in_group("WarpStatues"):
        Events.show_dialogue.emit(area.dialogue_text, 0)
    if area.is_in_group("WorldStatues"):
        Events.show_dialogue.emit(area.dialogue_text, 0)
    if area.is_in_group("InteractableEnviron"):
        pass
    if area.is_in_group("ButterflyStatues"):
        Events.show_dialogue.emit(area.dialogue_text, 0)
    if area.is_in_group("LevelExit"):
        Events.show_dialogue.emit(area.dialogue_text, 0)
    if area.is_in_group("RespawnPoint"):
        respawn_position = area.position
    if area.is_in_group("PortalStone"):
        respawn_position = area.position


func exit_interactable(_area: Area2D):
    current_interactable = null
    Events.hide_dialogue.emit()


func enter_dialogue(area: Area2D):
    current_dialogue = area


func exit_dialogue(_area: Area2D):
    current_dialogue = null


func enter_collectable(coll: Collectable) -> void:
    """ """
    coll.collect()


func croak() -> void:
    if _is_wall_clinging():
        state = states.WALL_CLING_CROAKING
        animated_sprite_2d.play("wall_cling_croak")
    else:
        state = states.CROAKING
        animated_sprite_2d.play("croak")
    Events.player_croaked.emit(current_color)

    await animated_sprite_2d.animation_finished

    if can_try_activate_interactable():
        current_interactable.try_activate()


    if state == states.CROAKING:
        state = states.IDLE
        animated_sprite_2d.play("idle")

    if state == states.WALL_CLING_CROAKING:
        state = states.WALL_CLINGING
        animated_sprite_2d.play("wall_cling")


func change_frog_color():
    var curr_idx = 0
    var ls = GlobalData.frog_paletes_keys

    for i in ls.size():
       if ls[i] == current_color:
            curr_idx = i
            break

    var next_idx = curr_idx + 1
    if next_idx >= ls.size():
        next_idx = 0

    current_color = ls[next_idx]
    var p_array = GlobalData.frog_palettes_dict[current_color]
    animated_sprite_2d.material.set_shader_parameter("replace_color_1", p_array[0])
    animated_sprite_2d.material.set_shader_parameter("replace_color_2", p_array[1])
    animated_sprite_2d.material.set_shader_parameter("replace_color_3", p_array[2])
    Events.player_change_color.emit(current_color)
    GameData.current_player_color = current_color


func handle_swtich_pressed():
    if Input.is_action_just_pressed("switch"):
        change_frog_color()


func handle_croaking():
    if (Input.is_action_just_pressed("action") and can_croak()):
        croak()


func dash():
    dash_used = true
    dash_direction = face_direction
    if _is_wall_clinging():
        dash_direction = -dash_direction
        wall_cling_used_count += 1
    state = states.DASHING
    velocity.x = dash_velocity_x * dash_direction
    velocity.y = -dash_velocity_y
    animated_sprite_2d.play("dash")
    await get_tree().create_timer(dash_duration).timeout
    dash_cooldown_timer.start()
    if state == states.DASHING:
        state = states.FALLING


func handle_dashing():
    if (Input.is_action_just_pressed("dash") and can_dash()):
        dash()


func get_next_portal_stone(current_number: int):
    var numbers = portal_stones_unlocked.keys()
    numbers.sort()
    var next_number = current_number

    # Try to assign next number to the no right after current
    for i in numbers:
        if i <= current_number:
            continue
        if i > current_number:
            next_number = i
            break
    # If a new number was not assigned, assign to the first in the list (wrap-around)
    if next_number == current_number:
        next_number = numbers[0]
    return next_number

func handle_interacts_with_up_down():
    if state != states.IDLE: return

    if (Input.is_action_just_pressed("up")):
        if (current_interactable != null and current_interactable.is_in_group("LevelExit")):
            Events.try_go_to_next_level.emit()

    if (Input.is_action_just_pressed("down")):
        if (current_interactable != null and current_interactable.is_in_group("LevelExit")):
            Events.try_go_to_prev_level.emit()

    if (Input.is_action_just_pressed("up")):
        if (current_interactable != null and current_interactable.is_in_group("GameExit")):
            Events.try_exit_game.emit()

    if (Input.is_action_just_pressed("up")):
        if (current_interactable != null and current_interactable.is_in_group("PortalStone")) and len(portal_stones_unlocked) > 1:
            var curr = (current_interactable as PortalStone).stone_number
            var next = get_next_portal_stone(curr)
            var teleport_pos = portal_stones_unlocked[next]

            teleport_player(teleport_pos)


func handle_buttons_held():
    if v_direction < 0 and can_prep_big_jump():
        button_down_held_time += .005
    elif state != states.IDLE or v_direction >= 0 and !super_hop_prep_reached:
        button_down_held_time = 0
        super_hop_prep_reached = false
        flash_sprite_component.stop_flash_continuous_intervals()

    if button_down_held_time >= .36 && not super_hop_prep_reached:
        super_hop_prep_reached = true
        await get_tree().create_timer(.025).timeout
        super_hop_prep()
        flash_sprite_component.start_flash_continuous_intervals(1)


func super_hop_prep():
    Events.player_super_hop_prep.emit()
    flash_sprite_component.flash()
    scale_sprite_component.tween_scale()


func handle_states_animations():

    if _has_fall_velocity() and state != states.HOP_LAND and has_control() and not _is_wall_clinging():
        if state != states.FALLING:
            animated_sprite_2d.play("hop_fall")
        state = states.FALLING
        has_big_fall_velocity = true if velocity.y > 150 else false

    if is_on_floor() and state == states.FALLING and has_control():
        state = states.HOP_LAND
        hop_landed()

    if _is_hopping() and state != states.HOP_START and state != states.DASHING and not _is_wall_clinging() and has_control():
        state = states.HOP_START
        animated_sprite_2d.play("hop_start")

    if _is_idle() and state != states.IDLE and has_control():
        state = states.IDLE
        animated_sprite_2d.play("idle")

    if state == states.IDLE and button_down_held_time > 0.1:
        animated_sprite_2d.play("prep_super_hop")
    elif state == states.IDLE and button_down_held_time <= 0 and idle_timer > 8.0:
        animated_sprite_2d.play("idle_sleep")
    elif state == states.IDLE and button_down_held_time <= 0:
        animated_sprite_2d.play("idle")

    if _is_dashing():
        velocity.x = dash_velocity_x * dash_direction
        velocity.y = move_toward(velocity.y, -dash_velocity_y, 0)

    if state == states.IDLE:
        dash_used = false
        wall_cling_used_count = 0
        idle_timer += .01

        if current_dialogue != null:
            Events.should_show_dialogue.emit()
    else:
        idle_timer = 0



    if state == states.WALL_CLINGING and has_control():
        animated_sprite_2d.play("wall_cling")
        velocity.y = 0

    if state == states.WALL_CLING_CROAKING and has_control():
        velocity.y = 0

    curr_velocity = velocity


func handle_wall_cling():
    if state != states.WALL_CLINGING and v_direction <= 0: return

    if not _can_cling_to_wall() and state == states.WALL_CLINGING:
        state = states.FALLING
        return

    if not _can_cling_to_wall(): return
    if not has_control(): return

    state = states.WALL_CLINGING


func can_dash() -> bool: return has_control() and dash_used == false and dash_cooldown_timer.time_left <= .01 and dash_unlocked
func can_croak() -> bool: return state == states.IDLE or _is_wall_clinging()
func has_control() -> bool: return !_is_hazard_respawning() and state != states.CROAKING and state != states.DASHING and !_is_paused
func can_hop() -> bool: return move_hop_timer.time_left <= 0 and has_control() and (is_on_floor() or _is_wall_clinging())
func _is_croaking() -> bool: return state == states.CROAKING or state == states.WALL_CLING_CROAKING
func _is_hopping() -> bool: return velocity.y < 0 and state != states.DASHING
func _has_fall_velocity() -> bool: return velocity.y > 0
func _is_falling() -> bool: return _has_fall_velocity() and not is_on_floor()
func _is_idle() -> bool: return velocity.x == 0 and is_on_floor() and has_control()
func _is_dashing() -> bool: return state == states.DASHING # and check conditions that break dash (is_on_floor, is on wall)e.g.
func _is_wall_clinging() -> bool: return state == states.WALL_CLINGING or state == states.WALL_CLING_CROAKING
func _is_hazard_respawning() -> bool: return state == states.HIT_HAZARD or state == states.RESPAWNING
func _can_turn_face() -> bool: return (
    state == states.IDLE and current_interactable == null
    and (
        current_interactable == null
        or (
            !current_interactable.is_in_group("LevelExit")
            or !current_interactable.is_in_group("PortalStone")
        )
        )
    )
func _can_cling_to_wall() ->  bool: return (
    is_on_wall()
    and wall_cling_timer.time_left <= 0.0
    and wall_cling_unlocked
    and wall_cling_used_count < wall_cling_used_max
    and get_wall_direction() == -face_direction
    )
func can_prep_big_jump() -> bool: return state == states.IDLE and super_hop_unlocked
func can_try_activate_interactable() -> bool: return current_interactable != null and ( \
current_interactable.is_in_group("FrogStatues") \
or current_interactable.is_in_group("WarpStatues") \
or current_interactable.is_in_group("WorldStatues") \
or current_interactable.is_in_group("InteractableEnviron") \
or current_interactable.is_in_group("ButterflyStatues")
)
