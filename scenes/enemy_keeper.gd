extends CharacterBody2D

@export var health: int = 3
@export var linked_card: NodePath   # assign this in the editor!
@onready var enemy_idle = $Idle
@onready var enemy_death = $Death
@onready var collision = $CollisionShape2D
@onready var blood_particles = $BloodParticles2D

var _is_dead := false

func _ready():
	enemy_idle.show()
	enemy_death.hide()

func take_damage(amount: int) -> void:
	if _is_dead:
		return

	health -= amount
	if blood_particles:
		blood_particles.emitting = true

	if health <= 0:
		die()

func die() -> void:
	if _is_dead:
		return
	_is_dead = true

	set_physics_process(false)
	set_process(false)
	collision.disabled = true

	enemy_idle.hide()
	enemy_death.show()
	enemy_death.play("death_animation")

	# --- Reveal assigned green card ---
	if linked_card != null and has_node(linked_card):
		var card = get_node(linked_card)
		card.visible = true
		if card.has_node("CollisionShape2D"):
			card.get_node("CollisionShape2D").disabled = false
		if card is Area2D:
			card.monitoring = true
		print("[EnemyKeeper] Revealed", card.name)
	# ----------------------------------

	await enemy_death.animation_finished
	enemy_death.stop()
