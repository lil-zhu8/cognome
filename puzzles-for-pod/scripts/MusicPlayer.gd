extends Control

# Called when the node enters the scene tree for the first time.
func OnButtonPressed() -> void:
	var player:AudioStreamPlayer = $AudioStreamPlayer
	player.stream_paused = !player.stream_paused

