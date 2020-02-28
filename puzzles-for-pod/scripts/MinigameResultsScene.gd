extends Node2D

const _puzzlePieceScene:PackedScene = preload("res://scenes/puzzle-piece.tscn")
export var _puzzlePieceParent:NodePath
export var _resultLabelPath:NodePath
export var _minPiecesToUnlock:int = 0
export var _maxPiecesToUnlock:int = 7
export var _pieceSpacing:int = 20

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var _unlockedPieces = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var score:float = SaveData.Get("minigame_score", 6)
	var maxScore:float = SaveData.Get("minigame_max_score", 10)

	var resultLabel:RichTextLabel = get_node(_resultLabelPath)
	var rounded:int = round(100 * score / maxScore)
	resultLabel.bbcode_text = "[center]You got\n[color=red]%d%%[/color]\ncorrect![/center]" % rounded
	var piecesToUnlock:float = lerp(_minPiecesToUnlock, _maxPiecesToUnlock, score / maxScore)

	var puzzleName:String = SaveData.Get("active_puzzle", "1")
	var data:Dictionary = SaveData.Get(puzzleName, SaveData.EmptyPuzzleData(puzzleName))

	var pieces:Dictionary = data.pieces
	var unavailablePieces:Array = []

	for i in pieces:
		if !pieces[i].available:
			unavailablePieces.insert(randi() % (unavailablePieces.size() + 1), i)

			if _unlockedPieces.size() >= piecesToUnlock:
				break
	for i in range(piecesToUnlock):
		if i >= unavailablePieces.size():
			break
		var key:String = unavailablePieces[i]
		pieces[key].available = true
		_unlockedPieces.append(key)

	SaveData.Set(puzzleName, data)
	SpawnUnlockedPieces()
	yield(ScreenTransitioner.transitionIn(1.0, ScreenTransitioner.DIAMONDS), "completed")

func SpawnUnlockedPieces() -> void:
	var puzzleName:String = SaveData.Get("active_puzzle", "1")
	var puzzleData:Dictionary = PuzzleData.PUZZLES[puzzleName]
	var image:Texture = puzzleData.image
	var maskData:Dictionary = PuzzleMasks.MASKS[puzzleData.masks]
	var masks:Array = maskData.images
	var columns:int = maskData.columns
	var rows:int = masks.size() / columns
	var pieceSize:Vector2 = Vector2(image.get_size().x / columns, image.get_size().y / rows)
	var container:HBoxContainer = get_node(_puzzlePieceParent)
	container.set("custom_constants/separation", pieceSize.x + _pieceSpacing)

	for i in _unlockedPieces:
		var piece:PuzzlePiece = _puzzlePieceScene.instance()
		var control:Control = Control.new()
		control.set_v_size_flags(Control.SIZE_SHRINK_CENTER)
		container.add_child(control)
		control.add_child(piece)
		var mask:Texture = masks[int(i)]
		var row:int = int(i) / columns
		var col:int = int(i) % columns
		var position:Vector2 = Vector2(col * pieceSize.x, row * pieceSize.y)
		piece.Init(image, mask, pieceSize, position)
		piece.ZeroPositionCenterY()
		piece.MakeAvailable()

func OnResumeButtonPressed() -> void:
	yield(ScreenTransitioner.transitionOut(1.0, ScreenTransitioner.DIAMONDS), "completed")
	get_tree().change_scene("res://scenes/puzzle-play-scene.tscn")
