extends Node2D
@onready var pause_menu = $PauseMenu
@onready var start_screen = $Menu

func _ready() -> void:
	start_screen.visible = false  # Hide start screen when gameplay starts

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		print("ESC pressed. Paused? ", get_tree().paused)
		if not get_tree().paused:
			print("Opening pause menu")
			open_pause_menu()
		else:
			print("Closing pause menu")
			close_pause_menu()

func open_pause_menu():
	get_tree().paused = true
	pause_menu.visible = true

func close_pause_menu():
	pause_menu.visible = false
	get_tree().paused = false
