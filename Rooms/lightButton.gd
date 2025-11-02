extends Area2D
signal toggled

func _ready():
	connect("body_entered", Callable(self, "_on_area_entered"))
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("bullets"):
		emit_signal("toggled")
