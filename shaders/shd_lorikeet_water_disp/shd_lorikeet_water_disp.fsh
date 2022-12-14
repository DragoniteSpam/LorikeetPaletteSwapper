varying vec2 v_vTexcoord;

#region Copy everything in this region if you want to bring it into another shader
uniform sampler2D samp_lorikeet_Palette;
uniform vec4 u_lorikeet_TextureBounds;
uniform float u_lorikeet_PaletteSlot;
uniform vec2 u_lorikeet_PaletteSize;

uniform float u_lorikeet_AlphaTest;
uniform float u_lorikeet_AlphaTestRef;

vec4 GetLorikeetColor(vec4 data) {
    // this would be easier with texture filtering enabled, but i only want
    // it on the vertical axis, horizontal filtering would make a mess
    vec2 textureBoundsBase = u_lorikeet_TextureBounds.xy;
    vec2 textureBoundsExtends = u_lorikeet_TextureBounds.zw;
    
    float h = (floor(data.r * u_lorikeet_PaletteSize.x) + 0.5) / u_lorikeet_PaletteSize.x;
    vec2 uv = textureBoundsBase + vec2(h, clamp(u_lorikeet_PaletteSlot, 0.0, u_lorikeet_PaletteSize.y) / u_lorikeet_PaletteSize.y) * (textureBoundsExtends - textureBoundsBase);
    return vec4(texture2D(samp_lorikeet_Palette, uv).rgb, data.a);
}
#endregion

uniform sampler2D samp_Displace;
uniform float u_Time;

varying vec2 v_vWorldPosition;

void main() {
    vec4 displace = texture2D(samp_Displace, v_vTexcoord + u_Time * (2.5 + vec2(sin(v_vWorldPosition.x), 1.125 * sin(v_vWorldPosition.y + 0.175))));
    vec2 offset = vec2(displace.rg * 2.0 - 1.0) / 8.0;
    
    gl_FragColor = GetLorikeetColor(texture2D(gm_BaseTexture, v_vTexcoord + offset - u_Time));
    if (u_lorikeet_AlphaTest != 0.0) if (gl_FragColor.a < u_lorikeet_AlphaTestRef) discard;
}