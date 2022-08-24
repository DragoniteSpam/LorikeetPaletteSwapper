/*/
	This is a shader made for use with the sPart system.
	
	Sindre Hauge Larsen, 2019
	www.TheSnidr.com
/*/
varying vec2 v_vTexcoord;

#region Copy everything in this region if you want to bring it into another shader
uniform sampler2D samp_lorikeet_Palette;
uniform vec4 u_lorikeet_TextureBounds;
uniform float u_lorikeet_PaletteSlot;
uniform float u_lorikeet_PaletteSlotCount;

uniform float u_lorikeet_AlphaTest;
uniform float u_lorikeet_AlphaTestRef;

vec4 GetLorikeetColor(vec4 data) {
    // this would be easier with texture filtering enabled, but i only want
    // it on the vertical axis, horizontal filtering would make a mess
    vec2 textureBoundsBase = u_lorikeet_TextureBounds.xy;
    vec2 textureBoundsExtends = u_lorikeet_TextureBounds.zw;
    vec2 uv1 = textureBoundsBase + vec2(data.r, mod(floor(u_lorikeet_PaletteSlot), u_lorikeet_PaletteSlotCount) / u_lorikeet_PaletteSlotCount) * (textureBoundsExtends - textureBoundsBase);
    vec2 uv2 = textureBoundsBase + vec2(data.r, mod(ceil(u_lorikeet_PaletteSlot), u_lorikeet_PaletteSlotCount) / u_lorikeet_PaletteSlotCount) * (textureBoundsExtends - textureBoundsBase);
    vec4 c1 = texture2D(samp_lorikeet_Palette, uv1);
    vec4 c2 = texture2D(samp_lorikeet_Palette, uv2);
    return vec4(mix(c1, c2, fract(u_lorikeet_PaletteSlot)).rgb, data.a);
}
#endregion

void main() {
    gl_FragColor = GetLorikeetColor(texture2D(gm_BaseTexture, v_vTexcoord));
    if (u_lorikeet_AlphaTest != 0.0) if (gl_FragColor.a < u_lorikeet_AlphaTestRef) discard;
}