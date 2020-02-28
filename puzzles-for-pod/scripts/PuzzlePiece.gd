extends TextureRect

class_name PuzzlePiece

signal GuiInput

var _locked:bool = false
var _available:bool = false
var JustAvailable:bool = false
const SIZE_FACTOR:float = 1.5

func Snap(instant:bool) -> void:
	set_position(Vector2.ZERO)
	_locked = true
	get_parent().move_child(self, 0)
	var shaderMaterial:ShaderMaterial = material

	if instant:
		shaderMaterial.set_shader_param("size", 0.0)
		return

	var tween:Tween = Tween.new()
	tween.interpolate_property(shaderMaterial,
		"shader_param/glow",
		0, 1, 0.2,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	add_child(tween)
	tween.start()
	yield(tween, "tween_completed")

	var tweenb:Tween = Tween.new()
	var tweenc:Tween = Tween.new()

	tweenb.interpolate_property(shaderMaterial,
		"shader_param/glow",
		1, 0, 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tweenc.interpolate_property(shaderMaterial,
		"shader_param/size",
		0.004, 0, 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	add_child(tweenb)
	add_child(tweenc)
	tweenb.start()
	tweenc.start()

func IsLocked() -> bool:
	return _locked

func IsAvailable() -> bool:
	return _available

func MakeAvailable() -> void:
	_available = true
	visible = true

func Save() -> Dictionary:
	var result:Dictionary = {}
	result.position_x = get_position().x
	result.position_y = get_position().y
	result.locked = _locked
	result.available = _available
	result.just_available = false
	return result

func Load(data:Dictionary) -> void:
	if !data.has_all(["position_x", "position_y", "locked", "available", "just_available"]):
		return
	set_position(Vector2(data.position_x, data.position_y))
	_available = data.available
	visible = _available
	_locked = data.locked
	JustAvailable = data.just_available
	if _locked:
		Snap(true)

func PlaceRandomly(rect:Rect2) -> void:
	var collision:Control = $Collision

	rect.end.x -= collision.get_global_transform().get_scale().x * collision.get_size().x
	rect.end.y -= collision.get_global_transform().get_scale().y * collision.get_size().y
	var x:float = rand_range(rect.position.x, rect.end.x)
	var y:float = rand_range(rect.position.y, rect.end.y)

	set_global_position(
		get_global_transform().xform(-collision.get_position()) + Vector2(x, y) - get_global_position()
	)

func ZeroPositionCenterY() -> void:
	var collision:Control = $Collision
	var pos:Vector2 = -collision.get_position()
	#pos += Vector2.UP * collision.get_size().y * 0.5
	set_position(pos)

func Init(image:Texture, mask:Texture, size:Vector2, position:Vector2) -> void:
	texture = image
	set_size(image.get_size())
	material = material.duplicate(true)
	var shaderMaterial:ShaderMaterial = material
	shaderMaterial.set_shader_param("maskTexture", mask)
	var collision:Control = $Collision
	collision.set_position(position - Vector2(size.x * (SIZE_FACTOR - 1) * 0.5, size.y * (SIZE_FACTOR - 1) * 0.5))
	size *= SIZE_FACTOR
	collision.set_size(size)
	collision.connect("gui_input", self, "OnGuiInput")
	Reset()

func Reset() -> void:
	_available = false
	_locked = false
	visible = false

func OnGuiInput(event:InputEvent) -> void:
	if _locked:
		return

	emit_signal("GuiInput", event)
