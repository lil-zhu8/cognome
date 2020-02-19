extends Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# show instructions when user requests help
func _on_Help_pressed():
	self.visible = true

# close help screen when done
func _on_OK_pressed():
	self.visible = false
