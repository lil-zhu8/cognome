extends Control

func _ready() -> void:
	var enabled:bool = SaveData.Get("music_enabled", true)
	var player:AudioStreamPlayer = $AudioStreamPlayer
	player.playing = enabled

func OnButtonPressed() -> void:
	var enabled:bool = SaveData.Get("music_enabled", true)
	enabled = !enabled
	SaveData.Set("music_enabled", enabled)
	var player:AudioStreamPlayer = $AudioStreamPlayer
	player.stream_paused = !enabled
	if enabled && !player.playing:
		player.playing = true


