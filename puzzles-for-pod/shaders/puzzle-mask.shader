shader_type canvas_item;

uniform sampler2D maskTexture;
uniform float size = 0.004;
uniform float glow = 0.0;

void fragment() {
	if (size <= 0.0) {
	    vec4 colorb = texture(TEXTURE, UV);
    	float maskValb = texture(maskTexture, UV).r;
		colorb.a = maskValb;
		COLOR = colorb;
	} else {
	    vec4 color = texture(TEXTURE, UV);
		
		
		
		
		
	    float maskVal = texture(maskTexture, UV).r;
	    float maskVal1 = texture(maskTexture, UV + vec2(size, 0.0)).r;
	    float maskVal2 = texture(maskTexture, UV + vec2(-size, 0.0)).r;
	    float maskVal3 = texture(maskTexture, UV + vec2(0.0, size)).r;
	    float maskVal4 = texture(maskTexture, UV + vec2(0.0, -size)).r;
	    float maskVal5 = texture(maskTexture, UV + vec2(size, size)).r;
	    float maskVal6 = texture(maskTexture, UV + vec2(-size, -size)).r;
	    float maskVal7 = texture(maskTexture, UV + vec2(size, size)).r;
	    float maskVal8 = texture(maskTexture, UV + vec2(-size, -size)).r;
		float outline = maskVal1 + maskVal2 + maskVal3 + maskVal4 + maskVal5 + maskVal6 + maskVal7 + maskVal8;
	
		vec4 outlineColor = vec4(0.0, 0.0, 0.0, 1.0);
		
		float lerp = clamp(outline * 0.125, 0.0, 1.0);
	
	
		color = mix(color, outlineColor, pow(1.0 - lerp, 0.75));
		color.a = maskVal;
		
		// Assign the color to the output
		
		vec4 newcol = vec4(0.0, 0.0, 0.0, 0.0);
		newcol += texture(TEXTURE, UV + vec2(size, 0.0));
	    newcol += texture(TEXTURE, UV + vec2(-size, 0.0));
	    newcol += texture(TEXTURE, UV + vec2(0.0, size));
	    newcol += texture(TEXTURE, UV + vec2(0.0, -size));
	    newcol += texture(TEXTURE, UV + vec2(size, size));
	    newcol += texture(TEXTURE, UV + vec2(-size, -size));
	    newcol += texture(TEXTURE, UV + vec2(size, size));
	    newcol += texture(TEXTURE, UV + vec2(-size, -size));

/*
	    float bmaskVal = texture(maskTexture, UV).r;
	    float bmaskVal1 = texture(maskTexture, UV + vec2(size*2.0, 0.0)).r;
	    float bmaskVal2 = texture(maskTexture, UV + vec2(-size*2.0, 0.0)).r;
	    float bmaskVal3 = texture(maskTexture, UV + vec2(0.0, size*2.0)).r;
	    float bmaskVal4 = texture(maskTexture, UV + vec2(0.0, -size*2.0)).r;
	    float bmaskVal5 = texture(maskTexture, UV + vec2(size*2.0, size*2.0)).r;
	    float bmaskVal6 = texture(maskTexture, UV + vec2(-size*2.0, -size*2.0)).r;
	    float bmaskVal7 = texture(maskTexture, UV + vec2(size*2.0, size*2.0)).r;
	    float bmaskVal8 = texture(maskTexture, UV + vec2(-size*2.0, -size*2.0)).r;
		float boutline = bmaskVal1 + bmaskVal2 + bmaskVal3 + bmaskVal4 + bmaskVal5 + bmaskVal6 + bmaskVal7 + bmaskVal8;
*/
		
		newcol = newcol * 0.25;
		// newcol.a = boutline;
		newcol.a = maskVal;
		color = mix(color, newcol, glow);
		
		
		
		
		
		COLOR = color;
	    // COLOR = vec4(color.rgb, clamp(abs(-8.0 * maskVal + outline) + maskVal, 0.0, 1.0));
	}
}