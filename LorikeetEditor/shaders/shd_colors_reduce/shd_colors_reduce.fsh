varying vec2 v_vTexcoord;

void main() {
    gl_FragColor = texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor.rgb *= 0.5;
}