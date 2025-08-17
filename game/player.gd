extends CharacterBody2D

@export var movespeed: float = 600.0

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
