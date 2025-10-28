extends HSlider

@export var sfx_bus_name: String = "SFX"  # Change this if your SFX bus has a different name

var sfx_bus_id: int

func _ready() -> void:
	sfx_bus_id = AudioServer.get_bus_index(sfx_bus_name)
	# Set slider value to current bus volume converted from dB to linear 
	var current_db = AudioServer.get_bus_volume_db(sfx_bus_id)
	value = db_to_linear(current_db)

func _on_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(sfx_bus_id, db)
