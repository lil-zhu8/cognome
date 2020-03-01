extends CanvasLayer

var _confirm:AudioStream = preload("res://sfx/confirm_down.wav")

var _transitioning:bool = true

func _ready() -> void:
	yield(ScreenTransitioner.transitionIn(1.0, ScreenTransitioner.DIAMONDS), "completed")
	_transitioning = false

func OnButtonPressed() -> void:
	if _transitioning:
		return
	AudioPlayer.playSound(_confirm)
	_transitioning = true
	yield(ScreenTransitioner.transitionOut(1.0, ScreenTransitioner.DIAMONDS), "completed")
	get_tree().change_scene("res://scenes/minigame-scene.tscn")
