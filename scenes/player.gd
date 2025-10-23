extends Actor

@export var push_strength: float = 1300.0

func _physics_process(delta: float) -> void:
	if hp <= 0:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")

	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()

	velocity = input_vector * SPEED
	move_and_slide()

	rotation = (get_global_mouse_position() - global_position).angle()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D and collider.name.begins_with("Door"):
			collider.apply_impulse(collider.global_position, input_vector.normalized() * push_strength)

	if Input.is_action_pressed("left_click_pressed"):
		_gun.shoot()

func _ready() -> void:
	add_to_group("player")
