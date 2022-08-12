shader_type canvas_item;

uniform sampler2D noisetex;

void fragment() {
	COLOR = texture(TEXTURE, UV);
//	load noise
	vec4 noisecolor = texture(noisetex, UV + vec2(0,0.06*TIME));
//	intensify noise
	
	noisecolor.r = pow(noisecolor.b * 2.0,2.0);
	noisecolor.g = pow(noisecolor.b * 1.6,2.0);
	noisecolor.b = pow(noisecolor.b * 1.2,1.4);
	noisecolor *= 1.5;
//	pegtop's branchless soft light formula for every color
	COLOR.r = (1.0 - 2.0 * noisecolor.r) * pow(COLOR.r, 2) + (1.6 * COLOR.r * noisecolor.r);
	COLOR.g = (1.0 - 2.0 * noisecolor.g) * pow(COLOR.g, 2) + (1.6 * COLOR.g * noisecolor.g);
	COLOR.b = (1.0 - 2.0 * noisecolor.b) * pow(COLOR.b, 2) + (1.6 * COLOR.b * noisecolor.b);
	}
	