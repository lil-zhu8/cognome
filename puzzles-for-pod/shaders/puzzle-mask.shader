shader_type canvas_item;

uniform sampler2D maskTexture;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    vec4 maskColor = texture(maskTexture, UV);

	color.a = maskColor.r;

    // Assign the color to the output
    COLOR = color;
}