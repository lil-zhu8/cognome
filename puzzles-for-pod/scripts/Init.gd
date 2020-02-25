extends Node

func _ready() -> void:
	randomize()
	ScreenTransitioner.setParams({"diamondPixelSize": 50})
