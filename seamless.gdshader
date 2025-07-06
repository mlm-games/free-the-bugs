shader_type canvas_item;

uniform float speed = 0.05;
uniform float alpha = 1.0;
uniform vec4 tint_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float wave_amplitude = 0.01;
uniform float wave_frequency = 5.0;
uniform vec2 direction = vec2(1.0, 1.0);
uniform bool pixel_snap = false;
uniform float brightness = 1.0;

void fragment() {
    // Normalize direction vector
    vec2 norm_direction = normalize(direction);

    vec2 wave_offset = vec2(
        sin(TIME * wave_frequency + UV.y * 10.0) * wave_amplitude,
        cos(TIME * wave_frequency + UV.x * 10.0) * wave_amplitude
    );

    // Calculate new UV with directional movement and wave
    vec2 new_uv = UV + TIME * speed * norm_direction + wave_offset;

    //if (pixel_snap) {
        //new_uv = floor(new_uv * 64.0) / 64.0;
    //}

    vec4 color = texture(TEXTURE, new_uv);

    color.rgb *= tint_color.rgb * brightness;

    color.a *= alpha * tint_color.a;

    COLOR = color;
}