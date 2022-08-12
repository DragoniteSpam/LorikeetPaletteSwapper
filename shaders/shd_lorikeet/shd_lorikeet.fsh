varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D samp_Palette;
uniform vec4 u_TextureBounds;
uniform float u_PaletteSlot;

uniform float u_AlphaTest;
uniform float u_AlphaTestRef;

vec4 GetColor(vec4 data) {
    vec2 uv = u_TextureBounds.xy + vec2(min(data.x + 0.0002, 1.0), u_PaletteSlot) * (u_TextureBounds.zw - u_TextureBounds.xy);
    return vec4(texture2D(samp_Palette, uv).rgb, data.a);
}

void main() {
    gl_FragColor = v_vColour * GetColor(texture2D(gm_BaseTexture, v_vTexcoord));
    
    if (u_AlphaTest != 0.0) if (gl_FragColor.a < u_AlphaTestRef) discard;
}