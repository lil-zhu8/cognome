extends Node2D

export var _puzzleImage:Texture
export var _puzzleScene:PackedScene
export var _snapThreshold:int = 25

var _activePiece:PuzzlePiece = null
var _dragOffset:Vector2
var _puzzle:Puzzle

func _ready():
	_puzzle = _puzzleScene.instance()
	$PuzzleParent.add_child(_puzzle)
	_puzzle.Init(_puzzleImage)

func _unhandled_input(event: InputEvent) -> void:
	var clickEvent:InputEventScreenTouch = event as InputEventScreenTouch
	if clickEvent != null:
		if clickEvent.pressed:
			HandleClick(clickEvent.position)
		else:
			HandleRelease()

	var moveEvent:InputEventScreenDrag = event as InputEventScreenDrag
	if moveEvent != null:
		HandleDrag(moveEvent.position)

func HandleClick(position:Vector2) -> void:
	var intersections:Array = get_world_2d().direct_space_state.intersect_point(
		position,
		_puzzle.get_child_count(),
		[],
		2147483647,
		true,
		true
	)
	var clickedPiece:PuzzlePiece = null
	for intersection in intersections:
		var piece:PuzzlePiece = intersection.collider as PuzzlePiece
		if piece != null && (clickedPiece == null || piece.get_index() > clickedPiece.get_index()):
			clickedPiece = piece
	if clickedPiece != null:
		_activePiece = clickedPiece
		_dragOffset = clickedPiece.position - position
		_puzzle.move_child(clickedPiece, _puzzle.get_child_count() - 1)

func HandleRelease() -> void:
	if _activePiece != null && _activePiece.position.length_squared() <= _snapThreshold * _snapThreshold:
		_activePiece.position = Vector2.ZERO
	_activePiece = null

func HandleDrag(position: Vector2) -> void:
	if _activePiece != null:
		_activePiece.position = position + _dragOffset
