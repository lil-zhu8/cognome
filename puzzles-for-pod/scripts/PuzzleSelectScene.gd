extends Node2D

var _confirm:AudioStream = preload("res://sfx/confirm.wav")
var _puzzleSelectButtonScene:PackedScene = preload("res://scenes/puzzle-select-button.tscn")
var _popupSound:AudioStream = preload("res://sfx/popup.wav")
export var _gridPath:NodePath
export var _popup:NodePath
export var _completedPopup:NodePath
export var _scrollContainerPath:NodePath
var _transitioning:bool = true

func _ready() -> void:
	var grid:GridContainer = get_node(_gridPath)
	for puzzle in PuzzleData.PUZZLES:
		var button:PuzzleSelectButton = _puzzleSelectButtonScene.instance()
		grid.add_child(button)
		button.Init(puzzle)
		button.connect("Pressed", self, "OnButtonPressed", [puzzle])
	grid.move_child(grid.get_child(0), grid.get_child_count() - 1)
	yield(ScreenTransitioner.transitionIn(1.0, ScreenTransitioner.DIAMONDS), "completed")
	_transitioning = false

func OnButtonPressed(puzzle:String) -> void:
	if _transitioning:
		return

	if puzzle == "more_puzzles":
		ShowPopup()
		return
	SaveData.Set("active_puzzle", puzzle)
	var progress:float = SaveData.GetProgress(puzzle)
	if progress >= 1.0:
		ShowCompletedPopup()
		return

	_transitioning = true
	AudioPlayer.playSound(_confirm)
	yield(ScreenTransitioner.transitionOut(1.0, ScreenTransitioner.DIAMONDS), "completed")
	get_tree().change_scene("res://scenes/puzzle-play-scene.tscn")

func ShowPopup() -> void:
	var popup:ColorRect = get_node(_popup)
	popup.visible = true
	AudioPlayer.playSound(_popupSound)
	var dialog:AcceptDialog = popup.get_node("AcceptDialog")
	dialog.popup()
	while dialog.visible:
		yield(get_tree(), "idle_frame")
	AudioPlayer.playSound(_popupSound)
	popup.visible = false

func ShowCompletedPopup() -> void:
	AudioPlayer.playSound(_popupSound)
	var popup:ColorRect = get_node(_completedPopup)
	popup.visible = true

func CompletedOkPressed() -> void:
	if _transitioning:
		return
	var puzzle:String = SaveData.Get("active_puzzle", "1")
	SaveData.Set(puzzle, SaveData.EmptyPuzzleData(puzzle))
	_transitioning = true
	AudioPlayer.playSound(_confirm)
	yield(ScreenTransitioner.transitionOut(1.0, ScreenTransitioner.DIAMONDS), "completed")
	get_tree().change_scene("res://scenes/puzzle-play-scene.tscn")

func CompletedCancelPressed() -> void:
	if _transitioning:
		return
	AudioPlayer.playSound(_popupSound)
	var popup:ColorRect = get_node(_completedPopup)
	popup.visible = false
