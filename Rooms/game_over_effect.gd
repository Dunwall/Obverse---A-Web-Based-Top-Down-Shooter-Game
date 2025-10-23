extends Control
var can_restart: bool = false

func show_restart_screen():
	visible = true
	can_restart = true

func hide_restart_screen():
	visible = false
	can_restart = false

func _input(event):
	if can_restart and event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
