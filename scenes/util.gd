# res://scripts/util.gd
class_name Util

# Plays an AudioStreamPlayer2D with a random pitch
static func audio_play_varied_pitch_2d(player: AudioStreamPlayer2D, min_pitch := 0.9, max_pitch := 1.1) -> void:
	if player.stream == null:
		return
	player.pitch_scale = randf_range(min_pitch, max_pitch)
	player.play()
