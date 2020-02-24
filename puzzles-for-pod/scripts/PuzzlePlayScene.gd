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
	Load()

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
	Save()
	_activePiece = null

func Save() -> void:
	var file:File = File.new()
	var data:Dictionary = {}
	if file.open("user://savegame.txt", File.READ) == OK:
		data = parse_json(file.get_as_text())
		file.close()

	SaveData(data)

	if file.open("user://savegame.txt", File.WRITE) == OK:
		file.store_line(to_json(data))
		file.close()

func Load() -> void:
	var file:File = File.new()
	if file.open("user://savegame.txt", File.READ) != OK:
		return

	var allData:Dictionary = parse_json(file.get_as_text())
	file.close()
	if !allData.has(_puzzleScene.get_name()):
		return

	var data:Dictionary = allData[_puzzleScene.get_name()]
	for i in range(_puzzle.Pieces.size()):
		var piece:PuzzlePiece = _puzzle.Pieces[i]
		piece.Load(data.pieces[str(i)])

func SaveData(data:Dictionary) -> void:
	if !data.has(_puzzleScene.get_name()):
		data[_puzzleScene.get_name()] = {}

	var result:Dictionary = data[_puzzleScene.get_name()]
	result.pieces = {}
	for i in range(_puzzle.Pieces.size()):
		var piece:PuzzlePiece = _puzzle.Pieces[i];
		result.pieces[str(i)] = piece.Save()

func HandleDrag(position: Vector2) -> void:
	if _activePiece != null:
		_activePiece.set_global_position(position + _dragOffset)

func PlaceUnused(piece: PuzzlePiece) -> void:
	var unusedPosition:Control = get_node(_unusedPositionPath)
	var rect:Rect2 = unusedPosition.get_global_rect()
	piece.PlaceRandomly(rect)
