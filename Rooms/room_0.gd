extends Node2D

@onready var dir_light: DirectionalLight2D = $DirectionalLight2D
@onready var big_enemy_node = get_node("EnemyPath/PathFollow2D/bigEnemy")  # Make sure this path is correct
var tween: Tween

signal light_state_changed(is_dark: bool)

func _ready():
	await get_tree().process_frame  # ensures all children are ready
	big_enemy_node = get_node("EnemyPath/PathFollow2D/bigEnemy")
	connect("light_state_changed", Callable(big_enemy_node, "_on_light_state_changed"))
	print("Connected signal to: ", big_enemy_node)

func activate(turn_on: bool):
	print("activate called, turn_on = ", turn_on)
	
	# Prevent redundant toggles
	var current_on := dir_light.energy < 0.4  # you can also track a boolean
	if current_on == turn_on:
		print("Light already in desired state — skipping tween")
		return

	if tween and is_instance_valid(tween):
		tween.kill()

	tween = get_tree().create_tween()
	var fade_time := 0.6
	var target_energy := 0.0 if turn_on else 0.75
	print("Tweening energy from ", dir_light.energy, " to ", target_energy)
	tween.tween_property(dir_light, "energy", target_energy, fade_time)
	tween.finished.connect(func(): print("Tween finished! Final energy =", dir_light.energy))

	emit_signal("light_state_changed", not turn_on)

# Return true if the room is currently lit (i.e., energy is low)
func is_light_on() -> bool:
	# subtract mode: low energy = bright, high energy = darker
	return dir_light.energy <= 0.1

# Return numeric energy so switches can debug/decide
func get_light_energy() -> float:
	return dir_light.energy
