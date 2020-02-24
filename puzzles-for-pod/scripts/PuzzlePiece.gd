extends TextureRect

class_name PuzzlePiece

signal GuiInput

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

func OnGuiInput(event:InputEvent) -> void:
	emit_signal("GuiInput", event)
