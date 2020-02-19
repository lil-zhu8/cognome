extends Node

# Global variables to keep track of across the entire game

# Variable declarations
var rand_array = [] # array of positions to display
var rng = RandomNumberGenerator.new()
var n_times = 5 # number of times a cup appears
var len_sprites = 6 # length of sprite array
var N = rng.randi_range(1, n_times - 1) # how many N back
var coins = 0 # coins earned per turn
var total_coins = 0 # total coins player has earned

# var len_sprites = len($World.get_node("Sprite Array").sprites) - 1

var positions #fill in later????
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	for i in range(n_times):
		rand_array.append(rng.randi_range(0, len_sprites - 1)) # randomly generate positions
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
