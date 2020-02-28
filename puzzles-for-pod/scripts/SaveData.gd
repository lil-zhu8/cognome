extends Node

var _data:Dictionary = {}

func _ready() -> void:
	var file:File = File.new()
	if file.open("user://savegame.txt", File.READ) != OK:
		return
	_data = parse_json(file.get_as_text())
	file.close()

func Get(key:String, defaultValue):
	var result = _data.get(key)
	if result == null:
		return defaultValue
	return result

func Set(key:String, value) -> void:
	_data[key] = value
	Save()

func Save() -> void:
	var file:File = File.new()
	if file.open("user://savegame.txt", File.WRITE) != OK:
		return
	file.store_line(to_json(_data))
	file.close()

func GetProgress(puzzleName:String) -> float:
	if !_data.has(puzzleName):
		return 0.0
	var puzzleSaveData:Dictionary = _data.get(puzzleName)
	var lockedPieces:float = 0
	for i in puzzleSaveData.pieces:
		if puzzleSaveData.pieces[i].locked:
			lockedPieces += 0.5
		if puzzleSaveData.pieces[i].available:
			lockedPieces += 0.5
	return lockedPieces / puzzleSaveData.pieces.size()

func EmptyPuzzleData(puzzleName:String) -> Dictionary:
	var pieceData:Dictionary = {}
	var puzzleData:Dictionary = PuzzleData.PUZZLES[puzzleName]
	var masks:Array = PuzzleMasks.MASKS[puzzleData.masks]["images"]
	for i in range(masks.size()):
		pieceData[str(i)] = {
			"position_x": 0,
			"position_y": 0,
			"locked": false,
			"available": false,
		}
	return {
		"pieces": pieceData
	}
