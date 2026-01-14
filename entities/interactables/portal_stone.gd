class_name PortalStone
extends Collectable

var stone_number: int

func _ready() -> void:
    super()
    stone_number = int(collectable_name)


func collect() -> void:
    super()
    Events.portal_stone_unlocked.emit(stone_number, position)

func collect_quietly() -> void:
    super()
    Events.portal_stone_unlocked.emit(stone_number, position)
