shader_type canvas_item;

uniform vec2 scale;
uniform float y_zoom;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

uniform vec4 water_color: source_color;
uniform vec2 distortion_scale;
uniform float intensity;
uniform sampler2D noise: filter_nearest, repeat_enable;
uniform float speed;

uniform float wave_amplitude;
uniform float wave_speed;
uniform float wave_period;


void fragment()
{
    float waves = UV.y * scale.y + sin(UV.x * scale.x / wave_period - TIME*wave_speed) * cos(0.2 * UV.x * scale.x / wave_period + TIME-wave_speed) * wave_amplitude - wave_amplitude;

    float distortion = texture(noise, UV * scale * distortion_scale + TIME*speed).x;
    distortion -= 0.5;

    float uv_height = SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y;
    //vec2 reflected_screenuv = vec2(SCREEN_UV.x - distortion * intensity, SCREEN_UV.y - uv_height * UV.y * scale.y * y_zoom * 2.0);
    vec2 reflected_screenuv = vec2(SCREEN_UV.x - (distortion * intensity * y_zoom), SCREEN_UV.y - uv_height * UV.y * y_zoom * scale.y * 2.0);

    vec4 relfection = texture(SCREEN_TEXTURE, reflected_screenuv);

    COLOR.rgb = mix(relfection.rgb, water_color.rgb, water_color.a);
    COLOR.a = smoothstep(.01, 0.05, waves);

}


void vertex() {

}
