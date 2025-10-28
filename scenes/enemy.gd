class_name Enemy
extends CharacterBody2D

@export var vision_delay: float = 0.2
@export var max_sight_distance: float = 250.0
@export var chase_speed: float = 150.0
@export var shoot_range: float = 100.0
@export var fire_delay: float = 0.6
@export var detection_range: float = 400.0
@export var los_check_interval: float = 0.2
@export var patrol_speed: float = 80.0
@export var patrol_loop: bool = true
@export var path_follow_node: NodePath
@export var search_memory_time: float = 1.0
@export var search_wait_time: float = 1.0
@export var hearing_range: float = 150.0
@export var hearing_chase_speed: float = 160.0
@export var damage: int = 1

# Roaming settings
@export var roam_enabled: bool = true
@export var roam_speed: float = 60.0
@export var roam_wait_time: float = 3.0
@export var roam_radius: float = 200.0

@onready var enemy_torso: AnimatedSprite2D = $enemyTorso
@onready var enemy_legs: AnimatedSprite2D = $enemyLegs
@onready var enemy_death: AnimatedSprite2D = $enemyDeath
@onready var agent: NavigationAgent2D = $NavigationAgent2D

enum State {
	PATROL,
	ROAM,
	CHASE,
	SEARCH,
	INVESTIGATE,
	RETURNING_TO_PATROL  # New state for walking back to patrol path
}

var _current_state: State = State.PATROL
var _spawn_position: Vector2
var _roam_target: Vector2
var _roam_wait_timer: float = 0.0

var _last_heard_position: Vector2
var _heard_gunshot: bool = false
var _last_seen_position: Vector2 = Vector2.ZERO
var _search_wait_timer: float = 0.0

var _player: Actor
var _shoot_timer: float = 0.0
var _los_timer: float = 0.0
var _can_see_player: bool = false
var _gun: Node
var _los_ray: RayCast2D
var _is_dead: bool = false
var _path_follow: PathFollow2D
var _path_length: float = 0.0
var _patrol_direction: int = 1
var _search_timer: float = 0.0
var _vision_timer: float = 0.0
var _player_in_sight: bool = false
var _is_shooting: bool = false
var navigation: NavigationRegion2D
var _return_to_patrol_target: Vector2  # Target point on patrol path

var blood_particles: GPUParticles2D

func _ready() -> void:
	# Get blood particles node
	if has_node("BloodParticles"):
		blood_particles = get_node("BloodParticles")
	elif has_node("GPUParticles2D"):
		blood_particles = get_node("GPUParticles2D")
	add_to_group("enemies")
	_spawn_position = global_position

	enemy_torso.sprite_frames = enemy_torso.sprite_frames.duplicate(true)
	enemy_legs.sprite_frames = enemy_legs.sprite_frames.duplicate(true)
	enemy_death.hide()

	if has_node("EnemGun"):
		_gun = get_node("EnemGun")

	if has_node("LoSRay"):
		_los_ray = get_node("LoSRay")

	# Check for patrol path
	if path_follow_node != NodePath():
		_path_follow = get_node_or_null(path_follow_node)
		if _path_follow and _path_follow.get_parent() and _path_follow.get_parent().has_method("get_curve"):
			_path_length = _path_follow.get_parent().curve.get_baked_length()
			_current_state = State.PATROL
		else:
			_path_follow = null
	
	# If no path, set up roaming
	if _path_follow == null:
		if roam_enabled:
			_current_state = State.ROAM
			_roam_wait_timer = 0.0
			_pick_new_roam_point()

	navigation = get_tree().get_root().get_node("NavigationRegion2D")
	call_deferred("_find_player")
	SoundManager.connect("noise_emitted", Callable(self, "_on_noise_emitted"))

	if agent.get_navigation_map() == null:
		var nav_map = navigation.get_navigation_map()
		if nav_map:
			agent.set_navigation_map(nav_map)

func _find_player() -> void:
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0 and players[0] is Actor:
		_player = players[0]

