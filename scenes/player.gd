extends Actor

@export var push_strength: float = 1300.0

@onready var animated_sprite = $Character
var is_shooting = false

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

	# Shooting - BEFORE animation update
	if Input.is_action_pressed("left_click_pressed"):
		shoot()
	
	# Animation update - AFTER shooting
	update_animation(input_vector)

func _ready() -> void:
	add_to_group("player")

# Override Actor's get_sprite_node
func get_sprite_node():
	return animated_sprite

func update_animation(input_vector: Vector2):
	# Check if shoot animation is currently playing
	# FIXED: Use correct animation name
	var is_playing_shoot = animated_sprite.animation == "attack_scorpion" and animated_sprite.is_playing()
	
	if not is_playing_shoot:
		if input_vector.length() > 0:
			animated_sprite.play("walk_scorpion")
		else:
			animated_sprite.stop()

func shoot():
	# FIXED: Play correct animation name
	if animated_sprite.animation != "attack_scorpion" or not animated_sprite.is_playing():
		animated_sprite.play("attack_scorpion")
	
	# Gun handles its own cooldown
	if _gun != null:
		_gun.shoot()
