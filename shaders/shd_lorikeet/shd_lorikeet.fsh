varying vec2 v_vTexcoord;
varying vec4 v_vColour;

vec4 GetColor(vec2 data) {
    return vec4(1);
}

void main() {
    vec4 palette_lookup = texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor = v_vColour * GetColor(palette_lookup.rg);
}
