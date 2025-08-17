extends CharacterBody2D

@export var speed: float = 200.0

func _physics_process(delta: float) -> void:
	var player = get_parent().get_node("Player")
	if not player:
		return 
		
	var direction = (player.position - position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	look_at(player.position)
