class_name Enemy
extends CharacterBody2D

@export var vision_delay: float = 0.2   # seconds before enemy reacts
@export var max_sight_distance: float = 250.0  # max distance for enemy sight1
@export var chase_speed: float = 150.0
@export var shoot_range: float = 100.0
@export var fire_delay: float = 0.6
@export var detection_range: float = 400.0
@export var los_check_interval: float = 0.2
@export var patrol_speed: float = 80.0
@export var patrol_loop: bool = true
@export var path_follow_node: NodePath  # drag PathFollow2D here (Enemy is NOT its child)
@export var search_memory_time: float = 3.0  # seconds enemy remembers seeing the player
@export var hearing_range: float = 100.0
@export var hearing_chase_speed: float = 120.0  # slower speed when chasing by hearing only


var _last_heard_position: Vector2
var _heard_gunshot: bool = false
var _last_seen_position: Vector2 = Vector2.ZERO

var _player: Actor
var _shoot_timer: float = 0.0
var _los_timer: float = 0.0
var _can_see_player: bool = false
var _gun: Node
var _los_ray: RayCast2D
var _is_dead: bool = false

var _patrolling: bool = true
var _path_follow: PathFollow2D
var _path_length: float = 0.0
var _patrol_direction: int = 1
var _search_timer: float = 0.0
var _vision_timer: float = 0.0
var _player_in_sight: bool = false

# Death sprites array
var death_sprites := [
	preload("res://asset/Enemy/death_pose_0.png"),
	preload("res://asset/Enemy/death_pose_1.png"),
	preload("res://asset/Enemy/death_pose_2.png")
]


@onready var agent: NavigationAgent2D = $NavigationAgent2D
var navigation: NavigationRegion2D
@onready var animated_sprite: AnimatedSprite2D = $Character
var _is_shooting: bool = false

func _ready() -> void:
	add_to_group("enemies")
	animated_sprite.sprite_frames = animated_sprite.sprite_frames.duplicate(true)
	if has_node("EnemGun"):
		_gun = get_node("EnemGun")
	else:
		push_warning("[Enemy] No 'EnemGun' node found — enemy will not shoot!")

	if has_node("LoSRay"):
		_los_ray = get_node("LoSRay")
	else:
		push_warning("[Enemy] No 'LoSRay' node found — enemy will not check LoS!")

	if path_follow_node != NodePath():
		_path_follow = get_node_or_null(path_follow_node)
		if _path_follow and _path_follow.get_parent() and _path_follow.get_parent().has_method("get_curve"):
			_path_length = _path_follow.get_parent().curve.get_baked_length()
	else:
		push_warning("[Enemy] No PathFollow2D assigned — patrol disabled")
		_patrolling = false

	navigation = get_tree().get_root().get_node("NavigationRegion2D")
	call_deferred("_find_player")
	SoundManager.connect("noise_emitted", Callable(self, "_on_noise_emitted"))
	if agent.get_navigation_map() == null:
		var nav_map = navigation.get_navigation_map()
		if nav_map:
			agent.set_navigation_map(nav_map)
		else:
			push_warning("[Enemy] Navigation map not found in NavigationRegion2D")

func _find_player() -> void:
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0 and players[0] is Actor:
		_player = players[0]
	else:
		push_warning("[Enemy] No valid player found in group 'player'")

