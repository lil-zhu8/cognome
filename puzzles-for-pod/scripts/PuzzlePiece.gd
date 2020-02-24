extends TextureRect

class_name PuzzlePiece

signal GuiInput

var _locked:bool = false
var _available:bool = false

func Snap() -> void:
	set_position(Vector2.ZERO)
	_locked = true
	get_parent().move_child(self, 0)

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
	return result

func Load(data:Dictionary) -> void:
	if !data.has_all(["position_x", "position_y", "locked", "available"]):
		return
	set_position(Vector2(data.position_x, data.position_y))
	_available = data.available
	visible = _available
	_locked = data.locked
	if _locked:
		Snap()

func PlaceRandomly(rect:Rect2) -> void:
	var collision:Control = $Collision

	rect.end.x -= collision.get_global_transform().get_scale().x * collision.get_size().x
	rect.end.y -= collision.get_global_transform().get_scale().y * collision.get_size().y
	var x:float = rand_range(rect.position.x, rect.end.x)
	var y:float = rand_range(rect.position.y, rect.end.y)

	set_global_position(
		get_global_transform().xform(-collision.get_position()) + Vector2(x, y) - get_global_position()
	)

func Init(image:Texture, mask:Texture, size:Vector2, position:Vector2) -> void:
	texture = image
	set_size(image.get_size())
	material = material.duplicate(true)
	var shaderMaterial:ShaderMaterial = material
	shaderMaterial.set_shader_param("maskTexture", mask)
	var collision:Control = $Collision
	collision.set_size(size)
	collision.set_position(position)
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
