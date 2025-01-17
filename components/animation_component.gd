class_name AnimationComponent extends Node

@export var target: Control
@export var from_center : bool = true
@export var scale_amount : Vector2 = Vector2(1, 1)
@export var scale_dur : float = 0.1
@export var transition_type : Tween.TransitionType

var default_scale : Vector2


func _ready() -> void:
    setup()


func setup() -> void:
    if from_center:
        target.pivot_offset = target.size / 2.0
    default_scale = Vector2(0,0)


func open():
    add_tween("scale", scale_amount, scale_dur)


func close():
    add_tween("scale", default_scale, scale_dur)


func add_tween(property: String, value, seconds: float) -> void:
    var tween = get_tree().create_tween()
    tween.tween_property(target, property, value, seconds).set_trans(transition_type)
