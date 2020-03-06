extends Control

func _ready() -> void:
	var enabled:bool = SaveData.Get("music_enabled", true)
	var player:AudioStreamPlayer = $AudioStreamPlayer
	player.playing = enabled
	var button:TextureButton = $Button
	button.modulate = Color.white if enabled else Color(1.0, 1.0, 1.0, 0.5)

func OnButtonPressed() -> void:
	var enabled:bool = SaveData.Get("music_enabled", true)
	enabled = !enabled
	SaveData.Set("music_enabled", enabled)
	var player:AudioStreamPlayer = $AudioStreamPlayer
	player.stream_paused = !enabled
	if enabled && !player.playing:
		player.playing = true
	var button:TextureButton = $Button
	button.modulate = Color.white if enabled else Color(1.0, 1.0, 1.0, 0.5)
	
func _input(ev):
	if ev is InputEventKey and ev.scancode == KEY_K:
		print('awftnaw222222222222fuytnawfuyt')
		var img = get_viewport().get_texture().get_data()
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		img.flip_y()
		img.save_png("user://cap.png")
	