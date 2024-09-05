extends CharacterBody2D

@export var move_speed := 55.0
@export var hop_height := 120.0
@export var hop_cooldown := .35
@export var dash_velocity_x = 200.0
@export var dash_velocity_y = 10.0
@export var dash_duration = 0.1
@export var dash_cooldown_duration := 1.0
@export var wall_cling_cooldown := 0.3

@onready var move_hop_timer: Timer = $MoveHopTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hazard_detector: Area2D = $HazardDetector
@onready var interact_detector: Area2D = $InteractDetector
@onready var starting_position := global_position
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var wall_cling_timer: Timer = $WallClingTimer
@onready var hop_land_effect: CPUParticles2D = $HopLandEffect

var current_interactable: Area2D

var h_direction: float
var v_direction: float
var face_direction := 1
var dash_direction := 1
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var has_big_fall_velocity:= false

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

var curr_velocity: Vector2


func _ready() -> void:
	hazard_detector.area_entered.connect(hit_hazard)
	interact_detector.area_entered.connect(enter_interactable)
	interact_detector.area_exited.connect(exit_interactable)
	Events.level_completed.connect(on_level_complete)
	Events.level_purified.connect(on_level_purified)
	Events.level_reset.connect(on_level_reset)
	dash_cooldown_timer.wait_time = dash_cooldown_duration


func _physics_process(delta: float) -> void:
	prep_jump = false
	handle_face_direction()
	handle_move_directions()
	apply_gravity(delta)

	handle_interacts_with_up_down()

	handle_croaking()
	handle_dashing()
	handle_hopping(delta)
	handle_h_movement()
	handle_wall_cling()

	if not velocity.is_zero_approx():
		move_and_slide()

	handle_states_animations()


func hop(_delta: float, hop_mod: float = 1.0) -> void:
	velocity.y = -hop_height * hop_mod
	Events.player_hopped.emit()


func hop_landed() -> void:
	move_hop_timer.wait_time = hop_cooldown
	move_hop_timer.start()
	dash_used = false
	if has_big_fall_velocity:
		hop_land_effect.emitting = true
	if not has_control(): return
	if state == states.HIT_HAZARD: return
	animated_sprite_2d.play("hop_land")
	Events.player_hop_landed.emit()
	await animated_sprite_2d.animation_finished
	animated_sprite_2d.play("idle")


func handle_hopping(delta):
	if (Input.is_action_pressed("jump") and can_hop() and is_on_floor()):
		hop(delta, 1.5)
		return

	if (Input.is_action_just_pressed("jump") and can_hop() and _is_wall_clinging()):
		hop(delta, 1.5)
		wall_cling_timer.wait_time = wall_cling_cooldown
		wall_cling_timer.start()
		return

	if h_direction and can_hop() and is_on_floor():
		hop(delta)
		return


func handle_h_movement():
	if h_direction and (can_hop() or !is_on_floor()) and state != states.DASHING:
		velocity.x = h_direction * move_speed
	elif state != states.DASHING:
		velocity.x = move_toward(velocity.x, 0, move_speed)


func handle_face_direction():
	if velocity.x != 0:
		face_direction = -1 if velocity.x < 0 else 1
		animated_sprite_2d.flip_h = (velocity.x < 0)


func handle_move_directions():
	h_direction = Input.get_axis("move_left", "move_right")
	v_direction = Input.get_axis("down", "up")


func apply_gravity(delta):
	if is_on_floor(): return
	if _is_dashing(): return
	if _is_wall_clinging(): return

	velocity.y += gravity * delta


func hit_hazard(_area: Area2D):
	Events.player_hit_hazard.emit()
	state = states.HIT_HAZARD
	animated_sprite_2d.play("despawn")
	velocity.x = 0
	velocity.y = 0
	await animated_sprite_2d.animation_finished
	state = states.RESPAWNING
	global_position = starting_position
	animated_sprite_2d.play("respawn")
	Events.player_respawn.emit()
	await animated_sprite_2d.animation_finished
	if state == states.RESPAWNING:
		state = states.IDLE
		animated_sprite_2d.play("idle")


