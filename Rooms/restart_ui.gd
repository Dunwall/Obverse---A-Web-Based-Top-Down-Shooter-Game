extends CanvasLayer

var you_died_label: Label
var press_r_label: Label

func _ready():
	you_died_label = $HBoxContainer/YouDiedLabel
	press_r_label = $HBoxContainer2/PressRLabel
	you_died_label.visible = false
	press_r_label.visible = false

func show_restart_screen():
	you_died_label.visible = true
	press_r_label.visible = true

func _process(_delta):
	if you_died_label.visible and Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
