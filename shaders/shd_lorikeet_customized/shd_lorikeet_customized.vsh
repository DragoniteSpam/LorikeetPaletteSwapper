attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexcoord;

void main() {
    float height = in_Colour.r * 255.0;
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x, in_Position.yz + height, 1);
    v_vTexcoord = in_TextureCoord;
}