extends RigidBody2D

class_name Bubble

func _ready() -> void:
	modulate = Color(1, 1, 1, 0)
	var tween:Tween = Tween.new()
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	add_child(tween)
	tween.start()

func CollisionShape() -> Shape2D:
	var collision:CollisionShape2D = $CollisionShape2D
	return collision.shape

func StartMotion(speed:float) -> void:
	var vel:Vector2 = Vector2.RIGHT * speed
	vel = vel.rotated(rand_range(0, 2 * PI))
	linear_velocity = vel

func StopMotion() -> void:
	linear_damp = 5

func Highlight() -> void:
	modulate = Color(0, 1, 0, 1)

func HighlightWrong() -> void:
	modulate = Color(1, 0, 0, 1)

func HighlightCorrect() -> void:
	var circle:Sprite = $Circle
	circle.visible = true
	get_parent().move_child(self, get_parent().get_child_count() - 1)
