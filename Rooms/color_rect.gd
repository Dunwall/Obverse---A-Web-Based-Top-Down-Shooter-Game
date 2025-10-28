extends ColorRect

@onready var label = $Label

func _ready():
	rect_size = label.get_size()
