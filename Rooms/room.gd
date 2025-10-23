extends Node2D
@onready var pause_menu = $pause_menu

func _ready():
	pause_menu.visible = false

func _input(event):
	if event.is_action_pressed("ui_cancel") and not get_tree().paused:
		open_pause_menu()
	elif event.is_action_pressed("ui_cancel") and get_tree().paused:
		close_pause_menu()

func open_pause_menu():
	get_tree().paused = true
	pause_menu.visible = true
	# Ensure PauseMenu can receive UI input while paused
	pause_menu.set_process_unhandled_input(true)

func close_pause_menu():
	pause_menu.visible = false
	get_tree().paused = false
