extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var sprites
#var rng = RandomNumberGenerator.new()
var curr = 0
var n_times = get_parent().get_parent().n_times
var rand_array = get_parent().get_parent().rand_array
# Called when the node enters the scene tree for the first time.
func _ready():
	sprites = get_children()
	for i in range(len(sprites)):
		sprites[i].hide()
	#print(sprites)
	#self.hide()
	get_parent().get_node("TeaTimer").connect("timeout", self, "_if_timeout")
	#get_parent().get_node("TeaTimer").nsprites = len(sprites)
	
	
	#var sprites = get_children() # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _if_timeout():
	if curr == n_times:
		self.hide()
	else:
		#change scene
#self.hide()
		for i in range(len(sprites)):
			sprites[i].hide()	
		yield(self.get_tree().create_timer(.25,0), "timeout")
		#print(rand)
		#print(sprites[rand])
		sprites[rand_array[curr]].show()
		print(sprites[rand_array[curr]].get_global_position()) 
		if curr == n_times:
			get_parent().get_node("TeaTimer").stop()
			#change scene
		curr += 1