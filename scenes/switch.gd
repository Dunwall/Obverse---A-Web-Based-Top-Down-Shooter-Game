extends Node2D

@export var connected_object: Node2D

@onready var area_2d: Area2D = $Area2D

var is_active := true
var cooldown := false
func _ready():
	area_2d.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	print("Body entered: ", body.name)
	if body.is_in_group("bullets"):
		print("Bullet hit switch")

		if connected_object:
			if connected_object.has_method("get_light_energy"):
				var current_energy = connected_object.get_light_energy()
				print("room energy =", current_energy)
			else:
				print("room has no get_light_energy method")

			if connected_object.has_method("is_light_on"):
				var light_on = connected_object.is_light_on()
				print("room reports is_light_on =", light_on)
				if light_on:
					# Only allow player to turn lights off (i.e., request darkness)
					if connected_object.has_method("activate"):
						print("Calling activate(false) to turn OFF light")
						connected_object.activate(false)
				else:
					print("Light already off, player cannot turn it on")
			else:
				# fallback - toggle if room doesn't provide methods
				is_active = not is_active
				if connected_object and connected_object.has_method("activate"):
					connected_object.activate(is_active)
		else:
			print("No connected_object on switch!")
		body.queue_free()
