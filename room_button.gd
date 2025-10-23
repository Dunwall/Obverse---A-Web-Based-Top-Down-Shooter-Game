extends Button

@export var room: PackedScene

func _ready() -> void:
	pressed.connect(_on_pressed)
	if room:
		var inst = room.instantiate()
		if inst and inst.has_meta("room_name"):
			text = inst.room_name
			print("button ready",text)
		else:
			text = "Unnamed Room"
		inst.queue_free()
	else:
		text = "No room assigned"
func _on_pressed() -> void:
	if room:
		get_tree().change_scene_to_packed(room)
