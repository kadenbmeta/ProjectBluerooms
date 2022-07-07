shader_type canvas_item;

uniform float size_x = 0.008;
uniform float size_y = 0.008;

void fragment() {
	vec2 target = SCREEN_UV;
	target -= mod(target, vec2(size_x, size_y));
	COLOR.rgb = textureLod(SCREEN_TEXTURE, target, 0.0).rgb;
}
