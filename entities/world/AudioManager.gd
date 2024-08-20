extends Node

@export var play_music_loop := true

@onready var music_loop: AudioStreamPlayer2D = $MusicLoop
@onready var audio_light_bug_collect: AudioStreamPlayer2D = $AudioLightBugCollect
@onready var audio_level_complete: AudioStreamPlayer2D = $AudioLevelComplete
@onready var audio_level_reset: AudioStreamPlayer2D = $AudioLevelReset
@onready var audio_level_purified: AudioStreamPlayer2D = $AudioLevelPurified
@onready var audio_statue_activated: AudioStreamPlayer2D = $AudioStatueActivated
@onready var audio_light_bug_spawn: AudioStreamPlayer2D = $AudioLightBugSpawn
@onready var audio_hit_hazard: AudioStreamPlayer2D = $AudioHitHazard
@onready var audio_player_respawn: AudioStreamPlayer2D = $AudioPlayerRespawn
@onready var audio_enter_unpurified: AudioStreamPlayer2D = $AudioEnterUnpurified
@onready var audio_enter_level_new: AudioStreamPlayer2D = $AudioEnterLevelNew
@onready var audio_go_to_next: AudioStreamPlayer2D = $AudioGoToNext
@onready var audio_go_to_prev: AudioStreamPlayer2D = $AudioGoToPrev


func _ready() -> void:
    Events.light_bug_spawn.connect(play_light_bug_spawn)
    Events.light_bug_collected.connect(play_light_bug_collect)
    Events.go_to_next_level.connect(play_goto_next)
    Events.go_to_prev_level.connect(play_goto_prev)
    Events.level_completed.connect(play_level_complete)
    Events.level_reset.connect(play_level_reset)
    Events.level_purified.connect(play_level_purified)
    Events.level_new.connect(play_leveL_new)
    Events.frog_statue_activating.connect(play_statue_activated)
    Events.player_hit_hazard.connect(play_hit_hazard)
    Events.player_respawn.connect(play_player_respawn)

    if play_music_loop:
        music_loop.play()


func play_light_bug_collect():
    audio_light_bug_collect.play()

func play_level_complete(_level_key: String, _on_start: bool):
    if _on_start:
        audio_enter_unpurified.play()
    else:
        audio_level_complete.play()

func play_level_purified(_level_key: String, _on_start: bool):
    if _on_start: return
    audio_level_purified.play()

func play_level_reset(_level_key: String, _on_start: bool):
    if _on_start: return
    audio_level_reset.play()

func play_leveL_new(_level_key: String, _on_start: bool):
    audio_enter_level_new.play()

func play_statue_activated():
    audio_statue_activated.play()

func play_light_bug_spawn():
    audio_light_bug_spawn.play()

func play_hit_hazard():
    audio_hit_hazard.play()

func play_player_respawn():
    audio_player_respawn.play()

func play_goto_next():
    audio_go_to_next.play()

func play_goto_prev():
    audio_go_to_prev.play()
