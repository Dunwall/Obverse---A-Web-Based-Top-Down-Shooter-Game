extends CharacterBody2D

@export var movespeed: float = 600.0
@export var bullet_speed = 2000.0
var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
func _physics_process(delta: float) -> void:
	var motion = Vector2.ZERO

	if Input.is_action_pressed("up"):
		motion.y -= 1
	elif Input.is_action_pressed("down"):
		motion.y += 1
	if Input.is_action_pressed("left"):
		motion.x -= 1
	elif Input.is_action_pressed("right"):
		motion.x += 1

	motion = motion.normalized()

	velocity = motion * movespeed
	move_and_slide()

	look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("LMB"):
		fire()

func fire() -> void:
	var bullet_instance = bullet_scene.instantiate()
	
	var dir = Vector2.RIGHT.rotated(rotation)
	bullet_instance.global_position = global_position + dir * 30
	bullet_instance.global_rotation = rotation
	
	get_parent().add_child(bullet_instance)

	if bullet_instance is RigidBody2D:
		bullet_instance.apply_impulse(dir * bullet_speed)
