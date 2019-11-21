extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rand_array 
var rng = RandomNumberGenerator.new()
var N = 2
var n_times = 5
var len_sprites
var positions #fill in later????
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	for i in range(n_times):
		#r = rng.randi_range(0, len(sprites) - 1)
		rand_array.append(rng.randi_range(0, len($World.get_node("Sprite Array").sprites) - 1))
		
	#pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
