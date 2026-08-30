shader_type canvas_item;

uniform vec4 track_color : source_color = vec4(0.3, 0.7, 1.0, 1.0);

uniform float center_transparency : hint_range(0.0, 1.0) = 0.9;
uniform float edge_width : hint_range(0.01, 0.5) = 0.2;
uniform float glow_strength : hint_range(0.0, 10.0) = 3.0;

uniform float end_thinness : hint_range(0.01, 0.5) = 0.15;

uniform float wave_count : hint_range(1.0, 50.0) = 10.0;
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.0;

void fragment() {

	// Distance from center of track
	float width = abs(UV.y - 0.5) * 2.0;

	// Brightness toward the sides
	float edge = smoothstep(
		1.0 - edge_width,
		1.0,
		width
	);

	// Transparency toward the center
	float center_fade = smoothstep(
		0.0,
		0.7,
		width
	);

	float alpha = mix(
		1.0 - center_transparency,
		1.0,
		center_fade
	);

	// Side glow
	float glow = pow(edge, 2.0);

	// Wave travels along the LENGTH of the track
	float wave = sin(
		UV.x * wave_count * 6.28318
		- TIME * pulse_speed
	);

	wave = wave * 0.5 + 0.5;

	// Start/end taper
	float start_fade = smoothstep(
		0.0,
		end_thinness,
		UV.x
	);

	float end_fade = smoothstep(
		0.0,
		end_thinness,
		1.0 - UV.x
	);

	float end_mask = start_fade * end_fade;

	// Apply taper
	alpha *= end_mask;

	// Color
	vec3 color = track_color.rgb;

	color += track_color.rgb * glow * glow_strength;

	// Subtle moving wave
	color += track_color.rgb * wave * 0.15;

	COLOR = vec4(color, alpha);
}