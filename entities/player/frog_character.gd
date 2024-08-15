extends CharacterBody2D

@export var move_speed := 50.0
@export var hop_height := 125.0
@export var hop_cooldown := 1.5

@onready var move_hop_timer: Timer = $MoveHopTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hazard_detector: Area2D = $HazardDetector
@onready var starting_position := global_position
@onready var point_light_2d: PointLight2D = $PointLight2D

var face_direction := 0
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

enum states {IDLE, HOP_START, FALLING, HOP_LAND}
var state = states.IDLE

var is_idle := true
var is_falling := false


func _ready() -> void:
    hazard_detector.area_entered.connect(hit_hazard)
    Events.level_completed.connect(hide_light_point)


func _physics_process(delta: float) -> void:

    if velocity.x != 0:
        face_direction = velocity.x
        animated_sprite_2d.flip_h = (velocity.x < 0)

    if not is_on_floor():
        velocity.y += gravity * delta

    var direction := Input.get_axis("move_left", "move_right")

    if direction and can_hop() and is_on_floor():
        hop(delta)

    if direction and (can_hop() or !is_on_floor()):
        velocity.x = direction * move_speed
    else:
        velocity.x = move_toward(velocity.x, 0, move_speed)

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


func hop(delta: float) -> void:
    velocity.y = -hop_height


func hop_landed() -> void:
    move_hop_timer.wait_time = hop_cooldown
    move_hop_timer.start()
    animated_sprite_2d.play("hop_land")
    await animated_sprite_2d.animation_finished
    animated_sprite_2d.play("idle")


func hit_hazard(area: Area2D):
    global_position = starting_position


func hide_light_point():
    point_light_2d.enabled = false

func can_hop() -> bool: return move_hop_timer.time_left <= 0 and is_on_floor()
func _is_hopping() -> bool: return velocity.y < 0
func _has_fall_velocity() -> bool: return velocity.y > 0
func _is_falling() -> bool: return _has_fall_velocity() and not is_on_floor()
func _is_idle() -> bool: return velocity.x == 0 and is_on_floor()
