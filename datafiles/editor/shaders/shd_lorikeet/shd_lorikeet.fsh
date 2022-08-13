varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D samp_Palette;
uniform vec4 u_TextureBounds;
uniform float u_PaletteSlot;
uniform float u_PaletteSlotCount;

uniform float u_AlphaTest;
uniform float u_AlphaTestRef;

vec4 GetColor(vec4 data) {
    // this would be easier with texture filtering enabled, but i only want
    // it on the vertical axis, horizontal filtering would make a mess
    vec2 uv1 = u_TextureBounds.xy + vec2(data.r, mod(floor(u_PaletteSlot), u_PaletteSlotCount) / u_PaletteSlotCount) * (u_TextureBounds.zw - u_TextureBounds.xy);
    vec2 uv2 = u_TextureBounds.xy + vec2(data.r, mod(ceil(u_PaletteSlot), u_PaletteSlotCount) / u_PaletteSlotCount) * (u_TextureBounds.zw - u_TextureBounds.xy);
    vec4 c1 = texture2D(samp_Palette, uv1);
    vec4 c2 = texture2D(samp_Palette, uv2);
    return vec4(mix(c1, c2, fract(u_PaletteSlot)).rgb, data.a);
}

void main() {
    gl_FragColor = v_vColour * GetColor(texture2D(gm_BaseTexture, v_vTexcoord));
    if (u_AlphaTest != 0.0) if (gl_FragColor.a < u_AlphaTestRef) discard;
}