extends Camera2D

@export var max_offset_distance: float = 100
@export var return_speed: float = 700

var player: Node2D
var camera_offset: Vector2 = Vector2.ZERO
var shift_pressed: bool = false

func _ready():
	player = get_parent()


func _process(delta):
	if player == null:
		return

	shift_pressed = Input.is_action_pressed("ui_shift")
	if shift_pressed:
		var mouse_pos = get_global_mouse_position()
		var target_offset = (mouse_pos - player.global_position).limit_length(max_offset_distance)
		camera_offset = camera_offset.move_toward(target_offset, 1000 * delta)  # 600 can be adjusted for smoothing speed
	else:
		camera_offset = camera_offset.move_toward(Vector2.ZERO, return_speed * delta)
	global_position = player.global_position + camera_offset
