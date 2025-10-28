extends CanvasLayer

var you_died_panel: Panel
var press_r_panel: Panel

func _ready():
	you_died_panel = $Panel
	press_r_panel = $Panel2
	you_died_panel.visible = false
	press_r_panel.visible = false

func show_restart_screen():
	you_died_panel.visible = true
	press_r_panel.visible = true


func _process(_delta):
	if you_died_panel.visible and Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
