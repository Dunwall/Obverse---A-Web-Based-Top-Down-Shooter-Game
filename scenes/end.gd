extends CanvasLayer

@onready var music_bus_name: String = "Music"
var music_bus_id: int

func _ready() -> void:
	music_bus_id = AudioServer.get_bus_index(music_bus_name)
	AudioManager.store_original_volume()  # store volume before fade
	fade_out_music()

func fade_out_music() -> void:
	var duration = 2.0
	var start_volume_db = AudioServer.get_bus_volume_db(music_bus_id)
	var end_volume_db = -80.0
	
	var timer = 0.0
	while timer < duration:
		var t = timer / duration
		var current_db = lerp(start_volume_db, end_volume_db, t)
		AudioServer.set_bus_volume_db(music_bus_id, current_db)
		await get_tree().process_frame
		timer += get_process_delta_time()
	
	AudioServer.set_bus_volume_db(music_bus_id, end_volume_db)
	
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://Rooms/start_screen.tscn")
