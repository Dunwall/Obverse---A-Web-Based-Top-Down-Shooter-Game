class_name Bullet
extends CharacterBody2D

const SHELL_CASING: PackedScene = preload("res://scenes/shell_casing.tscn")
const SPEED: int = 600
const DAMAGE: int = 1  # Always 1 since it's one-shot kill
const IMPACT: PackedScene = preload("res://scenes/blood_splatter.tscn")
const HIT_WALL: AudioStream = preload("res://sounds/wall-hit-1-100717.mp3")
const HIT_FLESH: AudioStream = preload("res://sounds/080998_bullet-hit-39870.mp3")

@export var friendly: bool = false

@onready var _hit: AudioStreamPlayer2D = $Hit

func _physics_process(delta: float) -> void:
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision:
		var collider: Object = collision.get_collider()
		
		if collider is TileMapLayer:
			print("Bullet hit wall/tile: ", collider)
			if _hit:
				_hit.stream = HIT_WALL
				Util.audio_play_varied_pitch_2d(_hit)
		
		elif collider is Enemy:
			print("Bullet hit Enemy: ", collider.name)
			# One-shot kill - always deal 1 damage (which kills since hp = 1)
			if collider.has_method("take_damage"):
				collider.take_damage(1)
			elif collider.has_method("heal_hurt"):
				collider.heal_hurt(-1)
			
			#inst.start(global_position)
			
			if _hit:
				_hit.stream = HIT_FLESH
				Util.audio_play_varied_pitch_2d(_hit)
		
		elif collider is Actor:
			print("Bullet hit Actor (Player): ", collider.name)
			# One-shot kill for player too
			collider.heal_hurt(-1)
			print("Actor HP after hit: ", collider.hp)
			
			var inst = IMPACT.instantiate()
			get_tree().current_scene.add_child(inst)
			inst.start(global_position)
			
			if _hit:
				_hit.stream = HIT_FLESH
				Util.audio_play_varied_pitch_2d(_hit)
		
		elif collider is Door:
			print("Bullet hit Door: ", collider.name)
			var impulse_dir: Vector2 = -collision.get_normal() * 200.0
			collider.apply_impulse(impulse_dir, collider.to_local(global_position))
		
		print("Bullet destroyed: ", self)
		queue_free()

func start(start_pos: Vector2, direction: Vector2, is_enemy_bullet: bool = false) -> void:
	global_position = start_pos
	rotation = direction.angle()
	velocity = direction * SPEED
	friendly = is_enemy_bullet
	
	if friendly:
		set_collision_mask_value(1, true)  # walls
		set_collision_mask_value(2, true)  # player
		set_collision_mask_value(3, false) # NOT enemies
	else:
		set_collision_mask_value(1, true)  # walls
		set_collision_mask_value(2, false) # NOT player
		set_collision_mask_value(3, true)  # enemies
