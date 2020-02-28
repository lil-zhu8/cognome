extends Control

class_name Puzzle

const _puzzlePieceScene:PackedScene = preload("res://scenes/puzzle-piece.tscn")

var Pieces:Array = []

func Init(puzzleData:Dictionary) -> void:
	var maskData:Dictionary = PuzzleMasks.MASKS[puzzleData.masks]
	var columns:int = maskData.columns
	var masks:Array = maskData.images
	var rows:int = masks.size() / columns
	var image:Texture = puzzleData.image
	var pieceSize:Vector2 = Vector2(image.get_size().x / columns, image.get_size().y / rows)

	for i in range(masks.size()):
		var row:int = i / columns
		var col:int = i % columns
		var position:Vector2 = Vector2(col * pieceSize.x, row * pieceSize.y)
		ConstructPiece(image, masks[i], pieceSize, position)

	set_scale(Vector2(get_parent().get_size().x / image.get_size().x, get_parent().get_size().y / image.get_size().y))
	if get_scale() != Vector2.ONE:
		push_warning("Wrong image aspect ratio, should be " + str(get_parent().get_size().x / get_parent().get_size().y) + " but was " + str(image.get_size().x / image.get_size().y))

	# Randomize sort order
	for child in get_children():
		move_child(child, randi() % get_child_count())

func Reset() -> void:
	for p in Pieces:
		var piece:PuzzlePiece = p
		piece.Reset()
		move_child(p, randi() % get_child_count())

func ConstructPiece(image:Texture, mask:Texture, pieceSize:Vector2, position:Vector2) -> void:
	var newPiece:PuzzlePiece = _puzzlePieceScene.instance()
	newPiece.Init(image, mask, pieceSize, position)
	add_child(newPiece)
	Pieces.append(newPiece)
