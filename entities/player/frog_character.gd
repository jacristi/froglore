extends CharacterBody2D

@export var move_speed := 50.0
@export var hop_height := 125.0
@export var hop_cooldown := 1.5

@onready var move_hop_timer: Timer = $MoveHopTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hazard_detector: Area2D = $HazardDetector
@onready var interact_detector: Area2D = $InteractDetector
@onready var starting_position := global_position
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer

var current_interactable: Area2D

var face_direction := 1
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

enum states {IDLE, HOP_START, FALLING, HOP_LAND, HIT_HAZARD, RESPAWNING, CROAKING, DASHING}
var state = states.IDLE

var is_idle := true
var is_falling := false
var prep_jump := false

var dash_used:= false
@export var dash_velocity_x: float
@export var dash_velocity_y: float
@export var dash_duration: float
@export var dash_cooldown_duration:= 1.0
var curr_velocity: Vector2

func _ready() -> void:
    hazard_detector.area_entered.connect(hit_hazard)
    Events.dark_bug_collected.connect(collected_dark_bug)
    interact_detector.area_entered.connect(enter_interactable)
    interact_detector.area_exited.connect(exit_interactable)
    Events.level_completed.connect(hide_light_point)
    Events.level_purified.connect(hide_light_point)
    Events.level_reset.connect(show_light_point)
    dash_cooldown_timer.wait_time = dash_cooldown_duration


func _physics_process(delta: float) -> void:
    prep_jump = false
    if velocity.x != 0:
        face_direction = -1 if velocity.x < 0 else 1
        animated_sprite_2d.flip_h = (velocity.x < 0)

    if not is_on_floor() and not _is_dashing():
        velocity.y += gravity * delta

    var direction := Input.get_axis("move_left", "move_right")

    if (Input.is_action_just_pressed("up")):
        if (current_interactable != null and current_interactable.is_in_group("LevelExit")):
            Events.try_go_to_next_level.emit()

    if (Input.is_action_just_pressed("down")):
        if (current_interactable != null and current_interactable.is_in_group("LevelExit")):
            Events.try_go_to_prev_level.emit()

    if (Input.is_action_just_pressed("action") and can_croak()):
        croak()

    if (Input.is_action_just_pressed("dash") and can_dash()):
        dash()

    if (Input.is_action_pressed("jump") and can_hop() and is_on_floor()):
        hop(delta, 1.5)
    elif direction and can_hop() and is_on_floor():
        hop(delta)

    if direction and (can_hop() or !is_on_floor()) and state != states.DASHING:
        velocity.x = direction * move_speed
    elif state != states.DASHING:
        velocity.x = move_toward(velocity.x, 0, move_speed)

    if not velocity.is_zero_approx():
        move_and_slide()

    if _has_fall_velocity() and state != states.HOP_LAND and has_control():
        animated_sprite_2d.play("hop_fall")
        state = states.FALLING

    if is_on_floor() and state == states.FALLING:
        state = states.HOP_LAND
        hop_landed()

    if _is_hopping() and state != states.HOP_START and state != states.DASHING:
        state = states.HOP_START
        animated_sprite_2d.play("hop_start")

    if _is_idle() and state != states.IDLE and has_control():
        state = states.IDLE
        animated_sprite_2d.play("idle")

    if _is_dashing():
        velocity.x = dash_velocity_x * face_direction
        velocity.y = move_toward(velocity.y, -dash_velocity_y, 0)

    if state == states.IDLE:
        dash_used = false

    curr_velocity = velocity

func hop(_delta: float, hop_mod: float = 1.0) -> void:
    velocity.y = -hop_height * hop_mod
    Events.player_hopped.emit()

func hop_landed() -> void:
    move_hop_timer.wait_time = hop_cooldown
    move_hop_timer.start()
    dash_used = false
    if not has_control(): return
    if state == states.HIT_HAZARD: return
    animated_sprite_2d.play("hop_land")
    Events.player_hop_landed.emit()
    await animated_sprite_2d.animation_finished
    animated_sprite_2d.play("idle")


func hit_hazard(_area: Area2D):
    Events.player_hit_hazard.emit()
    state = states.HIT_HAZARD
    animated_sprite_2d.play("hit_hazard")
    await animated_sprite_2d.animation_finished
    state = states.RESPAWNING
    global_position = starting_position
    animated_sprite_2d.play("respawn")
    Events.player_respawn.emit()
    await animated_sprite_2d.animation_finished
    if state == states.RESPAWNING:
        state = states.IDLE
        animated_sprite_2d.play("idle")


func collected_dark_bug():
    show_light_point("", false)


func enter_interactable(area: Area2D):
    current_interactable = area


func exit_interactable(_area: Area2D):
    current_interactable = null


func croak() -> void:
    state = states.CROAKING
    Events.player_croaked.emit()

    animated_sprite_2d.play("croak")
    await animated_sprite_2d.animation_finished

    if current_interactable and current_interactable.is_in_group("FrogStatues"):
        current_interactable.try_activate()

    if current_interactable and current_interactable.is_in_group("WarpStatues"):
        current_interactable.try_activate()

    if current_interactable and current_interactable.is_in_group("LevelExit"):
        if LevelManager.get_level_state(LevelManager.current_level) == LevelManager.level_states.PURIFIED and LevelManager.current_level != "level_0":
            Events.go_to_level.emit("level_0")

    if state == states.CROAKING:
        state = states.IDLE
        animated_sprite_2d.play("idle")


func dash():
    dash_used = true
    state = states.DASHING
    velocity.x = dash_velocity_x * face_direction
    velocity.y = -dash_velocity_y
    animated_sprite_2d.play("dash")
    await get_tree().create_timer(dash_duration).timeout
    dash_cooldown_timer.start()
    if state == states.DASHING:
        state = states.FALLING


func hide_light_point(_level_key: String, _on_start: bool):
    point_light_2d.enabled = false


func show_light_point(_level_key: String, _on_start: bool):
    #await get_tree().create_timer(1.0).timeout
    point_light_2d.enabled = true


func can_dash() -> bool: return has_control() and dash_used == false and dash_cooldown_timer.time_left <= .01
func can_croak() -> bool: return state == states.IDLE
func has_control() -> bool: return state != states.HIT_HAZARD and state != states.RESPAWNING and state != states.CROAKING and state != states.DASHING
func can_hop() -> bool: return move_hop_timer.time_left <= 0 and is_on_floor() and has_control()
func _is_hopping() -> bool: return velocity.y < 0 and state != states.DASHING
func _has_fall_velocity() -> bool: return velocity.y > 0
func _is_falling() -> bool: return _has_fall_velocity() and not is_on_floor()
func _is_idle() -> bool: return velocity.x == 0 and is_on_floor() and has_control()
func _is_dashing() -> bool: return state == states.DASHING and true # check conditions that break dash (is_on_floor, is on wall)e.g.
