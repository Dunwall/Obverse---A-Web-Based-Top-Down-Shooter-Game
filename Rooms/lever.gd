extends StaticBody2D

@export var cooldown := 0.3
var can_toggle := true
@onready var detector: Area2D = $Detector

func _ready():
	detector.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not can_toggle:
		return
	if body.is_in_group("bullets"):
		var room = get_parent()
		if room.has_method("toggle_light"):
			room.toggle_light()
		body.queue_free()
		can_toggle = false
		await get_tree().create_timer(cooldown).timeout
		can_toggle = true