func enter_interactable(area: Area2D):
	current_interactable = area


func exit_interactable(_area: Area2D):
	current_interactable = null


func croak() -> void:
	if _is_wall_clinging():
		state = states.WALL_CLING_CROAKING
		animated_sprite_2d.play("wall_cling_croak")
	else:
		state = states.CROAKING
		animated_sprite_2d.play("croak")
	Events.player_croaked.emit()


	await animated_sprite_2d.animation_finished

	if can_try_activate_interactable():
		current_interactable.try_activate()

	if current_interactable and current_interactable.is_in_group("LevelExit"):
		if LevelManager.get_level_state(LevelManager.current_level) == LevelManager.level_states.PURIFIED \
			and LevelManager.current_level != "level_0" \
			and LevelManager.current_level != "title_scene":
			Events.go_to_level.emit("level_0")

	if state == states.CROAKING:
		state = states.IDLE
		animated_sprite_2d.play("idle")
	if state == states.WALL_CLING_CROAKING:
		state = states.WALL_CLINGING
		animated_sprite_2d.play("wall_cling")


func handle_croaking():
	if (Input.is_action_just_pressed("action") and can_croak()):
		croak()


func dash():
	dash_used = true
	dash_direction = face_direction
	if _is_wall_clinging():
		dash_direction = -dash_direction
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


func on_level_complete(_level_key: String, _on_start: bool):
	pass


func on_level_purified(_level_key: String, _on_start: bool):
	pass


func on_level_reset(_level_key: String, _on_start: bool):
	pass


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

	if _is_dashing():
		velocity.x = dash_velocity_x * dash_direction
		velocity.y = move_toward(velocity.y, -dash_velocity_y, 0)

	if state == states.IDLE:
		dash_used = false

	if state == states.WALL_CLINGING and has_control():
		animated_sprite_2d.play("wall_cling")
		velocity.y = 0

	if state == states.WALL_CLING_CROAKING and has_control():
		velocity.y = 0

	curr_velocity = velocity


func handle_wall_cling():
	if state != states.WALL_CLINGING and not v_direction: return

	if not _can_cling_to_wall() and state == states.WALL_CLINGING:
		state = states.FALLING
		return

	if not _can_cling_to_wall(): return
	if not has_control(): return

	state = states.WALL_CLINGING


func can_dash() -> bool: return has_control() and dash_used == false and dash_cooldown_timer.time_left <= .01
func can_croak() -> bool: return state == states.IDLE or _is_wall_clinging()
func has_control() -> bool: return state != states.HIT_HAZARD and state != states.RESPAWNING and state != states.CROAKING and state != states.DASHING
func can_hop() -> bool: return move_hop_timer.time_left <= 0 and has_control() and (is_on_floor() or _is_wall_clinging())
func _is_croaking() -> bool: return state == states.CROAKING or state == states.WALL_CLING_CROAKING
func _is_hopping() -> bool: return velocity.y < 0 and state != states.DASHING
func _has_fall_velocity() -> bool: return velocity.y > 0
func _is_falling() -> bool: return _has_fall_velocity() and not is_on_floor()
func _is_idle() -> bool: return velocity.x == 0 and is_on_floor() and has_control()
func _is_dashing() -> bool: return state == states.DASHING # and check conditions that break dash (is_on_floor, is on wall)e.g.
func _is_wall_clinging() -> bool: return state == states.WALL_CLINGING or state == states.WALL_CLING_CROAKING

func _can_cling_to_wall() ->  bool: return is_on_wall() and wall_cling_timer.time_left <= 0.0

func can_try_activate_interactable() -> bool: return current_interactable != null and ( \
current_interactable.is_in_group("FrogStatues") \
or current_interactable.is_in_group("WarpStatues") \
or current_interactable.is_in_group("WorldStatues") \
or current_interactable.is_in_group("InteractableEnviron") \
)
