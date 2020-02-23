extends Node2D

class_name Puzzle

export var _columns:int
export(String, DIR) var _maskPath:String
export var _puzzlePieceScene:PackedScene

var Pieces:Array = []

func LoadMasks() -> Array:
	var filenames:Array = []
	var dir = Directory.new()
	dir.open(_maskPath)
	dir.list_dir_begin()
	var filename = dir.get_next()
	while filename != "":
		if filename.ends_with('png'):
			filenames.append(filename)
		filename = dir.get_next()

	var result = []
	filenames.sort()
	for filename in filenames:
		result.append(load(_maskPath + "/" + filename));
	return result

func Init(image:Texture) -> void:
	var masks:Array = LoadMasks()
	var rows:int = masks.size() / _columns
	var pieceSize:Vector2 = Vector2(image.get_size().x / _columns, image.get_size().y / rows)

	for i in range(masks.size()):
		var row:int = Pieces.size() / _columns
		var col:int = i % _columns
		var position:Vector2 = Vector2(col * pieceSize.x, row * pieceSize.y)
		ConstructPiece(image, masks[i], pieceSize, position)

func ConstructPiece(image:Texture, mask:Texture, pieceSize:Vector2, position:Vector2) -> void:
	var newPiece:PuzzlePiece = _puzzlePieceScene.instance()
	newPiece.Init(image, mask, pieceSize, position)
	add_child(newPiece)
	Pieces.append(newPiece)
