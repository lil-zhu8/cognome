extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var sprites
#var rng = RandomNumberGenerator.new()
var curr = 0
var n_times = global.n_times
var rand_array =global.rand_array
var rng = RandomNumberGenerator.new()
var n = rng.randi_range(0, 5)
var correct = rand_array[n]

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
		get_parent().get_node("TeaTimer").stop()
		var n_backs = get_parent().get_node("n-backs").get_children()
		
		n_backs[n].show()
		
		for i in range(len(sprites)):
			print(i)
			sprites[i].visible = true
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

func _on_Button1_pressed():
	print("press 1")
	if (5-n) != 0:
		print("incorrect")
	else:
		global.coins += 100;
	get_tree().change_scene("res://N-Back-1/reward.tscn")


func _on_Button2_pressed():
	print("press 2")
	if (5-n) != 1:
		print("incorrect")
	else:
		global.coins += 100;
	get_tree().change_scene("res://N-Back-1/reward.tscn")


func _on_Button3_pressed():
	print("press 3")
	if (5-n) != 2:
		print("incorrect")
	else:
		global.coins += 100;
	get_tree().change_scene("res://N-Back-1/reward.tscn")

func _on_Button4_pressed():
	print("press 4")
	if (5-n) != 3:
		print("incorrect")
	else:
		global.coins += 100;
	get_tree().change_scene("res://N-Back-1/reward.tscn")

func _on_Button5_pressed():
	print("press 5")
	if (5-n) != 4:
		print("incorrect")
	else:
		global.coins += 100;
	get_tree().change_scene("res://N-Back-1/reward.tscn")

func _on_Button6_pressed():
	print("press 6")
	if (5-n) != 5:
		print("incorrect")
	else:
		global.coins += 100;
	get_tree().change_scene("res://N-Back-1/reward.tscn")