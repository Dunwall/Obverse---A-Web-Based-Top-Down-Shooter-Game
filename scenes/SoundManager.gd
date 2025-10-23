extends Node
signal noise_emitted(position: Vector2, radius: float)

func emit_noise(position: Vector2, radius: float) -> void:
	emit_signal("noise_emitted", position, radius)
