class_name GunData
extends Resource

var name: String = ""
var rounds: int = 0           # Bullets per magazine
var fire_rate: float = 0.0
var reload_time: float = 0.0
var total_capacity: int = 0   # Total bullets the gun can hold

# REMOVED damage parameter since it's one-shot kill
func _init(_rounds: int, _fire_rate: float, _reload_time: float, _total_capacity: int = 0) -> void:
	rounds = _rounds
	fire_rate = _fire_rate
	reload_time = _reload_time
	# If no total_capacity provided, default to 6 magazines worth
	total_capacity = _total_capacity if _total_capacity > 0 else _rounds * 6

func set_name_custom(_name: String) -> void:
	name = _name
