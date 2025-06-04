varying vec2 v_vTexcoord;

uniform float u_outline_value;
uniform float u_alpha_cutoff;
uniform float u_use_diagonals;

void main() {
    vec2 duv = vec2(
        dFdx(v_vTexcoord.x),
        dFdy(v_vTexcoord.y)
    );
    
    gl_FragColor = texture2D(gm_BaseTexture, v_vTexcoord);
    
    if (gl_FragColor.a <= u_alpha_cutoff) {
        float adjacent_alpha = 0.0;
        // there's probably a way to optimize this slightly using dfdx dfdy
        if (u_use_diagonals > 0.5) {
            adjacent_alpha =
                texture2D(gm_BaseTexture, v_vTexcoord + vec2(-duv.x, -duv.y)).a +
                texture2D(gm_BaseTexture, v_vTexcoord + vec2(-duv.x,  duv.y)).a +
                texture2D(gm_BaseTexture, v_vTexcoord + vec2( duv.x, -duv.y)).a +
                texture2D(gm_BaseTexture, v_vTexcoord + vec2( duv.x,  duv.y)).a +
                
                texture2D(gm_BaseTexture, v_vTexcoord - vec2(duv.x, 0)).a +
                texture2D(gm_BaseTexture, v_vTexcoord + vec2(duv.x, 0)).a +
                texture2D(gm_BaseTexture, v_vTexcoord - vec2(0, duv.y)).a +
                texture2D(gm_BaseTexture, v_vTexcoord + vec2(0, duv.y)).a;
        } else {
            adjacent_alpha =
                texture2D(gm_BaseTexture, v_vTexcoord - vec2(duv.x, 0)).a +
                texture2D(gm_BaseTexture, v_vTexcoord + vec2(duv.x, 0)).a +
                texture2D(gm_BaseTexture, v_vTexcoord - vec2(0, duv.y)).a +
                texture2D(gm_BaseTexture, v_vTexcoord + vec2(0, duv.y)).a;
        }
        
        if (adjacent_alpha > u_alpha_cutoff) {
            gl_FragColor = vec4(u_outline_value, u_outline_value, u_outline_value, 1);
        }
    }
}