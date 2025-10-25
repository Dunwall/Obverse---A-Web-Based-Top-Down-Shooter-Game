extends Control
@onready var audio_player = $AudioStreamPlayer2D  # Path to your AudioStreamPlayer2D node
@onready var volume_slider = $MarginContainer/VBoxContainer/Volume       # Path 

var is_dragging = false

func _ready():
	volume_slider.connect("value_changed", Callable(self, "_on_volume_value_changed"))
	volume_slider.connect("gui_input", Callable(self, "_on_volume_gui_input"))
	
func _on_volume_value_changed(value: float) -> void:
	# Set bus volume quietly on change
	AudioServer.set_bus_volume_db(0, value)

func _on_volume_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
			else:
				if is_dragging:
					# Left mouse button released - play sound
					audio_player.play()
				is_dragging = false
				
var previous_volume_db = 0.0  # Store last volume before mute

func _on_mute_toggled(toggled_on: bool) -> void:
	if toggled_on:
		# Save current volume before muting
		previous_volume_db = AudioServer.get_bus_volume_db(0)
		# Mute by setting volume extremely low
		AudioServer.set_bus_volume_db(0, -80)
	else:
		# Unmute by restoring previous volume
		AudioServer.set_bus_volume_db(0, previous_volume_db)
