extends TextureRect

class_name PuzzlePiece

signal GuiInput

func Init(image:Texture, mask:Texture, size:Vector2, position:Vector2):
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
