extends Node2D

var sprites # array of cups
var curr = 0 # current round
var n_times = global.n_times 
var rand_array = global.rand_array
var n = global.N
var correct = rand_array[n_times-n-1] # the correct cup for this game
var cups

# Set up cups array and timer
func _ready():
	sprites = get_children()
	for i in range(len(sprites)):
		sprites[i].hide()
		for node in sprites[i].get_children():
			if node.get_class() == "Button":
				node.add_to_group("cups",true)
				
	get_parent().get_node("TeaTimer").connect("timeout", self, "_if_timeout")
	
	cups = get_tree().get_nodes_in_group("cups")
	#for button in cups:
		#button.connect("pressed",self, "_on_any_button",[button])

# Game logic: show random cups until rounds are complete
# Then show all cups for user to choose
func _if_timeout():
	if curr == n_times: # all rounds finished
		get_parent().get_node("TeaTimer").stop()
		var n_backs = get_parent().get_node("n-backs").get_children()
		
		n_backs[n-1].show()
		
		for i in range(len(sprites)):
			sprites[i].visible = true
	else: # keep showing cups for each round
		for i in range(len(sprites)):
			sprites[i].hide()	
		yield(self.get_tree().create_timer(.25,0), "timeout")
		
		sprites[rand_array[curr]].show()
		print(sprites[rand_array[curr]].get_global_position()) 
		
		curr += 1 # next round

# Bad style lol
func _on_Button1_pressed():
	_on_any_button(0)

func _on_Button2_pressed():
	_on_any_button(1)

func _on_Button3_pressed():
	_on_any_button(2)

func _on_Button4_pressed():
	_on_any_button(3)

func _on_Button5_pressed():
	_on_any_button(4)

func _on_Button6_pressed():
	_on_any_button(5)
	
func _on_any_button(button):
	var number = button
	print("press " + str(number))
	if correct != number:
		print(correct)
		print("incorrect")
		global.coins = 0
	else:
		global.coins = 100
	global.total_coins += global.coins
	get_tree().change_scene("res://N-Back-1/reward.tscn")