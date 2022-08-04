function lorikeet_set(palette_sprite, slot = 0, subimage = 0) {
    static sampler_index = shader_get_sampler_index(shd_lorikeet, "samp_Palette");
    static slot_index = shader_get_uniform(shd_lorikeet, "u_PaletteSlot");
    static slot_texture_bounds = shader_get_uniform(shd_lorikeet, "u_TextureBounds");
    shader_set(shd_lorikeet);
    texture_set_stage(sampler_index, sprite_get_texture(palette_sprite, clamp(subimage, 0, sprite_get_number(palette_sprite) - 1)));
    gpu_set_texfilter_ext(sampler_index, false);
    var bounds = sprite_get_uvs(palette_sprite, subimage);
    shader_set_uniform_f(slot_texture_bounds, bounds[0], bounds[1], bounds[2], bounds[3]);
    shader_set_uniform_f(slot_index, clamp(slot, 0, 1));
}