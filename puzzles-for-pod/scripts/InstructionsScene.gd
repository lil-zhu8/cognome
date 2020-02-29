extends CanvasLayer

var _transitioning:bool = true

func _ready() -> void:
	yield(ScreenTransitioner.transitionIn(1.0, ScreenTransitioner.DIAMONDS), "completed")
	_transitioning = false

func OnButtonPressed() -> void:
	if _transitioning:
		return
	_transitioning = true
	yield(ScreenTransitioner.transitionOut(1.0, ScreenTransitioner.DIAMONDS), "completed")
	get_tree().change_scene("res://scenes/puzzle-select-scene.tscn")
