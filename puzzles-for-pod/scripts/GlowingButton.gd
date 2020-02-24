extends Button

class_name GlowingButton

export var GlowColor:Color = Color.yellow
export var Enabled:bool = true
export var duration:float = 1.0

var _initialColor:Color

func _ready() -> void:
	_initialColor = modulate

func _process(_delta: float) -> void:
	if pressed || disabled || !Enabled:
		modulate = _initialColor
		return
	var l:float = sin(OS.get_ticks_msec() * .001 * 2 * PI / duration) * 0.5 + 0.5
	modulate = lerp(_initialColor, GlowColor, l)
