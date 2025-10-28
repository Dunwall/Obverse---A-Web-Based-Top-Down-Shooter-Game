# Attach to RigidBody2D (door)
extends RigidBody2D

@export var open_angle = 90 # degrees to rotate when opened
@export var open_speed = 8  # higher is snappier

var opened = false

func apply_open_force():
	# Change rotation by applying an angular impulse
	apply_torque_impulse(open_speed)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not opened:
		opened = true
		apply_open_force()
