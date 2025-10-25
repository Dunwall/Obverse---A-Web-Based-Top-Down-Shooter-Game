extends Control

@onready var options: Panel = $Options
@onready var main_buttons: VBoxContainer = $MainButtons

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Rooms/room.tscn")

func _ready() -> void:
	main_buttons.visible = true
	options.visible = false

func _on_settings_pressed() -> void:
	print("settings pressed")
	main_buttons.visible = false
	options.visible = true
	

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	_ready()
