extends Actor
class_name PlayerBody

@export var push_strength: float = 1300.0

@onready var legs_sprite = $LegsAnimatedSprite2d
@onready var torso_sprite = $TorsoAnimatedSprite2d
@onready var death_sprite = $DeathAnimatedSprite2d

const LEGS_WALK_ANIM = "walk_legs"
const TORSO_WALK_ANIM = "walk_scorpion"
const TORSO_ATTACK_ANIM = "attack_scorpion"

func _physics_process(delta: float) -> void:
	if hp <= 0:
		# Stop movement
		velocity = Vector2.ZERO
		move_and_slide()

		# Hide legs and torso sprites, show death sprite
		legs_sprite.hide()
		torso_sprite.hide()
		death_sprite.show()
		if death_sprite.animation != "death" or not death_sprite.is_playing():
			death_sprite.play("death")
		return
	else:
		# Ensure death sprite is hidden when alive
		death_sprite.hide()
		legs_sprite.show()
		torso_sprite.show()

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

func update_animation(input_vector: Vector2):
	var is_attacking = torso_sprite.animation == TORSO_ATTACK_ANIM and torso_sprite.is_playing()
	
	if input_vector.length() > 0:
		legs_sprite.play(LEGS_WALK_ANIM)
		if not is_attacking:
			torso_sprite.play(TORSO_WALK_ANIM)
	else:
		legs_sprite.stop()
		if not is_attacking:
			torso_sprite.stop()

func shoot():
	if _gun != null and _gun.current_mag > 0:
		if torso_sprite.animation != TORSO_ATTACK_ANIM or not torso_sprite.is_playing():
			torso_sprite.play(TORSO_ATTACK_ANIM)
		_gun.shoot()
