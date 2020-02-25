extends Node2D

enum State {SHOW_INITIAL, SHOW_ALL, CLICK, ANSWER}

export var _bubbleAreaPath:NodePath
export var _bubbleParentPath:NodePath
export var _labelPath:NodePath
export var _bubbleScene:PackedScene
export var _activeBubbleCount:int = 2
export var _inactiveBubbleCount:int = 12
export var _waitTime:float = 6.0
export var _minSpeed:float = 50.0
export var _maxSpeed:float = 100.0

var _bubbles = []
var _state
var _clickedBubbles = []

signal _bubbleClicked
signal _unhandledClick

func _ready() -> void:
	var label:Label = get_node(_labelPath)
	label.text = "Track these %d bubbles as they move!\nTap to continue..." % _activeBubbleCount
	_state = State.SHOW_INITIAL
	for _i in range(_activeBubbleCount):
		SpawnBubble()

	yield(ScreenTransitioner.transitionIn(1.0, ScreenTransitioner.DIAMONDS), "completed")

	yield(self, "_unhandledClick")

	_state = State.SHOW_ALL
	label.text = "Track the original %d bubbles..." % _activeBubbleCount
	yield(get_tree().create_timer(0.5), "timeout")
	for _i in range(_inactiveBubbleCount):
		SpawnBubble()
	yield(get_tree().create_timer(_waitTime), "timeout")

	_state = State.CLICK
	label.text = "Tap on the original %d bubbles!" % _activeBubbleCount
	for b in _bubbles:
		var bubble:Bubble = b as Bubble
		bubble.StopMotion()
	while _clickedBubbles.size() < _activeBubbleCount:
		var clickedBubble:Bubble = yield(self, "_bubbleClicked")
		if !_clickedBubbles.has(clickedBubble):
			_clickedBubbles.append(clickedBubble)
			clickedBubble.Highlight()

	_state = State.ANSWER
	label.text = "Correct answer:\nTap to continue..."
	var correctCount:int = 0
	for bubble in _clickedBubbles:
		if _bubbles.find(bubble) >= _activeBubbleCount:
			bubble.HighlightWrong()
	for i in _activeBubbleCount:
		var bubble:Bubble = _bubbles[i]
		bubble.HighlightCorrect()
		correctCount += 1

	SaveData.Set("new_pieces_available", correctCount)
	yield(self, "_unhandledClick")
	yield(ScreenTransitioner.transitionOut(1.0, ScreenTransitioner.DIAMONDS), "completed")
	get_tree().change_scene("res://scenes/puzzle-play-scene.tscn")

func SpawnBubble() -> void:
	var bubbleArea:Control = get_node(_bubbleAreaPath)
	var rect:Rect2 = bubbleArea.get_global_rect()
	var bubble:Bubble = _bubbleScene.instance()
	var bubbleParent:Node2D = get_node(_bubbleParentPath)
	bubbleParent.add_child(bubble)

	var x:float
	var y:float

	while true:
		x = rand_range(rect.position.x, rect.end.x)
		y = rand_range(rect.position.y, rect.end.y)
		var query:Physics2DShapeQueryParameters = Physics2DShapeQueryParameters.new()
		query.transform = Transform2D.IDENTITY.translated(Vector2(x, y))
		query.set_shape(bubble.CollisionShape())
		var intersections:Array = get_world_2d().direct_space_state.intersect_shape(query)
		if intersections.size() <= 0:
			break

	bubble.set_global_position(Vector2(x, y))
	_bubbles.append(bubble)
	bubble.StartMotion(rand_range(_minSpeed, _maxSpeed))

func RandomPosition() -> Vector2:
	var bubbleArea:Control = get_node(_bubbleAreaPath)
	var rect:Rect2 = bubbleArea.get_global_rect()
	var x:float= rand_range(rect.position.x, rect.end.x)
	var y:float = rand_range(rect.position.y, rect.end.y)
	return Vector2(x, y)

func _input(event:InputEvent) -> void:
	var clickEvent:InputEventMouseButton = event as InputEventMouseButton
	if clickEvent != null && clickEvent.pressed && _state == State.CLICK:
		var intersections:Array = get_world_2d().direct_space_state.intersect_point(
			clickEvent.get_global_position()
		)
		for intersection in intersections:
			var bubble:Bubble = intersection.collider as Bubble
			if bubble != null:
				emit_signal("_bubbleClicked", bubble)
				get_tree().set_input_as_handled()
				return

func _unhandled_input(event: InputEvent) -> void:
	var clickEvent:InputEventMouseButton = event as InputEventMouseButton
	if clickEvent != null && clickEvent.pressed:
		emit_signal("_unhandledClick")
