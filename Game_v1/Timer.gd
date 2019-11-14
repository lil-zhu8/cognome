extends Timer

signal my_signal

func _ready():
	connect("timeout",self,"sendNumber")
	randomize()
	 # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func sendNumber():
	var r = randi()%6+1
	emit_signal("my_signal", r)
	print(r)