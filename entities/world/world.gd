extends Node2D

@export var next_level: PackedScene

@onready var ui_level_complete: ColorRect = $CanvasLayer/LevelComplete

var main_light: DirectionalLight2D
var initial_light_energy: float

var bugs_total: int
var bugs_collected: int

var light_incr_amt: float

var is_level_completed:= false


func _process(delta: float) -> void:
    if is_level_completed and Input.is_action_just_pressed("ui_accept") and !Input.is_action_pressed("jump"):
        go_to_next_level()


func _ready() -> void:
    Events.level_completed.connect(show_level_completed)
    Events.bug_collected.connect(handle_bug_collected)
    main_light = get_tree().get_nodes_in_group("MainLight")[0]
    initial_light_energy = main_light.energy

    bugs_total = get_tree().get_nodes_in_group("Bugs").size()
    light_incr_amt = initial_light_energy / bugs_total


func show_level_completed() -> void:
    ui_level_complete.show()
    is_level_completed = true


func go_to_next_level() -> void:
    if not next_level is PackedScene: return

    get_tree().paused = true
    await get_tree().create_timer(1.0).timeout
    await LevelTransition.fade_to_black()
    get_tree().paused = false
    get_tree().change_scene_to_packed(next_level)
    await LevelTransition.fade_from_black()


func handle_bug_collected():
    print("BUG COLLECTED!")
    bugs_collected += 1
    main_light.energy -= light_incr_amt*.4

    if bugs_collected == bugs_total:
        Events.level_completed.emit()
        main_light.energy = 0
        await get_tree().create_timer(.5).timeout
        show_level_completed()



