extends Area2D

class_name PuzzlePiece

func Init(image:Texture, mask:Texture, size:Vector2, position:Vector2):
	var sprite:Sprite = $Sprite
	sprite.texture = image
	sprite.material = sprite.material.duplicate(true)
	var material:ShaderMaterial = sprite.material
	material.set_shader_param("maskTexture", mask)
	var collision:CollisionShape2D = $CollisionShape2D
	var rect:RectangleShape2D = RectangleShape2D.new()
	rect.extents = size * 0.5
	collision.shape = rect
	collision.position = position + rect.extents
