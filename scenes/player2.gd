class_name Player extends Actor

func _physics_process(delta: float) -> void:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")

	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()

	velocity = input_vector * SPEED
	move_and_slide()
	# Always face mouse
	rotation = (get_global_mouse_position() - global_position).angle()

	if Input.is_action_pressed("left_click_pressed"):
		_gun.shoot()
# Player.gd
func _ready() -> void:
	add_to_group("actors")	
