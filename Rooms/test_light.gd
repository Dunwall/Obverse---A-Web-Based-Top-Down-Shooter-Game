extends Node2D

@onready var dir_light: DirectionalLight2D = $DirectionalLight2D
var tween: Tween
var going_dark := true

func _ready():
	# Start a looping fade cycle
	_loop_fade()

func _loop_fade():
	if tween and is_instance_valid(tween):
		tween.kill()

	tween = get_tree().create_tween()
	var fade_time := 1.5
	var target_energy := 0.75 if going_dark else 0.0

	tween.tween_property(dir_light, "energy", target_energy, fade_time)
	tween.tween_callback(Callable(self, "_on_fade_complete"))

func _on_fade_complete():
	# Flip direction and start next cycle
	going_dark = not going_dark
	_loop_fade()
