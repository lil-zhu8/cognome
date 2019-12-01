extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rand_array = []
var rng = RandomNumberGenerator.new()
var n_times = 5
var N = rng.randi_range(1, n_times)
var coins = 0

# var len_sprites = len($World.get_node("Sprite Array").sprites) - 1
var len_sprites = 5
var positions #fill in later????
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	for i in range(n_times):
		#r = rng.randi_range(0, len(sprites) - 1)
		rand_array.append(rng.randi_range(0, len_sprites))
		
	#pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