func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	if not _player or not is_instance_valid(_player) or _player.hp <= 0:
		return

	var to_player := _player.global_position - global_position
	var distance := to_player.length()

	# --- Line of sight updates ---
	_los_timer -= delta
	if _los_timer <= 0.0:
		var saw_player_prev = _can_see_player

		var distance_to_player = (_player.global_position - global_position).length()
		var in_vision_range = distance_to_player <= max_sight_distance
		var has_line_of_sight = check_line_of_sight(_player)

		_player_in_sight = in_vision_range and has_line_of_sight

		# Introduce delayed reaction to seeing the player
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

		if saw_player_prev and not _can_see_player:
			_search_timer = search_memory_time

	# --- Memory countdown ---
	if _can_see_player:
		_search_timer = search_memory_time
		_last_seen_position = _player.global_position
	else:
		_search_timer = max(_search_timer - delta, 0.0)

	var can_chase := distance <= detection_range and (_can_see_player or _search_timer > 0 or _heard_gunshot)

	# --- PATROL MODE ---
	if not can_chase:
		_patrolling = true
		if _path_follow:
			patrol(delta)
			if animated_sprite.animation != "walk_enemy" or not animated_sprite.is_playing():
				animated_sprite.play("walk_enemy")

		else:
			velocity = Vector2.ZERO
			move_and_slide()
		return

	# --- CHASE/SHOOT MODE ---
	_patrolling = false

	if can_chase and not _is_shooting:
		if animated_sprite.animation != "walk_enemy" or not animated_sprite.is_playing():
			animated_sprite.play("walk_enemy")

	if distance > 2.0:
		rotation = to_player.angle()

	var target_pos: Vector2 = Vector2.ZERO
	if _can_see_player:
		target_pos = _player.global_position
	elif _heard_gunshot:
		target_pos = _last_heard_position
	else:
		target_pos = _last_seen_position

	var to_target = target_pos - global_position
	var target_distance = to_target.length()

	if target_distance > 2.0:
		rotation = to_target.angle()

	# --- Use NavigationAgent2D for movement ---
	if agent.target_position.distance_to(target_pos) > 10.0:
		agent.target_position = target_pos

	if not agent.is_navigation_finished():
		var next_pos = agent.get_next_path_position()
		var direction = (next_pos - global_position).normalized()

		var current_speed = chase_speed
		if _heard_gunshot and not _can_see_player:
			current_speed = hearing_chase_speed

		var desired_velocity = direction * current_speed
		velocity = velocity.lerp(desired_velocity, 0.2)
	else:
		velocity = Vector2.ZERO

	if _heard_gunshot and target_distance < 20.0:
		_heard_gunshot = false

	move_and_slide()

	# --- Shooting logic ---
	_shoot_timer -= delta
	if distance <= shoot_range and _can_see_player:
		if _shoot_timer <= 0.0 and _gun and _gun.has_method("shoot_in_direction"):
			_is_shooting = true
			animated_sprite.play("shoot_enemy")

		_gun.global_rotation = global_rotation
		_gun.shoot_in_direction(Vector2.RIGHT.rotated(_gun.global_rotation))
		_shoot_timer = fire_delay

		await animated_sprite.animation_finished
		_is_shooting = false


func _on_noise_emitted(shot_pos: Vector2, radius: float) -> void:
	var distance_to_shot = global_position.distance_to(shot_pos)
	if distance_to_shot <= hearing_range and not _can_see_player:
		_last_heard_position = shot_pos
		_heard_gunshot = true
		_search_timer = search_memory_time

func patrol(delta: float) -> void:
	if not _path_follow or _path_length == 0.0:
		return

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
	print("[Enemy] ", name, " took ", amount, " damage and died!")
	die()

@onready var corpse_sprite: Sprite2D = $CorpseSprite

func die() -> void:
	if _is_dead:
		return
	_is_dead = true

	# Disable logic/collisions
	set_physics_process(false)
	set_process(false)
	remove_from_group("enemies")
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, false)

	# Randomize static corpse sprite (safe now)
	if animated_sprite:
		animated_sprite.stop()
		var random_index = randi() % death_sprites.size()
		var frames := SpriteFrames.new()
		frames.add_frame("dead", death_sprites[random_index])
		animated_sprite.sprite_frames = frames
		animated_sprite.play("dead")

	rotation += randf_range(-0.3, 0.3)

	await get_tree().create_timer(2.0).timeout
	queue_free()

	
'''func _draw():
	if agent and agent.get_current_navigation_path().size() > 0:
		var path = agent.get_current_navigation_path()
		for i in range(path.size() - 1):
			draw_line(to_local(path[i]), to_local(path[i + 1]), Color(1, 0, 0), 2)

func _process(_delta):
	queue_redraw()
'''
