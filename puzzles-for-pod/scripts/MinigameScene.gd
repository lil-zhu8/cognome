extends Node2D

enum State {SHOW_INITIAL, SHOW_ALL, CLICK, ANSWER}

export var _bubbleAreaPath:NodePath
export var _bubbleParentPath:NodePath
export var _viewportPath:NodePath
export var _labelPath:NodePath
export var _roundLabelPath:NodePath
export var _helpPopupPath:NodePath
export var _bubbleScene:PackedScene
export var _activeBubbleCount:int = 2
export var _inactiveBubbleCount:int = 12
export var _waitTime:float = 6.0
export var _minSpeed:float = 50.0
export var _maxSpeed:float = 100.0
export var _roundCount:int = 5

var _bubbles = []
var _state
var _clickedBubbles = []
var _transitioning = true

signal _bubbleClicked
signal _unhandledClick
signal _click

func _ready() -> void:
	var roundNumber:int = SaveData.Get("minigame_round", 0)

	_activeBubbleCount = roundNumber + 1
	var roundLabel:Label = get_node(_roundLabelPath)
	roundLabel.text = "Round %d/%d" % [roundNumber + 1, _roundCount]
	var label:Label = get_node(_labelPath)
	label.text = "Track the original bubble(s) to get more pieces!"# % _activeBubbleCount
	_state = State.SHOW_INITIAL
	for _i in range(_activeBubbleCount):
		SpawnBubble()

	yield(ScreenTransitioner.transitionIn(1.0, ScreenTransitioner.DIAMONDS), "completed")
	_transitioning = false

	#yield(self, "_unhandledClick")
	if !OS.is_debug_build() || !Input.is_key_pressed(KEY_SHIFT):
		yield(get_tree().create_timer(2.0), "timeout")

	_state = State.SHOW_ALL
	#label.text = "Track the original %d bubbles..." % _activeBubbleCount
	yield(get_tree().create_timer(0.5), "timeout")
	for _i in range(_inactiveBubbleCount):
		SpawnBubble()

	if !OS.is_debug_build() || !Input.is_key_pressed(KEY_SHIFT):
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
		else:
			correctCount += 1
			bubble.HighlightGotItRight()

	for i in _activeBubbleCount:
		var bubble:Bubble = _bubbles[i]
		bubble.HighlightCorrect()

	yield(self, "_unhandledClick")

	if _transitioning:
		return
	_transitioning = true

	yield(ScreenTransitioner.transitionOut(1.0, ScreenTransitioner.DIAMONDS), "completed")
	var total1:int = SaveData.Get("minigame_score", 0)
	var total2:int = SaveData.Get("minigame_max_score", 0)
	total1 += correctCount
	total2 += _activeBubbleCount
	SaveData.Set("minigame_score", total1)
	SaveData.Set("minigame_max_score", total2)

	if roundNumber < _roundCount - 1:
		roundNumber += 1
		SaveData.Set("minigame_round", roundNumber)
		get_tree().change_scene("res://scenes/minigame-scene.tscn")
		return

	var scoreHistory:Array = SaveData.Get("score_history", [])
	scoreHistory.append(float(total1) / total2)
	SaveData.Set("score_history", scoreHistory)
	get_tree().change_scene("res://scenes/minigame-results-scene.tscn")

func SpawnBubble() -> void:
	var bubbleArea:Control = get_node(_bubbleAreaPath)
	var rect:Rect2 = bubbleArea.get_global_rect()
	var bubble:Bubble = _bubbleScene.instance()
	var bubbleParent:Node2D = get_node(_bubbleParentPath)
	bubbleParent.add_child(bubble)

	var x:float
	var y:float

	var viewport:Viewport = get_node(_viewportPath)
	while true:
		x = rand_range(0, viewport.size.x)
		y = rand_range(0, viewport.size.y)
		var query:Physics2DShapeQueryParameters = Physics2DShapeQueryParameters.new()
		query.transform = Transform2D.IDENTITY.translated(Vector2(x, y))
		query.set_shape(bubble.CollisionShape())
		var intersections:Array = viewport.world_2d.direct_space_state.intersect_shape(query)
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
	var viewport:Viewport = get_node(_viewportPath)
	var viewportContainer:ViewportContainer = viewport.get_parent()
	var clickEvent:InputEventMouseButton = event as InputEventMouseButton
	if clickEvent != null && clickEvent.pressed:
		emit_signal("_click")
	if clickEvent != null && clickEvent.pressed && _state == State.CLICK:
		var intersections:Array = viewport.world_2d.direct_space_state.intersect_point(
			get_global_mouse_position() - viewportContainer.get_global_position()
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

func ExitButtonPressed() -> void:
	if _transitioning:
		return
	_transitioning = true
	yield(ScreenTransitioner.transitionOut(1.0, ScreenTransitioner.DIAMONDS), "completed")
	get_tree().change_scene("res://scenes/puzzle-play-scene.tscn")

func HelpButtonPressed() -> void:
	if _transitioning:
		return
	get_tree().paused = true
	var helpPopup:ColorRect = get_node(_helpPopupPath)
	helpPopup.visible = true
	yield(self, "_click")
	get_tree().paused = false
	helpPopup.visible = false
