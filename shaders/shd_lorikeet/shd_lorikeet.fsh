varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D samp_Palette;
uniform float u_PaletteSlot;

vec4 GetColor(vec4 data) {
    return vec4(texture2D(samp_Palette, vec2(max(data.r - 0.001, 0.0), u_PaletteSlot)).rgb, data.a);
}

void main() {
    gl_FragColor = v_vColour * GetColor(texture2D(gm_BaseTexture, v_vTexcoord));
}