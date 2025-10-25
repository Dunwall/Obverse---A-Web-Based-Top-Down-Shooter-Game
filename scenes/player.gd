extends Actor

@export var push_strength: float = 1300.0

@onready var animated_sprite = $Character

# Animation name constants
const ANIM_WALK = "walk_scorpion"
const ANIM_ATTACK = "attack_scorpion"

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

	# Shooting
	if Input.is_action_pressed("left_click_pressed"):
		shoot()
	
	# Animation update
	update_animation(input_vector)

func _ready() -> void:
	add_to_group("player")

func get_sprite_node():
	return animated_sprite

func update_animation(input_vector: Vector2):
	var is_attacking = animated_sprite.animation == ANIM_ATTACK and animated_sprite.is_playing()
	
	if not is_attacking:
		if input_vector.length() > 0:
			animated_sprite.play(ANIM_WALK)
		else:
			animated_sprite.stop()

func shoot():
	# CHANGED: Only play animation if gun has bullets
	if _gun != null:
		# Check if gun has bullets in magazine
		if _gun.current_mag > 0:
			# Play animation only when there are bullets
			if animated_sprite.animation != ANIM_ATTACK or not animated_sprite.is_playing():
				animated_sprite.play(ANIM_ATTACK)
		
		# Gun script handles shooting (including dry fire sound)
		_gun.shoot()