func _physics_process(delta: float) -> void:
	if _is_dead:
		enemy_legs.hide()
		enemy_torso.hide()
		enemy_death.show()
		if enemy_death.animation != "die" or not enemy_death.is_playing():
			enemy_death.play("die")
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if not _player or not is_instance_valid(_player) or _player.hp <= 0:
		_return_to_default_state()
		_process_default_state(delta)
		return

	var to_player = _player.global_position - global_position
	var distance_to_player = to_player.length()

	# --- Line of sight check ---
	_los_timer -= delta
	if _los_timer <= 0.0:
		var in_vision_range = distance_to_player <= max_sight_distance
		var has_line_of_sight = check_line_of_sight(_player)
		_player_in_sight = in_vision_range and has_line_of_sight

		if _player_in_sight:
			if _vision_timer < vision_delay:
				_vision_timer += los_check_interval
				_can_see_player = false
			else:
				_can_see_player = true
		else:
			_can_see_player = false
			_vision_timer = 0.0

		_los_timer = los_check_interval

	# Update memory
	if _can_see_player:
		_search_timer = search_memory_time
		_last_seen_position = _player.global_position
		if _current_state != State.CHASE:
			_current_state = State.CHASE
	else:
		_search_timer = max(_search_timer - delta, 0.0)

	# Determine if we should engage
	var should_engage = distance_to_player <= detection_range and (_can_see_player or _search_timer > 0 or _heard_gunshot)

	# State machine
	if not should_engage and _current_state in [State.CHASE, State.SEARCH, State.INVESTIGATE]:
		_return_to_default_state()
	elif should_engage and _current_state in [State.PATROL, State.ROAM, State.RETURNING_TO_PATROL]:
		_current_state = State.CHASE
	elif not _can_see_player and should_engage and _current_state == State.CHASE:
		_current_state = State.SEARCH
		agent.target_position = _last_seen_position

	# Process current state
	match _current_state:
		State.PATROL:
			_process_patrol(delta)
		State.ROAM:
			_process_roam(delta)
		State.CHASE:
			_process_chase(delta, to_player, distance_to_player)
		State.SEARCH:
			_process_search(delta)
		State.INVESTIGATE:
			_process_investigate(delta)
		State.RETURNING_TO_PATROL:
			_process_returning_to_patrol(delta)

func _process_patrol(delta: float) -> void:
	if _path_follow and _path_length > 0.0:
		_path_follow.progress_ratio += _patrol_direction * (patrol_speed * delta / _path_length)
		
		if not patrol_loop:
			if _path_follow.progress_ratio >= 1.0:
				_path_follow.progress_ratio = 1.0
				_patrol_direction = -1
			elif _path_follow.progress_ratio <= 0.0:
				_path_follow.progress_ratio = 0.0
				_patrol_direction = 1
		
		global_position = _path_follow.global_position
		rotation = _path_follow.rotation
		
		if enemy_legs.animation != "walk_enemy" or not enemy_legs.is_playing():
			enemy_legs.play("walk_enemy")
		if enemy_torso.animation != "walk_enemy" or not enemy_torso.is_playing():
			enemy_torso.play("walk_enemy")
	
	velocity = Vector2.ZERO
	move_and_slide()

func _process_roam(delta: float) -> void:
	if _roam_wait_timer > 0.0:
		_roam_wait_timer -= delta
		enemy_legs.stop()
		enemy_torso.stop()
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if agent.target_position.distance_to(_roam_target) > 10.0:
		agent.target_position = _roam_target
	
	if not agent.is_navigation_finished():
		var next_pos = agent.get_next_path_position()
		var direction = (next_pos - global_position).normalized()
		velocity = direction * roam_speed
		rotation = direction.angle()
		
		if enemy_legs.animation != "walk_enemy" or not enemy_legs.is_playing():
			enemy_legs.play("walk_enemy")
		if enemy_torso.animation != "walk_enemy" or not enemy_torso.is_playing():
			enemy_torso.play("walk_enemy")
	else:
		_roam_wait_timer = roam_wait_time
		_pick_new_roam_point()
		velocity = Vector2.ZERO
	
	move_and_slide()

func _process_chase(delta: float, to_player: Vector2, distance_to_player: float) -> void:
	if enemy_legs.animation != "walk_enemy" or not enemy_legs.is_playing():
		enemy_legs.play("walk_enemy")
	if not _is_shooting:
		if enemy_torso.animation != "walk_enemy" or not enemy_torso.is_playing():
			enemy_torso.play("walk_enemy")
	
	rotation = to_player.angle()
	
	if agent.target_position.distance_to(_player.global_position) > 10.0:
		agent.target_position = _player.global_position
	
	if not agent.is_navigation_finished():
		var next_pos = agent.get_next_path_position()
		var direction = (next_pos - global_position).normalized()
		var desired_velocity = direction * chase_speed
		velocity = velocity.lerp(desired_velocity, 0.2)
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	
	_shoot_timer -= delta
	if distance_to_player <= shoot_range and _can_see_player:
		if _shoot_timer <= 0 and not _is_shooting:
			_is_shooting = true
			enemy_torso.play("shoot_enemy")
			
			if _player and is_instance_valid(_player):
				_player.heal_hurt(-damage)
			
			if _gun and _gun.has_method("shoot"):
				_gun.shoot()
			
			_shoot_timer = fire_delay
			await enemy_torso.animation_finished
			_is_shooting = false
			if not _is_dead:
				enemy_torso.play("walk_enemy")

