extends Node

signal level_reset(level_key: String)
signal level_completed(level_key: String)
signal level_purified(level_key: String)
signal light_bug_collected
signal dark_bug_collected

signal go_to_level(level_key: String)
signal go_to_next_level
signal go_to_prev_level

signal frog_statue_activated
