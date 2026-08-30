shader_type canvas_item;

uniform vec4 particle_color : source_color = vec4(0.3, 0.7, 1.0, 1.0);
uniform float glow_strength : hint_range(0.0, 5.0) = 2.0;

void fragment() {
	float dist = distance(UV, vec2(0.5));

	float alpha = 1.0 - smoothstep(0.0, 0.5, dist);

	float glow = pow(alpha, 2.0);

	vec3 color = particle_color.rgb * (1.0 + glow * glow_strength);

	COLOR = vec4(color, alpha);
}