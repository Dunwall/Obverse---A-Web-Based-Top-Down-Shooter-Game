extends Area2D

@onready var pickup_sound = $PickupSound  # optional

func _ready() -> void:
	print("GreenCard spawned:", global_position)

func _on_body_entered(body):
	print("Greencard touched by: ", body.name)
	if body.name == "Player":
		Global.add_keycard()
		print("Keycards:", Global.keycards_collected)
		
		if pickup_sound:
			pickup_sound.play()
			
		await get_tree().create_timer(0.1).timeout
		queue_free()  # remove the card from the scene
