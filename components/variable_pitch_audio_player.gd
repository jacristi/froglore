class_name VariablePitchAudioPlayer
extends AudioStreamPlayer



@export var pitch_min = 0.6
@export var pitch_max = 1.4
@export var auto_play_with_variance: = false

var curr_pitch

func _ready() -> void:
    curr_pitch = pitch_min
    if auto_play_with_variance:
        play_with_variance(0.0)


func play_with_variance(from_position: float = 0.0) -> void:
    pitch_scale = randf_range(pitch_min, pitch_max)
    play(from_position)


func play_with_increasing_pitch(from_position: float = 0.0) -> void:
    pitch_scale = curr_pitch
    if curr_pitch+.1 > pitch_max:
        curr_pitch = pitch_min
    else:
        curr_pitch += .1

    play(from_position)


func play_with_specific_pitch(pitch_val: float, from_position: float = 0.0) -> void:
    pitch_scale = pitch_val
    play(from_position)
