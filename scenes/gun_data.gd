class_name GunData
extends Resource

var name: String = ""
var rounds: int = 0
var damage: int = 0
var fire_rate: float = 0.0
var reload_time: float = 0.0

func _init(_rounds: int, _damage: int, _fire_rate: float, _reload_time: float) -> void:
	rounds = _rounds
	fire_rate = _fire_rate
	reload_time = _reload_time
	damage = _damage
func set_name_custom(_name: String)->void:
	name = _name
