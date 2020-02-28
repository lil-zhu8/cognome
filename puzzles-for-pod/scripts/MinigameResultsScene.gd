extends Node2D

const _puzzlePieceScene:PackedScene = preload("res://scenes/puzzle-piece.tscn")
const _whitePixel:Texture = preload("res://harmonic-godot/sprites/white-pixel.png")
export var _viewportMargin:int = 10
export var _viewportXMargin:int = 30
export var _pointColor:Color = Color(0, 0.3, 0.9)
export var _puzzlePieceParent:NodePath
export var _resultLabelPath:NodePath
export var _minPiecesToUnlock:int = 0
export var _maxPiecesToUnlock:int = 7
export var _pieceSpacing:int = 20
export var _graphLinePath:NodePath
export var _graphViewportPath:NodePath

var _lastPoint:Sprite = null
var _transitioning:bool = true
var _unlockedPieces = []

func _ready() -> void:
	var score:float = SaveData.Get("minigame_score", 6)
	var maxScore:float = SaveData.Get("minigame_max_score", 10)
	DrawGraph()

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
	_transitioning = false

func DrawGraph() -> void:
	var scoreHistory:Array = SaveData.Get("score_history", [0.2, .5, .7, .3, 1])
	var line:Line2D = get_node(_graphLinePath)
	var viewport:Viewport = get_node(_graphViewportPath)
	var width:float = viewport.size.x - _viewportXMargin * 2
	var height:float = viewport.size.y - _viewportMargin * 2
	var arr:PoolVector2Array = PoolVector2Array()
	for i in scoreHistory.size():
		var x:float = _viewportXMargin + 0.5 * width
		if scoreHistory.size() > 1:
			x = width * i / (scoreHistory.size() - 1) + _viewportXMargin
		var y:float = (1 - scoreHistory[i]) * viewport.size.y + _viewportMargin

		arr.append(Vector2(x, y))
		var pix:Sprite = Sprite.new()
		pix.texture = _whitePixel
		pix.scale = Vector2(10, 10)
		pix.modulate = _pointColor
		viewport.add_child(pix)
		pix.position = Vector2(x, y)
		_lastPoint = pix
	line.points = arr

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
	if _transitioning:
		return
	_transitioning = true
	yield(ScreenTransitioner.transitionOut(1.0, ScreenTransitioner.DIAMONDS), "completed")
	get_tree().change_scene("res://scenes/puzzle-play-scene.tscn")

func _process(delta:float) -> void:
	if _lastPoint == null:
		return
	var l:float = sin(OS.get_ticks_msec() * .001 * 2 * PI / 1.0) * 0.5 + 0.5
	_lastPoint.modulate = lerp(Color(1, 0, 1), Color(0, 0, 1), l)
