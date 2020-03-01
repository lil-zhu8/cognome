extends Control

var _confirm:AudioStream = preload("res://sfx/confirm_down.wav")

export var _imagePath:NodePath

var _transitioning:bool = true

func _ready() -> void:
	var activePuzzle = SaveData.Get("active_puzzle", "1")
	var puzzleData:Dictionary = PuzzleData.PUZZLES[activePuzzle]
	var image:TextureRect = get_node(_imagePath)
	image.texture = puzzleData.image

	yield(ScreenTransitioner.transitionIn(1.0, ScreenTransitioner.DIAMONDS), "completed")
	_transitioning = false

func OnButtonPressed() -> void:
	if _transitioning:
		return
	AudioPlayer.playSound(_confirm)
	_transitioning = true
	yield(ScreenTransitioner.transitionOut(1.0, ScreenTransitioner.DIAMONDS), "completed")
	get_tree().change_scene("res://scenes/puzzle-select-scene.tscn")
