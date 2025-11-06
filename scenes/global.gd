extends Node

signal keycards_changed(new_value: int)

var keycards_collected: int = 0
var required_keycards: int = 3  # or however many you need

func add_keycard():
	keycards_collected += 1
	emit_signal("keycards_changed", keycards_collected)
