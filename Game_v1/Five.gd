extends Sprite

func _ready():
	hide()
	pass 
	
var x = 4
var y = 10
var num = 5
	
func _process(delta):
	if Input.is_action_pressed("ui_left"):
		_disappear(x,y)
	pass

func _appear(x,y):
	show()

func _disappear(x,y):
	hide()
	
func _trans(x,y):
	pass

func my_signal(x):
	pass

func _on_Timer_my_signal(x):
	if x == num:
		show() 
	else:
		hide()