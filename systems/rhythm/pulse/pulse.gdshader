shader_type canvas_item;

uniform vec4 pulse_color : source_color = vec4(0.3, 0.7, 1.0, 1.0);

uniform float core_size : hint_range(0.01, 0.5) = 0.12;
uniform float glow_size : hint_range(0.01, 0.5) = 0.25;
uniform float trail_length : hint_range(0.01, 1.0) = 0.4;
uniform float trail_width : hint_range(0.01, 0.5) = 0.18;
uniform float glow_strength : hint_range(0.0, 10.0) = 2.0;

void fragment() {

	vec2 p = UV - vec2(0.5);

	float dist = length(p);

	float core = 1.0 - smoothstep(
		0.0,
		core_size,
		dist
	);

	float glow = 1.0 - smoothstep(
		core_size,
		glow_size,
		dist
	);

	float behind = p.x;

	float trail_length_mask = 1.0  + smoothstep(
		0.0,
		trail_length,
		behind
	);

	float trail_width_mask = exp(
		-pow(p.y / trail_width, 2.0)
	);

	float direction = step(0.0, behind);

	float trail = trail_length_mask
		* trail_width_mask
		* direction;

	trail *= 1.0 - smoothstep(
		0.0,
		trail_length,
		behind
	);

	float brightness =
		core * 2.0 +
		glow * glow_strength +
		trail * glow_strength;

	float alpha =
		max(
			core,
			max(
				glow * 0.5,
				trail
			)
		);

	// Remove extremely faint pixels
	if (alpha < 0.02) {
		discard;
	}

	vec3 color = pulse_color.rgb * brightness;

	COLOR = vec4(color, alpha);
}