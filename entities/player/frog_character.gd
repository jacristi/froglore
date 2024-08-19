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

var current_interactable: Area2D

var face_direction := 0
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

enum states {IDLE, HOP_START, FALLING, HOP_LAND, HIT_HAZARD, RESPAWNING, CROAKING}
var state = states.IDLE

var is_idle := true
var is_falling := false
var prep_jump := false


func _ready() -> void:
    hazard_detector.area_entered.connect(hit_hazard)
    interact_detector.area_entered.connect(enter_interactable)
    interact_detector.area_exited.connect(exit_interactable)
    Events.level_completed.connect(hide_light_point)


func _physics_process(delta: float) -> void:
    prep_jump = false
    if velocity.x != 0:
        face_direction = int(velocity.x)
        animated_sprite_2d.flip_h = (velocity.x < 0)

    if not is_on_floor():
        velocity.y += gravity * delta

    var direction := Input.get_axis("move_left", "move_right")

    if (Input.is_action_just_pressed("up")):
        if (current_interactable != null and current_interactable.is_in_group("exit_point")):
            Events.go_to_next_level.emit()

    if (Input.is_action_just_pressed("down")):
        if (current_interactable != null and current_interactable.is_in_group("exit_point")):
            Events.go_to_prev_level.emit()

    if (Input.is_action_just_pressed("action") and has_control() and state != states.CROAKING):
        croak()

    if (Input.is_action_pressed("jump") and can_hop() and is_on_floor()):
        hop(delta, 1.5)
    elif direction and can_hop() and is_on_floor():
        hop(delta)

    if direction and (can_hop() or !is_on_floor()):
        velocity.x = direction * move_speed
    else:
        velocity.x = move_toward(velocity.x, 0, move_speed)

    if not velocity.is_zero_approx():
        move_and_slide()

    if _has_fall_velocity() and state != states.HOP_LAND:
        animated_sprite_2d.play("hop_fall")
        state = states.FALLING

    if is_on_floor() and state == states.FALLING:
        state = states.HOP_LAND
        hop_landed()

    if _is_hopping() and state != states.HOP_START:
        state = states.HOP_START
        animated_sprite_2d.play("hop_start")

    if _is_idle() and state != states.IDLE:
        state = states.IDLE
        animated_sprite_2d.play("idle")


func hop(_delta: float, hop_mod: float = 1.0) -> void:
    velocity.y = -hop_height * hop_mod


func hop_landed() -> void:
    move_hop_timer.wait_time = hop_cooldown
    move_hop_timer.start()
    animated_sprite_2d.play("hop_land")
    await animated_sprite_2d.animation_finished
    animated_sprite_2d.play("idle")


func hit_hazard(_area: Area2D):
    state = states.HIT_HAZARD
    animated_sprite_2d.play("hit_hazard")
    await animated_sprite_2d.animation_finished
    state = states.RESPAWNING
    global_position = starting_position
    animated_sprite_2d.play("respawn")
    await animated_sprite_2d.animation_finished
    state = states.IDLE
    animated_sprite_2d.play("idle")


func enter_interactable(area: Area2D):
    current_interactable = area


func exit_interactable(_area: Area2D):
    current_interactable = null


func croak() -> void:
    state = states.CROAKING
    # interact with object if exists
    animated_sprite_2d.play("croak")
    await animated_sprite_2d.animation_finished
    state = states.IDLE
    animated_sprite_2d.play("idle")


func hide_light_point(_level_key: String):
    point_light_2d.enabled = false

func has_control() -> bool: return state != states.HIT_HAZARD and state != states.RESPAWNING and state != states.CROAKING
func can_hop() -> bool: return move_hop_timer.time_left <= 0 and is_on_floor() and has_control()
func _is_hopping() -> bool: return velocity.y < 0
func _has_fall_velocity() -> bool: return velocity.y > 0
func _is_falling() -> bool: return _has_fall_velocity() and not is_on_floor()
func _is_idle() -> bool: return velocity.x == 0 and is_on_floor() and has_control()
