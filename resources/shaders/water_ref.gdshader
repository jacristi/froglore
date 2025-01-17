shader_type canvas_item;

//add a color picker to inspector
uniform vec4 CAST_COLOR : source_color;

//get the underlying screen texture
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

//add a noise resource to inspector (for fast noise)
uniform sampler2D fast_noise : filter_nearest, repeat_enable;

//speed at which waves move
uniform vec2 speed = vec2(0.02, 0.07);

//strength of waves
uniform float wave_strength = 0;

//scale and zoom parameters for when editor changes (set from script)
uniform float scale_y;
uniform float y_zoom;

void vertex() {
    //move water up and down
    // VERTEX.y += sin(TIME) * 1.0;
}

void fragment() {
    //get ripple noise
    vec4 tex_color = texture(TEXTURE, UV);
    vec2 uv = UV + speed * TIME;

    //get the noise from fast noise
    vec2 noise = texture(fast_noise, uv).rg;

    //get size of object shader is on
    float uv_height = (SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y);

    //calc where reflection is coming from
    vec2 reflected_uv = vec2(SCREEN_UV.x, SCREEN_UV.y - (uv_height * UV.y * scale_y * y_zoom));

    //get reflection pixel
    vec4 reflection = texture(SCREEN_TEXTURE, reflected_uv);

    vec4 waves = texture(SCREEN_TEXTURE, reflected_uv + noise * y_zoom * (wave_strength / 100.0));

    // Only apply wave ripples and selected color to transparent pixels
    if (tex_color.a != 0.0)
        COLOR = waves + vec4(tex_color.r, tex_color.g, tex_color.b, tex_color.a) ;
    else
        COLOR = waves + CAST_COLOR ;

}