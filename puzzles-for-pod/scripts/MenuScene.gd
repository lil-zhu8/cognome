extends CanvasLayer

var mainScene:PackedScene = preload("res://scenes/main-scene.tscn")

func _ready() -> void:
	pass

func _process(delta) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		yield(ScreenTransitioner.transitionOut(1.0, ScreenTransitioner.DIAMONDS), "completed")
		get_tree().change_scene_to(mainScene)
		yield(ScreenTransitioner.transitionIn(1.0, ScreenTransitioner.DIAMONDS), "completed")
