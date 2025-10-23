class_name Gun
extends Sprite2D 
signal gunshot_heard(position: Vector2)

# Just change this line to pick the gun from Data.guns
var data: GunData = Data.guns.submachine_gun

const BULLET: PackedScene = preload("res://scenes/bullet.tscn")
const SHELL_CASING: PackedScene = preload("res://scenes/shell_casing.tscn")

var ammo: int = data.rounds
var ammo_count: int = ammo * 6
var fire_rate: float
var spread: float = 0.05   # default, since GunData doesn’t define spread

@onready var _muzzle: Node2D = $Muzzle
@onready var _fire: AudioStreamPlayer2D = $Fire
@onready var _reload: AudioStreamPlayer2D = $Reload
@onready var _dry: AudioStreamPlayer2D = $Dry  
@onready var _fire_rate: Timer = $FireRate
@onready var _reload_time: Timer = $ReloadTime
@onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	await get_tree().process_frame
	fire_rate = data.fire_rate
	Events.ammo_updated.emit(ammo, ammo_count)

#Enemy Fire
func shoot_in_direction(dir: Vector2) -> void:
	if not _fire_rate.is_stopped() or not _reload_time.is_stopped():
		return
	if ammo <= 0:
		return
	
	var inst: Bullet = BULLET.instantiate()
	get_tree().current_scene.add_child(inst)
	inst.start(_muzzle.global_position, dir, true)  # 'true' since enemy bullet

	emit_signal("gunshot_heard", global_position)
	SoundManager.emit_noise(global_position, 600.0)  # radius = how far enemies can hear
	_fire.play()
	_fire_rate.start(fire_rate)
	ammo -= 1
	
	var casing = SHELL_CASING.instantiate()
	get_tree().current_scene.add_child(casing)
	if casing.has_method("start"):
		casing.start(_muzzle.global_position)


func shoot() -> void:
	if not _fire_rate.is_stopped() or not _reload_time.is_stopped():
		return
	if ammo <= 0:
		_dry.play()
		if ammo_count > 0 and _reload_time.is_stopped():
			_reload.play()
			_reload_time.start(data.reload_time)  # start reloading timer
		return
	# (rest of shooting code)


	var bullet: Bullet = BULLET.instantiate()
	var start_pos: Vector2 = _muzzle.global_position
	var dir: Vector2 = Vector2.RIGHT.rotated(global_rotation)

	get_tree().current_scene.add_child(bullet)
	bullet.start(start_pos, dir)

	_fire.play()
	_fire_rate.start(fire_rate)
	_animation_player.play("shoot")
	ammo -= 1
	Events.ammo_updated.emit(ammo, ammo_count)
	SoundManager.emit_noise(global_position, 900.0)
	# Spawn shell casing for player shooting
	var casing = SHELL_CASING.instantiate()
	get_tree().current_scene.add_child(casing)
	if casing.has_method("start"):
		casing.start(_muzzle.global_position)

	
func _on_reload_time_timeout() -> void:
	if ammo_count <= 0:
		return

	# fill the mag back up
	if ammo_count >= data.rounds:
		ammo = data.rounds
		ammo_count -= data.rounds
	else:
		ammo = ammo_count
		ammo_count = 0

	Events.ammo_updated.emit(ammo, ammo_count)
	
