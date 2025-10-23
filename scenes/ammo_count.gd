extends Label
func _ready() ->void:
	Events.ammo_updated.connect(_on_events_ammo_updated)
func _on_events_ammo_updated(ammo_size: int, ammo_count: int) -> void:
	text = str(ammo_size) + "/" + str(ammo_count)
