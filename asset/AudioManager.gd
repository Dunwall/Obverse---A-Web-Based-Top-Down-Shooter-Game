extends Node
# AudioManager.gd (autoload singleton)
var original_music_volume_db: float = 0.0

func store_original_volume():
	var music_bus_id = AudioServer.get_bus_index("Music")
	original_music_volume_db = AudioServer.get_bus_volume_db(music_bus_id)

func restore_original_volume():
	var music_bus_id = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(music_bus_id, original_music_volume_db)
