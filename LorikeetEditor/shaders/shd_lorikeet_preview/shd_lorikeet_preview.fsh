varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D samp_Palette;
uniform vec4 u_TextureBounds;
uniform float u_PaletteSlot;
uniform float u_PaletteSlotCount;

uniform float u_AlphaTest;
uniform float u_AlphaTestRef;

uniform float u_IndexUnderCursor;
uniform float u_IndexCount;

float dither2x2(vec2 position) {
    int x = int(min(mod(position.x, 6.0), 2.0));
    int y = int(min(mod(position.y, 6.0), 2.0));
    int index = x + y * 2;
    float limit = 0.0;
    
    if (x < 8) {
        if (index == 0) limit = 0.25;
        if (index == 1) limit = 0.75;
        if (index == 2) limit = 1.00;
        if (index == 3) limit = 0.50;
    }
    
    return limit;
}

vec4 GetColor(vec4 data) {
    // this would be easier with texture filtering enabled, but i only want
    // it on the vertical axis, horizontal filtering would make a mess
    vec2 uv1 = u_TextureBounds.xy + vec2(data.r, mod(floor(u_PaletteSlot), u_PaletteSlotCount) / u_PaletteSlotCount) * (u_TextureBounds.zw - u_TextureBounds.xy);
    vec2 uv2 = u_TextureBounds.xy + vec2(data.r, mod(ceil(u_PaletteSlot), u_PaletteSlotCount) / u_PaletteSlotCount) * (u_TextureBounds.zw - u_TextureBounds.xy);
    vec4 c1 = texture2D(samp_Palette, uv1);
    vec4 c2 = texture2D(samp_Palette, uv2);
    
    if (abs(data.r * u_IndexCount - u_IndexUnderCursor) < 0.5) {
        float d = dither2x2(gl_FragCoord.xy);
        c1 = mix(c1, 1.0 - c1, d);
        c2 = mix(c2, 1.0 - c2, d);
    }
    
    vec4 sampled = mix(c1, c2, fract(u_PaletteSlot));
    sampled.a *= data.a;
    return sampled;
}

void main() {
    gl_FragColor = v_vColour * GetColor(texture2D(gm_BaseTexture, v_vTexcoord));
    if (u_AlphaTest != 0.0) if (gl_FragColor.a < u_AlphaTestRef) discard;
}