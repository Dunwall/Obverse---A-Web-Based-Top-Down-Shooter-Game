extends CharacterBody2D

@export var patrol_speed: float = 70.0
@export var patrol_loop: bool = false  # unused here, just in case
@export var path_follow: PathFollow2D
@export var connected_room: Node = null

var _path_length: float = 0.0
var _patrol_direction: int = 1  # 1 = forward, -1 = backward
var _wait_time: float = 0.0

enum State { IDLE, MOVING_TO_SWITCH, WAITING_AT_SWITCH, RETURNING_HOME }
var state: State = State.IDLE

@onready var enemy_legs = $enemyLegs # adjust paths as per your scene
@onready var enemy_torso = $enemyTorso

func _ready():
	assert(path_follow != null, "path_follow must be assigned")
	_path_length = path_follow.get_parent().curve.get_baked_length()
	path_follow.progress_ratio = 0.0
#	state = State.MOVING_TO_SWITCH
	print("BigEnemy ready and waiting for signal")

func _process(delta):
	match state:
		State.IDLE:
			_play_idle_animation()
			# Do nothing

		State.MOVING_TO_SWITCH:
			_move_along_path(delta)
			if path_follow.progress_ratio >= 1.0:
				path_follow.progress_ratio = 1.0
				state = State.WAITING_AT_SWITCH
				_wait_time = 2.0
				print("Reached switch")
				if connected_room and connected_room.has_method("activate"):
					connected_room.activate(true)  # turn lights ON

		State.WAITING_AT_SWITCH:
			_wait_time -= delta
			_play_idle_animation()
			if _wait_time <= 0:
				state = State.RETURNING_HOME
				_patrol_direction = -1

		State.RETURNING_HOME:
			_move_along_path(delta)
			if path_follow.progress_ratio <= 0.0:
				path_follow.progress_ratio = 0.0
				state = State.IDLE
				print("Returned home")

	_update_position_and_rotation()

func _move_along_path(delta):
	var step = _patrol_direction * (patrol_speed * delta / _path_length)
	path_follow.progress_ratio = clamp(path_follow.progress_ratio + step, 0.0, 1.0)
	
	if enemy_legs.animation != "walk_enemy" or not enemy_legs.is_playing():
		enemy_legs.play("walk_enemy")
	if enemy_torso.animation != "walk_enemy" or not enemy_torso.is_playing():
		enemy_torso.play("walk_enemy")

func _play_idle_animation():
	if enemy_legs.animation != "idle" or not enemy_legs.is_playing():
		enemy_legs.play("idle")
	if enemy_torso.animation != "idle" or not enemy_torso.is_playing():
		enemy_torso.play("idle")

func _update_position_and_rotation():
	global_position = path_follow.global_position
	rotation = path_follow.rotation
	velocity = Vector2.ZERO
	move_and_slide()
func _on_light_state_changed(is_dark: bool) -> void:
	print("Received light_state_changed signal, is_dark: ", is_dark)
	if is_dark:
		if state == State.IDLE:
			print("Light off - starting patrol")
			state = State.MOVING_TO_SWITCH
			_patrol_direction = 1  # ensure moving forward
