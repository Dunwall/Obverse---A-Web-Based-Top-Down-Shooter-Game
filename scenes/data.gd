# data.gd
extends Node

# DON'T use class_name - it's already an autoload!

static var guns = {
	"pistol": GunData.new(
		7,      # rounds per mag
		0.3,    # fire rate
		1.5,    # reload time
		7      # total capacity
	),
	"uzi": GunData.new(
		24,
		0.2,
		2.0,
		24
	),
	"submachine_gun": GunData.new(
		24,     # rounds per mag
		0.1,    # fire rate (fast)
		2.0,    # reload time
		24     # total capacity
	),
	
	"shotgun": GunData.new(
		6,      # rounds per mag
		0.8,    # fire rate (slow)
		2.5,    # reload time
		6      # total capacity
	),
	
	"rifle": GunData.new(
		20,     # rounds per mag
		0.15,   # fire rate
		2.2,    # reload time
		20     # total capacity
	)
}

func _ready():
	guns.pistol.set_name_custom("Pistol")
	guns.submachine_gun.set_name_custom("Submachine Gun")
	guns.shotgun.set_name_custom("Shotgun")
	guns.rifle.set_name_custom("Rifle")
