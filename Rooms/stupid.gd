extends CanvasLayer
@onready var main_buttons: VBoxContainer = $pause_menu/MainButtons
@onready var options_panel: Panel = $pause_menu/Options
func _unhandled_input(event):
	if event is InputEventMouseButton:
		print("Mouse click detected")


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	visible = false
	print("Resume pressed")

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_options_button_pressed() -> void:
	main_buttons.visible = false
	options_panel.visible = true

func _on_exit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Rooms/start_screen.tscn")

func _ready():
	options_panel.visible = false

func _on_back_pressed() -> void:
	options_panel.visible = false
	main_buttons.visible = true
