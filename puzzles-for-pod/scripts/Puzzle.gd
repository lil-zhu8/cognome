extends Control

class_name Puzzle

export var _columns:int
export(String, DIR) var _maskPath:String
export var _puzzlePieceScene:PackedScene

var Pieces:Array = []

func LoadMasks() -> Array:
	var filenames:Array = []
	var dir = Directory.new()
	dir.open(_maskPath)
	dir.list_dir_begin(true, true)
	var filename = dir.get_next()
	while filename != "":
		if filename.ends_with('.png.import'):
			filenames.append(filename.replace(".import", ""))
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

	set_scale(Vector2(get_size().x / image.get_size().x, get_size().y / image.get_size().y))
	if get_scale() != Vector2.ONE:
		push_warning("Wrong image aspect ratio, should be " + str(get_size().x / get_size().y) + " but was " + str(image.get_size().x / image.get_size().y))

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
