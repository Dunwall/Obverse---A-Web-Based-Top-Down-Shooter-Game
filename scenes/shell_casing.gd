class_name ShellCasing extends Sprite2D


func start(start_pos: Vector2) -> void:
	var spread: int = 8
	start_pos.x += randf_range(-spread, spread)
	start_pos.y += randf_range(-spread, spread)
	global_position = start_pos
	rotation_degrees = randf_range(0,360)
