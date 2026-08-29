shader_type canvas_item;

uniform vec4 track_color : source_color = vec4(0.15, 0.2, 0.3, 1.0);
uniform vec4 glow_color : source_color = vec4(0.3, 0.7, 1.0, 1.0);

uniform float glow_strength : hint_range(0.0, 5.0) = 1.5;
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.0;
uniform float end_thinness : hint_range(0.0, 1.0) = 0.75;
uniform float glare_strength : hint_range(0.0, 5.0) = 2.0;
uniform float glare_width : hint_range(0.01, 0.5) = 0.08;


void fragment() {

	float end_fade = smoothstep(
		0.0,
		end_thinness,
		UV.x
	) * smoothstep(
		0.0,
		end_thinness,
		1.0 - UV.x
	);

	float pulse = sin(UV.y * 5.0 - TIME * pulse_speed);
	pulse = pulse * 0.5 + 1.0;

	float glare_pos = fract(TIME * pulse_speed * 0.15);
	float glare = 1.0 - smoothstep(
		0.0,
		glare_width,
		abs(UV.y - glare_pos)
	);

	glare *= glare_strength;

	vec3 color = mix(
		track_color.rgb,
		glow_color.rgb,
		pulse * 0.25
	);

	color += glow_color.rgb * glare;

	color *= 1.0 + pulse * glow_strength * 0.2;

	COLOR = vec4(
		color,
		end_fade
	);
}