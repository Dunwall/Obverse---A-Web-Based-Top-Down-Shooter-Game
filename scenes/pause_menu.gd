extends Control

func resume() -> void:
	get_tree().paused = false
	visible = false

func restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func options() -> void:
	pass # Replace with function body.


func exit() -> void:
	get_tree().quit()
