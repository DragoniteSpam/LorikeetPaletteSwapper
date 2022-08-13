function lorikeet_set(palette_sprite, palette_index = 0, subimage = 0) {
    static sampler_index = shader_get_sampler_index(shd_lorikeet, "samp_Palette");
    static u_slot_index = shader_get_uniform(shd_lorikeet, "u_PaletteSlot");
    static u_slot_index_count = shader_get_uniform(shd_lorikeet, "u_PaletteSlotCount");
    static u_slot_texture_bounds = shader_get_uniform(shd_lorikeet, "u_TextureBounds");
    static u_alpha_test = shader_get_uniform(shd_lorikeet, "u_AlphaTest");
    static u_alpha_test_ref = shader_get_uniform(shd_lorikeet, "u_AlphaTestRef");
    shader_set(shd_lorikeet);
    texture_set_stage(sampler_index, sprite_get_texture(palette_sprite, clamp(subimage, 0, sprite_get_number(palette_sprite) - 1)));
    gpu_set_texfilter_ext(sampler_index, false);
    var bounds = sprite_get_uvs(palette_sprite, subimage);
    bounds[4] *= texture_get_texel_height(sprite_get_texture(palette_sprite, subimage))
    bounds[5] *= texture_get_texel_width(sprite_get_texture(palette_sprite, subimage))
    shader_set_uniform_f(u_slot_texture_bounds, bounds[0], bounds[1], bounds[2] - bounds[4], bounds[3] - bounds[5]);
    shader_set_uniform_f(u_slot_index, palette_index);
    shader_set_uniform_f(u_slot_index_count, sprite_get_height(palette_sprite));
    shader_set_uniform_f(u_alpha_test, gpu_get_alphatestenable());
    shader_set_uniform_f(u_alpha_test_ref, gpu_get_alphatestref() / 255);
}