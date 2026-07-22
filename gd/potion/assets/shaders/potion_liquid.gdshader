shader_type canvas_item;

uniform vec4 potion_color : source_color;
uniform float fill_level : hint_range(0.0, 1.0) = 0.5;
uniform float amplitude : hint_range(0.0, 0.1) = 0.02;
uniform float frequency : hint_range(0.0, 20.0) = 10.0;
uniform float speed : hint_range(0.0, 10.0) = 3.0;
uniform float pixel_size : hint_range(8.0, 256.0) = 32.0;

void fragment() {
    vec2 pixel_uv = floor(UV * pixel_size) / pixel_size;
    float current_y = 1.0 - pixel_uv.y;
    float wave = sin(pixel_uv.x * frequency + TIME * speed) * amplitude;
    
    if (current_y < (fill_level + wave) && length(pixel_uv - vec2(0.5)) < 0.6) {
        COLOR = potion_color;
    } else {
        COLOR = vec4(0.0);
    }
}