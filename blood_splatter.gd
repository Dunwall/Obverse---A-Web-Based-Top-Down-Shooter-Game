class_name BloodSplatter extends Sprite2D

@onready var _sound: AudioStreamPlayer2D = $Sound

func start(start_pos: Vector2, normal: Vector2 = Vector2.ZERO) -> void:
	global_position = start_pos
	if normal != Vector2.ZERO:
		rotation = normal.angle()
	else:
		rotation_degrees = randf_range(0, 360)
	_sound.play()
