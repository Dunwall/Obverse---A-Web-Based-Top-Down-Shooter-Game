class_name Door2
extends RigidBody2D

@export var push_strength: float = 100.0  
var bodies_in_zone: Array = []

func _ready() -> void:
	$PushZone.body_entered.connect(_on_body_entered)
	$PushZone.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("actors") and body.has_method("get_move_velocity"):
		bodies_in_zone.append(body)

func _on_body_exited(body: Node) -> void:
	bodies_in_zone.erase(body)

func _physics_process(_delta: float) -> void:
	rotation_degrees = clamp(rotation_degrees, -90, 90)
	for body in bodies_in_zone:
		var velocity = body.get_move_velocity()
		if velocity.length() > 0:
			var dir = velocity.normalized()
			var local_hit_pos = to_local(body.global_position)
			apply_impulse(dir * push_strength, local_hit_pos)
