extends Node2D
signal state_changed(new_state)

enum State{
	PATROL,
	ENGAGE
}

@onready var player_detection_zone = $PlayerDetectionZone

var current_state: int = State.PATROL setget set_state
var player: Player = null

func set_state(new)
