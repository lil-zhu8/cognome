extends Node

export var _puzzleImage:Texture
export var _puzzleScene:PackedScene
export var _snapThreshold:int = 25
export var _puzzleParentPath:NodePath
export var _puzzlePreviewPath:NodePath
export var _unusedPositionPath:NodePath
export var _minigameButtonPath:NodePath

var _activePiece:PuzzlePiece = null
var _dragOffset:Vector2
var _puzzle:Puzzle

func _ready():
	_puzzle = _puzzleScene.instance()
	get_node(_puzzleParentPath).add_child(_puzzle)
	_puzzle.Init(_puzzleImage)
	for piece in _puzzle.Pieces:
		var puzzlePiece:PuzzlePiece = piece as PuzzlePiece
		puzzlePiece.connect("GuiInput", self, "OnGuiInput", [puzzlePiece])
		PlaceUnused(puzzlePiece)
	var puzzlePreview:TextureRect = get_node(_puzzlePreviewPath)
	puzzlePreview.texture = _puzzleImage
	Load()
	yield(ScreenTransitioner.transitionIn(1.0, ScreenTransitioner.DIAMONDS), "completed")

func OnGuiInput(event:InputEvent, piece:PuzzlePiece) -> void:
	var clickEvent:InputEventMouseButton = event as InputEventMouseButton
	if clickEvent != null:
		if clickEvent.pressed:
			HandleClick(clickEvent.global_position, piece)
		else:
			HandleRelease()
	var moveEvent:InputEventMouseMotion = event as InputEventMouseMotion
	if moveEvent != null:
		HandleDrag(moveEvent.global_position)

func HandleClick(position:Vector2, piece:PuzzlePiece) -> void:
	_activePiece = piece
	_dragOffset = piece.get_global_position() - position
	_puzzle.move_child(piece, _puzzle.get_child_count() - 1)

func HandleRelease() -> void:
	if _activePiece != null && _activePiece.get_position().length_squared() <= _snapThreshold * _snapThreshold:
		_activePiece.Snap()
	Save()
	_activePiece = null

func Save() -> void:
	var result:Dictionary = {}
	result.pieces = {}
	for i in range(_puzzle.Pieces.size()):
		var piece:PuzzlePiece = _puzzle.Pieces[i];
		result.pieces[str(i)] = piece.Save()
	SaveData.Set(_puzzleScene.get_name(), result)

func Load() -> void:
	var data:Dictionary = SaveData.Get(_puzzleScene.get_name())
	if data != null:
		for i in range(_puzzle.Pieces.size()):
			var piece:PuzzlePiece = _puzzle.Pieces[i]
			piece.Load(data.pieces[str(i)])

	var newPieces:int = SaveData.Get("new_pieces_available") || 0
	RevealPieces(newPieces)
	SaveData.Set("new_pieces_available", 0)

func SaveData(data:Dictionary) -> void:
	if !data.has(_puzzleScene.get_name()):
		data[_puzzleScene.get_name()] = {}

	var result:Dictionary = data[_puzzleScene.get_name()]
	result.pieces = {}
	for i in range(_puzzle.Pieces.size()):
		var piece:PuzzlePiece = _puzzle.Pieces[i];
		result.pieces[str(i)] = piece.Save()

func HandleDrag(position:Vector2) -> void:
	if _activePiece != null:
		_activePiece.set_global_position(position + _dragOffset)

func PlaceUnused(piece:PuzzlePiece) -> void:
	var unusedPosition:Control = get_node(_unusedPositionPath)
	var rect:Rect2 = unusedPosition.get_global_rect()
	piece.PlaceRandomly(rect)

func RevealPieces(count:int) -> void:

	var i:int = _puzzle.get_child_count() - 1
	while i >= 0:
		var piece:PuzzlePiece = _puzzle.get_child(i)
		if !piece.IsAvailable():
			piece.MakeAvailable()
			count -= 1
			if count <= 0:
				return
		i -= 1

func OnMinigameButtonPressed() -> void:
	yield(ScreenTransitioner.transitionOut(1.0, ScreenTransitioner.DIAMONDS), "completed")
	get_tree().change_scene("res://scenes/minigame-scene.tscn")

func HasAvailablePiece() -> bool:
	for p in _puzzle.Pieces:
		var piece:PuzzlePiece = p
		if piece.IsAvailable() && !piece.IsLocked():
			return true
	return false

func _process(_delta:float) -> void:
	var button:GlowingButton = get_node(_minigameButtonPath)
	button.Enabled = !HasAvailablePiece()

func OnMorePuzzlesButtonPressed() -> void:
	_puzzle.Reset()
	for p in _puzzle.Pieces:
		var piece:PuzzlePiece = p
		PlaceUnused(piece)
	Save()
