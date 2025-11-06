extends Label

func _ready():
	update_keycard_display()
	Global.connect("keycards_changed", Callable(self, "_on_keycards_changed"))

func _on_keycards_changed(_new_value):
	modulate = Color(0.743, 0.036, 0.308, 1.0)  # tint yellow
	update_keycard_display()
	await get_tree().create_timer(0.15).timeout
	modulate = Color.WHITE

func update_keycard_display():
	text = "Keycards: %d / %d" % [Global.keycards_collected, Global.required_keycards]
