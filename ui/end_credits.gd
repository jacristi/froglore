extends Control

@onready var title: Label = $Title
@onready var credits: Label = $Credits
@onready var thank_you: Label = $ThankYou
@onready var still_more: Label = $StillMore


func show_credits():
    if LevelManager.has_finished_all_purified:
        still_more.text = "Nice job! You've done everything (for now)!"

    Events.cutscene_start.emit()
    await get_tree().create_timer(.5).timeout
    title.show()
    await get_tree().create_timer(1.5).timeout
    credits.show()
    await get_tree().create_timer(2.5).timeout
    thank_you.show()
    await get_tree().create_timer(1.0).timeout
    still_more.show()

    await get_tree().create_timer(8.0).timeout
    title.hide()
    credits.hide()
    thank_you.hide()
    still_more.hide()
    Events.cutscene_end.emit()
