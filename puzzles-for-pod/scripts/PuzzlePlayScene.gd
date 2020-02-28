extends Node

export var _snapThreshold:int = 25
export var _puzzleParentPath:NodePath
export var _puzzlePreviewPath:NodePath
export var _unusedPositionPath:NodePath
export var _minigameButtonPath:NodePath

var _activePiece:PuzzlePiece = null
var _dragOffset:Vector2
var _puzzle:Puzzle

func _ready():
	var activePuzzle = SaveData.Get("active_puzzle", "1")
	var puzzleData:Dictionary = PuzzleData.PUZZLES[activePuzzle]
	_puzzle = Puzzle.new()
	get_node(_puzzleParentPath).add_child(_puzzle)
	_puzzle.Init(puzzleData)
	for piece in _puzzle.Pieces:
		var puzzlePiece:PuzzlePiece = piece as PuzzlePiece
		puzzlePiece.connect("GuiInput", self, "OnGuiInput", [puzzlePiece])
		PlaceUnused(puzzlePiece)
	var puzzlePreview:TextureRect = get_node(_puzzlePreviewPath)
	puzzlePreview.texture = puzzleData.image
	Load()
	Save()
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
	var activePuzzle:String = SaveData.Get("active_puzzle", "1")
	SaveData.Set(activePuzzle, result)

func Load() -> void:
	var activePuzzle:String = SaveData.Get("active_puzzle", "1")
	var data:Dictionary = SaveData.Get(activePuzzle, SaveData.EmptyPuzzleData(activePuzzle))
	for i in range(_puzzle.Pieces.size()):
		var piece:PuzzlePiece = _puzzle.Pieces[i]
		if data.pieces.has(str(i)):
			piece.Load(data.pieces[str(i)])

func HandleDrag(position:Vector2) -> void:
	if _activePiece != null:
		_activePiece.set_global_position(position + _dragOffset)

func PlaceUnused(piece:PuzzlePiece) -> void:
	var unusedPosition:Control = get_node(_unusedPositionPath)
	var rect:Rect2 = unusedPosition.get_global_rect()
	piece.PlaceRandomly(rect)

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
