varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D samp_Palette;
uniform vec4 u_TextureBounds;
uniform float u_PaletteSlot;
uniform float u_PaletteSlotCount;

uniform float u_AlphaTest;
uniform float u_AlphaTestRef;

uniform sampler2D samp_Displace;
uniform float u_Time;

varying vec2 v_vWorldPosition;

vec4 GetColor(vec4 data) {
    // this would be easier with texture filtering enabled, but i only want
    // it on the vertical axis, horizontal filtering would make a mess
    vec2 uv1 = u_TextureBounds.xy + vec2(data.r, floor(u_PaletteSlot) / u_PaletteSlotCount) * (u_TextureBounds.zw - u_TextureBounds.xy);
    vec2 uv2 = u_TextureBounds.xy + vec2(data.r, ceil(u_PaletteSlot) / u_PaletteSlotCount) * (u_TextureBounds.zw - u_TextureBounds.xy);
    vec4 c1 = texture2D(samp_Palette, uv1);
    vec4 c2 = texture2D(samp_Palette, uv2);
    return vec4(mix(c1, c2, fract(u_PaletteSlot)).rgb, data.a);
}

void main() {
    vec4 displace = texture2D(samp_Displace, v_vTexcoord + u_Time * (2.5 + vec2(sin(v_vWorldPosition.x), 1.125 * sin(v_vWorldPosition.y + 0.175))));
    vec2 offset = vec2(displace.rg * 2.0 - 1.0) / 12.0;
    
    gl_FragColor = v_vColour * GetColor(texture2D(gm_BaseTexture, v_vTexcoord + offset - u_Time));
}