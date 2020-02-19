extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Change to play scene when ready!
func _on_play_button_pressed():
	get_tree().change_scene("res://N-Back-1/sprites.tscn")
