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
	
	"submachine_gun": GunData.new(
		30,     # rounds per mag
		0.1,    # fire rate (fast)
		2.0,    # reload time
		30     # total capacity
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
