class_name Gun
extends Sprite2D 
signal gunshot_heard(position: Vector2)

var data: GunData = Data.guns.submachine_gun

const BULLET: PackedScene = preload("res://scenes/bullet.tscn")
const SHELL_CASING: PackedScene = preload("res://scenes/shell_casing.tscn")

# CHANGED: Track total bullets and max capacity
var total_bullets: int  # Current bullets you have
var max_capacity: int   # Maximum bullets this gun can hold
var current_mag: int    # Bullets currently in magazine
var fire_rate: float
var spread: float = 0.05

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
	
	# CHANGED: Initialize ammo system
	max_capacity = data.total_capacity  # e.g., 24 for pistol (4 rounds * 6 mags)
	total_bullets = max_capacity     # Start with full ammo
	current_mag = data.rounds        # Magazine starts full
	
	Events.ammo_updated.emit(total_bullets, max_capacity)

# Enemy Fire
func shoot_in_direction(dir: Vector2) -> void:
	if not _fire_rate.is_stopped() or not _reload_time.is_stopped():
		return
	if current_mag <= 0:
		return
	
	var inst: Bullet = BULLET.instantiate()
	get_tree().current_scene.add_child(inst)
	inst.start(_muzzle.global_position, dir, true)

	emit_signal("gunshot_heard", global_position)
	SoundManager.emit_noise(global_position, 600.0)
	_fire.play()
	_fire_rate.start(fire_rate)
	
	# CHANGED: Decrease both mag and total
	current_mag -= 1
	total_bullets -= 1
	
	var casing = SHELL_CASING.instantiate()
	get_tree().current_scene.add_child(casing)
	if casing.has_method("start"):
		casing.start(_muzzle.global_position)

# In gun.gd
func shoot() -> bool:
	if not _fire_rate.is_stopped() or not _reload_time.is_stopped():
		return false  # On cooldown
	
	# Check current magazine
	if current_mag <= 0:
		_dry.play()
		# Try to reload if we have bullets left
		if total_bullets > 0 and _reload_time.is_stopped():
			_reload.play()
			_reload_time.start(data.reload_time)
		return false  # No bullets, didn't shoot

	var bullet: Bullet = BULLET.instantiate()
	var start_pos: Vector2 = _muzzle.global_position
	var dir: Vector2 = Vector2.RIGHT.rotated(global_rotation)

	get_tree().current_scene.add_child(bullet)
	bullet.start(start_pos, dir)

	_fire.play()
	_fire_rate.start(fire_rate)
	_animation_player.play("shoot")
	
	current_mag -= 1
	total_bullets -= 1
	
	Events.ammo_updated.emit(total_bullets, max_capacity)
	SoundManager.emit_noise(global_position, 900.0)
	
	var casing = SHELL_CASING.instantiate()
	get_tree().current_scene.add_child(casing)
	if casing.has_method("start"):
		casing.start(_muzzle.global_position)
	
	return true  # Successfully shot


func _on_reload_time_timeout() -> void:
	# CHANGED: Reload magazine from total bullets
	if total_bullets <= 0:
		return  # No bullets left to reload
	
	# Calculate how many bullets to put in mag
	var bullets_needed = data.rounds - current_mag  # How many to fill magazine
	var bullets_available = total_bullets - current_mag  # Bullets not in current mag
	
	if bullets_available >= bullets_needed:
		# Enough bullets to fill magazine completely
		current_mag = data.rounds
	else:
		# Not enough for full mag, use what we have
		current_mag += bullets_available
	
	# Update UI (total_bullets doesn't change during reload)
	Events.ammo_updated.emit(total_bullets, max_capacity)
