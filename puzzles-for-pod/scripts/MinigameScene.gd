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

const UUID = preload("res://analytics/uuid.gd")
var _showSound:AudioStream = preload("res://sfx/bubble_show.wav")
var _selectSound:AudioStream = preload("res://sfx/bubble_select.wav")
var _popupSound:AudioStream = preload("res://sfx/popup.wav")
var _confirm:AudioStream = preload("res://sfx/confirm.wav")
var _confirmDown:AudioStream = preload("res://sfx/confirm_down.wav")

var _bubbles = []
var _state
var _clickedBubbles = []
var _transitioning = true
var _roundNumber:int = 0

signal _bubbleClicked
signal _unhandledClick
signal _click

func _ready() -> void:
	_roundNumber = SaveData.Get("minigame_round", 0)
	analytics.add_to_event_queue(analytics.get_progression_event("Start:Minigame:Round%d" % (_roundNumber + 1)))

	_activeBubbleCount = _roundNumber + 1
	var roundLabel:Label = get_node(_roundLabelPath)
	roundLabel.text = "Round %d/%d" % [_roundNumber + 1, _roundCount]
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
			AudioPlayer.playSound(_selectSound)

	yield(get_tree().create_timer(0.6), "timeout")
	AudioPlayer.playSound(_showSound)

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

	analytics.add_to_event_queue(analytics.get_progression_event("Complete:Minigame:Round%d" % (_roundNumber + 1), correctCount))
	if _roundNumber < _roundCount - 1:
		AudioPlayer.playSound(_confirmDown)
	else:
		AudioPlayer.playSound(_confirm)
	yield(ScreenTransitioner.transitionOut(1.0, ScreenTransitioner.DIAMONDS), "completed")
	var total1:int = SaveData.Get("minigame_score", 0)
	var total2:int = SaveData.Get("minigame_max_score", 0)
	total1 += correctCount
	total2 += _activeBubbleCount
	SaveData.Set("minigame_score", total1)
	SaveData.Set("minigame_max_score", total2)

	if _roundNumber < _roundCount - 1:
		_roundNumber += 1
		SaveData.Set("minigame_round", _roundNumber)
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
		var collisionShape:CircleShape2D = bubble.CollisionShape()
		query.set_shape(collisionShape)

		query.transform = Transform2D.IDENTITY.translated(Vector2(x, y))
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
	analytics.add_to_event_queue(analytics.get_progression_event("Fail:Minigame:Round%d" % (_roundNumber + 1)))
	_transitioning = true
	AudioPlayer.playSound(_confirmDown)
	yield(ScreenTransitioner.transitionOut(1.0, ScreenTransitioner.DIAMONDS), "completed")
	get_tree().change_scene("res://scenes/dummy-scene.tscn")
	#get_tree().change_scene("res://scenes/puzzle-play-scene.tscn")

func HelpButtonPressed() -> void:
	if _transitioning:
		return
	AudioPlayer.playSound(_popupSound)
	get_tree().paused = true
	var helpPopup:ColorRect = get_node(_helpPopupPath)
	helpPopup.visible = true
	yield(self, "_click")
	AudioPlayer.playSound(_popupSound)
	get_tree().paused = false
	helpPopup.visible = false
