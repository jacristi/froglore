class_name AnimationComponent extends Node

@export var target: Control
@export var from_center : bool = true
@export var scale_dur : float = 0.1
@export var scale_to : Vector2 = Vector2(0, 0)
@export var transition_type : Tween.TransitionType

var default_scale : Vector2
var default_offset : Vector2


func _ready() -> void:
    setup()
    target.scale = Vector2(0, 0)


func setup() -> void:
    default_offset = target.pivot_offset
    default_scale = target.scale


func open():
    if from_center:
        target.pivot_offset = target.size / 2.0

    add_tween("scale", default_scale, scale_dur)


func close():
    add_tween("scale", scale_to, scale_dur)


func add_tween(property: String, value, seconds: float) -> void:
    var tween = get_tree().create_tween()
    tween.tween_property(target, property, value, seconds).set_trans(transition_type)
