extends Node

export var _puzzleImage:Texture
export var _puzzleScene:PackedScene
export var _snapThreshold:int = 25
export var _puzzleParentPath:NodePath
export var _puzzlePreviewPath:NodePath
export var _unusedPositionPath:NodePath

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
		_activePiece.set_position(Vector2.ZERO)
	_activePiece = null

func HandleDrag(position: Vector2) -> void:
	if _activePiece != null:
		_activePiece.set_global_position(position + _dragOffset)

func PlaceUnused(piece: PuzzlePiece) -> void:
	var unusedPosition:Control = get_node(_unusedPositionPath)
	var rect:Rect2 = unusedPosition.get_global_rect()
	piece.PlaceRandomly(rect)
