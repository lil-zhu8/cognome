extends CanvasLayer

var menuScene:PackedScene = preload("res://scenes/menu-scene.tscn")
var copyProtectScene:PackedScene = preload("res://scenes/copy-protect-scene.tscn")

func _ready() -> void:
	if SiteLockUrls.hasViolation():
		get_tree().change_scene_to(copyProtectScene)
		return

	randomize()
	ScreenTransitioner.instantOut()
	yield(ScreenTransitioner.transitionIn(1.0, ScreenTransitioner.DIAMONDS), "completed")
	yield(Yields.timeOrInputPressed(2, "ui_accept", get_tree()), "completed")
	yield(ScreenTransitioner.transitionOut(1.0, ScreenTransitioner.DIAMONDS), "completed")
	get_tree().change_scene_to(menuScene)
	yield(ScreenTransitioner.transitionIn(1.0, ScreenTransitioner.DIAMONDS), "completed")
