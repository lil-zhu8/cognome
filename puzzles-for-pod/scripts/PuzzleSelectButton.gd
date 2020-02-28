extends Control

class_name PuzzleSelectButton

signal Pressed

func Init(puzzleName:String) -> void:
	var progress:float = SaveData.GetProgress(puzzleName)
	var bar:ProgressBar = $VBoxContainer/ProgressBar
	bar.value = progress
	var textureRect:TextureRect = $VBoxContainer/TextureRect
	textureRect.texture = PuzzleData.PUZZLES[puzzleName].image

func OnButtonPressed() -> void:
	emit_signal("Pressed")