func _process_search(delta: float) -> void:
	var to_target = _last_seen_position - global_position
	var distance = to_target.length()
	
	if enemy_legs.animation != "walk_enemy" or not enemy_legs.is_playing():
		enemy_legs.play("walk_enemy")
	if enemy_torso.animation != "walk_enemy" or not enemy_torso.is_playing():
		enemy_torso.play("walk_enemy")
	
	rotation = to_target.angle()
	
	if distance > 20.0:
		if not agent.is_navigation_finished():
			var next_pos = agent.get_next_path_position()
			var direction = (next_pos - global_position).normalized()
			velocity = direction * hearing_chase_speed
		else:
			velocity = Vector2.ZERO
	else:
		_current_state = State.INVESTIGATE
		_search_wait_timer = search_wait_time
		velocity = Vector2.ZERO
	
	move_and_slide()

func _process_investigate(delta: float) -> void:
	_search_wait_timer -= delta
	
	enemy_legs.stop()
	enemy_torso.stop()
	velocity = Vector2.ZERO
	move_and_slide()
	
	if _search_wait_timer <= 0.0:
		_return_to_default_state()
		_heard_gunshot = false

func _process_returning_to_patrol(delta: float) -> void:
	# Walk back to the patrol path
	var to_target = _return_to_patrol_target - global_position
	var distance = to_target.length()
	
	if enemy_legs.animation != "walk_enemy" or not enemy_legs.is_playing():
		enemy_legs.play("walk_enemy")
	if enemy_torso.animation != "walk_enemy" or not enemy_torso.is_playing():
		enemy_torso.play("walk_enemy")
	
	rotation = to_target.angle()
	
	if distance > 20.0:
		if not agent.is_navigation_finished():
			var next_pos = agent.get_next_path_position()
			var direction = (next_pos - global_position).normalized()
			velocity = direction * patrol_speed
		else:
			velocity = Vector2.ZERO
	else:
		# Reached patrol path, snap to it and resume patrolling
		if _path_follow:
			var path = _path_follow.get_parent()
			if path and path.curve:
				var closest_offset = path.curve.get_closest_offset(path.to_local(global_position))
				_path_follow.progress = closest_offset
				global_position = _path_follow.global_position
				rotation = _path_follow.rotation
		_current_state = State.PATROL
		velocity = Vector2.ZERO
	
	move_and_slide()

func _process_default_state(delta: float) -> void:
	match _current_state:
		State.PATROL:
			_process_patrol(delta)
		State.ROAM:
			_process_roam(delta)
		State.RETURNING_TO_PATROL:
			_process_returning_to_patrol(delta)
		_:
			velocity = Vector2.ZERO
			enemy_legs.stop()
			enemy_torso.stop()
			move_and_slide()

func _return_to_default_state() -> void:
	_can_see_player = false
	_heard_gunshot = false
	_search_timer = 0.0
	
	if _path_follow != null:
		# Find closest point on patrol path and walk to it
		var path = _path_follow.get_parent()
		if path and path.curve:
			var closest_offset = path.curve.get_closest_offset(path.to_local(global_position))
			_return_to_patrol_target = path.to_global(path.curve.sample_baked(closest_offset))
			agent.target_position = _return_to_patrol_target
			_current_state = State.RETURNING_TO_PATROL
		else:
			_current_state = State.PATROL
	elif roam_enabled:
		_current_state = State.ROAM
		_pick_new_roam_point()

func _pick_new_roam_point() -> void:
	var random_angle = randf() * TAU
	var random_distance = randf_range(roam_radius * 0.3, roam_radius)
	_roam_target = _spawn_position + Vector2(cos(random_angle), sin(random_angle)) * random_distance

func _on_noise_emitted(shot_pos: Vector2, radius: float) -> void:
	var distance_to_shot = global_position.distance_to(shot_pos)
	if distance_to_shot <= hearing_range and not _can_see_player:
		_last_heard_position = shot_pos
		_last_seen_position = shot_pos
		_heard_gunshot = true
		_search_timer = search_memory_time
		_current_state = State.SEARCH
		agent.target_position = shot_pos

func check_line_of_sight(target: Node2D) -> bool:
	if not _los_ray:
		return true
	_los_ray.target_position = to_local(target.global_position)
	_los_ray.force_raycast_update()
	if not _los_ray.is_colliding():
		return true
	return _los_ray.get_collider() == target

func take_damage(amount: int) -> void:
	if _is_dead:
		return
	
	# Emit blood particles
	if blood_particles:
		blood_particles.emitting = true
	
	print("[Enemy] ", name, " took ", amount, " damage and died!")
	die()

func die() -> void:
	if _is_dead:
		return
	_is_dead = true

	set_physics_process(false)
	set_process(false)
	remove_from_group("enemies")
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, false)

	enemy_legs.hide()
	enemy_torso.hide()
	enemy_death.show()
	enemy_death.play("die")

	await enemy_death.animation_finished
	queue_free()
