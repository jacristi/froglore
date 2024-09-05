extends Node

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
@onready var audio_hop: AudioStreamPlayer2D = $AudioHop
@onready var audio_hop_landed: AudioStreamPlayer2D = $AudioHopLanded
@onready var audio_croak: AudioStreamPlayer2D = $AudioCroak
@onready var audio_play_button_clicked: AudioStreamPlayer2D = $AudioPlayButtonClicked
@onready var audio_exit_button_clicked: AudioStreamPlayer2D = $AudioExitButtonClicked

var level_new_has_played:= false
var level_unpurified_has_played:= false


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
    Events.player_hopped.connect(play_hop)
    Events.player_hop_landed.connect(play_hop_landed)
    Events.player_croaked.connect(play_croak)
    Events.ui_play_button_clicked.connect(play_play_button_clicked)
    Events.ui_exit_button_clicked.connect(play_exit_button_clicked)


func play_light_bug_collect():
    audio_light_bug_collect.play()

func play_level_complete(_level_key: String, _on_start: bool):

    if _on_start:
        if level_unpurified_has_played: return
        level_unpurified_has_played = true
        if audio_enter_unpurified.playing: return
        audio_enter_unpurified.play()

    else:
        if audio_level_complete.playing: return
        audio_level_complete.play()

func play_level_purified(_level_key: String, _on_start: bool):
    if _on_start: return
    if audio_level_purified.playing: return
    audio_level_purified.play()

func play_level_reset(_level_key: String, _on_start: bool):
    if audio_level_reset.playing: return
    if _on_start: return
    audio_level_reset.play()

func play_leveL_new(_level_key: String, _on_start: bool):
    if level_new_has_played: return
    level_new_has_played = true
    audio_enter_level_new.play()

func play_statue_activated():
    audio_statue_activated.play()

func play_light_bug_spawn():
    if audio_light_bug_spawn.playing: return
    audio_light_bug_spawn.play()

func play_hit_hazard():
    if audio_hit_hazard.playing: return
    audio_hit_hazard.play()

func play_player_respawn():
    if audio_player_respawn.playing: return
    audio_player_respawn.play()

func play_goto_next():
    if audio_go_to_next.playing: return
    audio_go_to_next.play()

func play_goto_prev():
    if audio_go_to_prev.playing: return
    audio_go_to_prev.play()

func play_hop():
    if audio_hop.playing: return
    audio_hop.play()

func play_hop_landed():
    if audio_hop_landed.playing: return
    audio_hop_landed.play()

func play_croak():
    audio_croak.play()

func play_play_button_clicked():
    if audio_play_button_clicked.playing: return
    audio_play_button_clicked.play()

func play_exit_button_clicked():
    if audio_exit_button_clicked.playing: return
    audio_exit_button_clicked.play()
