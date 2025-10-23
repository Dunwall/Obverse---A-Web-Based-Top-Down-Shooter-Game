class_name Actor
extends CharacterBody2D

const SPEED: int = 200
const BULLET: PackedScene = preload("res://scenes/bullet.tscn")
const BLOOD_SPLATTER: PackedScene = preload("res://scenes/blood_splatter.tscn")

var hp: int = 1
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _gun: Gun = get_node("Gun")
@onready var _blood_particles: GPUParticles2D = $BloodParticles

func heal_hurt(value: int) -> void:
	hp += value
	if hp <= 0:
		set_collision_layer_value(2, false)
		_sprite.hide()

		var inst: BloodSplatter = BLOOD_SPLATTER.instantiate()
		get_tree().current_scene.add_child(inst)
		inst.start(global_position)

		# Show restart UI immediately
		var game_over_ui = get_tree().current_scene.get_node("RestartUI")
		if game_over_ui:
			game_over_ui.show_restart_screen()

		_blood_particles.restart()
		# Optionally await blood particles but this won't block UI now
		await(_blood_particles.finished)

		queue_free()
