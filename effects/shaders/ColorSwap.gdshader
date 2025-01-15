shader_type canvas_item;

uniform vec4 target_color_1: source_color = vec4(0.12, 0.11, 0.15, 1.0);
uniform vec4 target_color_2: source_color = vec4(.61, .71, .72, 1.0);
uniform vec4 target_color_3: source_color = vec4(.91, .92, .92, 1.0);
uniform vec4 target_color_4: source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform vec4 replace_color_1 : source_color;
uniform vec4 replace_color_2 : source_color;
uniform vec4 replace_color_3 : source_color;
uniform vec4 replace_color_4 : source_color;

uniform float tolerance : hint_range(0, 1) = .02;

void fragment()
{
    vec4 tex_color = texture(TEXTURE, UV);
    
    float dist1 = distance(tex_color.rgb, target_color_1.rgb);
    if (dist1 < tolerance)
    {
        tex_color.rgb = replace_color_1.rgb;
    }
    float dist2 = distance(tex_color.rgb, target_color_2.rgb);
    if (dist2 < tolerance)
    {
        tex_color.rgb = replace_color_2.rgb;
    }
    float dist3 = distance(tex_color.rgb, target_color_3.rgb);
    if (dist3 < tolerance)
    {
        tex_color.rgb = replace_color_3.rgb;
    }
    float dist4 = distance(tex_color.rgb, target_color_4.rgb);
    if (dist4 < tolerance)
    {
        tex_color.rgb = replace_color_4.rgb;
    }
    
    COLOR = tex_color;
}

