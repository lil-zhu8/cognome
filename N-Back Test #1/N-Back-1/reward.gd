extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_replay_pressed():
	get_tree().change_scene("res://N-Back-1/begin.tscn")


func _on_Label_draw():
	$end/Label.set_text("You have earned %d" %[global.coins])
