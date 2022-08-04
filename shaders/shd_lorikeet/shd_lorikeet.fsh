varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D samp_Palette;
uniform float u_PaletteSlot;

vec4 GetColor(vec4 data) {
    return vec4(texture2D(samp_Palette, vec2(min(data.r + 0.0002, 1.0), u_PaletteSlot)).rgb, data.a);
}

void main() {
    gl_FragColor = v_vColour * GetColor(texture2D(gm_BaseTexture, v_vTexcoord));
}