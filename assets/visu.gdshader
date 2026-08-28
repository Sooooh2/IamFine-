shader_type canvas_item;

uniform sampler2D screen_texture :
    hint_screen_texture,
    repeat_disable,
    filter_nearest;

uniform float pixel_size = 3.0;


void fragment() {

    vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;

    vec2 pixel_uv =
        floor(UV * resolution / pixel_size)
        * pixel_size / resolution;

    vec4 color =
        texture(screen_texture, pixel_uv);

    COLOR = color;
}