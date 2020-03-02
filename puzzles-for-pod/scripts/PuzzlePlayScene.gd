extends Node

var _confirm:AudioStream = preload("res://sfx/confirm.wav")
var _confirmDown:AudioStream = preload("res://sfx/confirm_down.wav")
var _popupSound:AudioStream = preload("res://sfx/popup.wav")
var _pieceUp:AudioStream = preload("res://sfx/piece_up.wav")
var _pieceDown:AudioStream = preload("res://sfx/piece_down.wav")
var _pieceSnap:AudioStream = preload("res://sfx/piece_snap.wav")
var _puzzleComplete:AudioStream = preload("res://sfx/puzzle_complete.wav")

export var _snapThreshold:int = 25
export var _puzzleParentPath:NodePath
export var _puzzlePreviewPath:NodePath
export var _unusedPositionPath:NodePath
export var _minigameButtonPath:NodePath
export var _helpPopupPath:NodePath

var _activePiece:PuzzlePiece = null
var _dragOffset:Vector2
var _puzzle:Puzzle
var _transitioning:bool = true

signal _unhandledClick

func _ready():
	var activePuzzle = SaveData.Get("active_puzzle", "1")
	analytics.add_to_event_queue(analytics.get_progression_event("Start:Puzzle:%s" % activePuzzle))
	var puzzleData:Dictionary = PuzzleData.PUZZLES[activePuzzle]
	_puzzle = Puzzle.new()
	get_node(_puzzleParentPath).add_child(_puzzle)
	_puzzle.Init(puzzleData)
	for piece in _puzzle.Pieces:
		var puzzlePiece:PuzzlePiece = piece as PuzzlePiece
		puzzlePiece.connect("GuiInput", self, "OnGuiInput", [puzzlePiece])
	var puzzlePreview:TextureRect = get_node(_puzzlePreviewPath)
	puzzlePreview.texture = puzzleData.image
	Load()
	for piece in _puzzle.Pieces:
		var puzzlePiece:PuzzlePiece = piece as PuzzlePiece
		#piece.MakeAvailable()
		if puzzlePiece.JustAvailable:
			PlaceUnused(puzzlePiece)
	Save()
	yield(ScreenTransitioner.transitionIn(1.0, ScreenTransitioner.DIAMONDS), "completed")
	_transitioning = false

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
	AudioPlayer.playSound(_pieceUp)
	_dragOffset = piece.get_global_position() - position
	_puzzle.move_child(piece, _puzzle.get_child_count() - 1)

func HandleRelease() -> void:
	if _activePiece != null && _activePiece.get_position().length_squared() <= _snapThreshold * _snapThreshold:
		_activePiece.Snap(false)
		AudioPlayer.playSound(_pieceSnap)
	Save()
	if _activePiece != null:
		AudioPlayer.playSound(_pieceDown)
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

	# Always ensure first 5 pieces are available.
	var availablePieces = []
	var unavailablePieces = []
	for i in range(_puzzle.Pieces.size()):
		var piece:PuzzlePiece = _puzzle.Pieces[i]
		if piece.IsAvailable():
			availablePieces.append(piece)
		else:
			unavailablePieces.append(piece)

	while availablePieces.size() < 5:
		var index:int = randi() % unavailablePieces.size()
		var piece:PuzzlePiece = unavailablePieces[index]
		piece.MakeAvailable()
		piece.JustAvailable = true
		unavailablePieces.remove(index)
		availablePieces.append(piece)

func HandleDrag(position:Vector2) -> void:
	if _activePiece != null:
		_activePiece.set_global_position(position + _dragOffset)

func PlaceUnused(piece:PuzzlePiece) -> void:
	var unusedPosition:Control = get_node(_unusedPositionPath)
	var rect:Rect2 = unusedPosition.get_global_rect()
	piece.PlaceRandomly(rect)

func OnMinigameButtonPressed() -> void:
	if _transitioning:
		return
	_transitioning = true
	AudioPlayer.playSound(_confirm)
	yield(ScreenTransitioner.transitionOut(1.0, ScreenTransitioner.DIAMONDS), "completed")
	SaveData.Set("minigame_round", 0)
	SaveData.Set("minigame_score", 0)
	SaveData.Set("minigame_max_score", 0)

	var seenInstructions:bool = SaveData.Get("seen_minigame_instructions", false)
	SaveData.Set("seen_minigame_instructions", true)
	if !seenInstructions:
		get_tree().change_scene("res://scenes/minigame-instructions-scene.tscn")
	else:
		get_tree().change_scene("res://scenes/minigame-scene.tscn")

func HasAvailablePiece() -> bool:
	for p in _puzzle.Pieces:
		var piece:PuzzlePiece = p
		if piece.IsAvailable() && !piece.IsLocked():
			return true
	return false

func HasUnavailablePiece() -> bool:
	for p in _puzzle.Pieces:
		var piece:PuzzlePiece = p
		if !piece.IsAvailable():
			return true
	return false

func _process(_delta:float) -> void:
	var button:GlowingButton = get_node(_minigameButtonPath)
	button.Enabled = !HasAvailablePiece()
	var availablePieceCount:int = 0
	for p in _puzzle.Pieces:
		var piece:PuzzlePiece = p
		if piece.IsAvailable():
			availablePieceCount += 1
	button.Enabled = button.Enabled || availablePieceCount <= 5
	button.disabled = !HasUnavailablePiece()

	if _transitioning:
		return

	for p in _puzzle.Pieces:
		var piece:PuzzlePiece = p
		if !piece.IsLocked():
			return

	var activePuzzle = SaveData.Get("active_puzzle", "1")
	analytics.add_to_event_queue(analytics.get_progression_event("Complete:Puzzle:%s" % activePuzzle))
	_transitioning = true
	yield(get_tree().create_timer(1.0), "timeout")

	AudioPlayer.playSound(_puzzleComplete)

	yield(ScreenTransitioner.transitionOut(1.0, ScreenTransitioner.DIAMONDS), "completed")
	get_tree().change_scene("res://scenes/congrats-scene.tscn")

func ResetPuzzle() -> void:
	_puzzle.Reset()
	for p in _puzzle.Pieces:
		var piece:PuzzlePiece = p
		PlaceUnused(piece)
	Save()

func OnMorePuzzlesButtonPressed() -> void:
	if _transitioning:
		return
	_transitioning = true
	AudioPlayer.playSound(_confirmDown)
	yield(ScreenTransitioner.transitionOut(1.0, ScreenTransitioner.DIAMONDS), "completed")
	get_tree().change_scene("res://scenes/puzzle-select-scene.tscn")

func OnHelpButtonPressed() -> void:
	if _transitioning:
		return
	var helpPopup:ColorRect = get_node(_helpPopupPath)
	helpPopup.visible = true
	AudioPlayer.playSound(_popupSound)
	yield(self, "_unhandledClick")
	AudioPlayer.playSound(_popupSound)
	helpPopup.visible = false

func _input(event: InputEvent) -> void:
	var clickEvent:InputEventMouseButton = event as InputEventMouseButton
	if clickEvent != null && clickEvent.pressed:
		emit_signal("_unhandledClick")
