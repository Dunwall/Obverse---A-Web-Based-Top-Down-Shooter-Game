class_name Actor
extends CharacterBody2D

const SPEED: int = 170
const BULLET: PackedScene = preload("res://scenes/bullet.tscn")
const BLOOD_SPLATTER: PackedScene = preload("res://scenes/blood_splatter.tscn")

var hp: int = 1
@onready var _gun: Gun = $Gun
@onready var _blood_particles: GPUParticles2D = $BloodParticles

# Virtual function - override in child classes if needed
func get_sprite_node():
	return null

func heal_hurt(value: int) -> void:
	hp += value
	if hp <= 0:
		die()

func die() -> void:
	set_collision_layer_value(2, false)
	
	# Hide sprite (works for both Sprite2D and AnimatedSprite2D)
	var sprite = get_sprite_node()
	if sprite != null:
		sprite.hide()
	
	# Spawn blood splatter
	#var inst: BloodSplatter = BLOOD_SPLATTER.instantiate()
	#get_tree().current_scene.add_child(inst)
	#inst.start(global_position)
	
	# Show restart UI immediately
	var game_over_ui = get_tree().current_scene.get_node("RestartUI")
	if game_over_ui:
		game_over_ui.show_restart_screen()
	
	# Play blood particles
	if _blood_particles != null:
		_blood_particles.restart()
		await _blood_particles.finished
	
	queue_free()
