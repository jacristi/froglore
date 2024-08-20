extends Node

signal level_reset(level_key: String, on_start: bool)
signal level_completed(level_key: String, on_start: bool)
signal level_purified(level_key: String, on_start: bool)
signal level_new(level_key: String, on_start: bool)

signal light_bug_collected
signal dark_bug_collected
signal light_bug_spawn
signal dark_bug_spawn

signal player_hit_hazard
signal player_respawn

signal go_to_level(level_key: String)
signal go_to_next_level
signal go_to_prev_level

signal frog_statue_activating
signal frog_statue_activated
