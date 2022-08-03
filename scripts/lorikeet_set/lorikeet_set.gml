function lorikeet_set(palette, slot) {
    static sampler_index = shader_get_sampler_index(shd_lorikeet, "samp_Palette");
    static slot_index = shader_get_uniform(shd_lorikeet, "u_PaletteSlot");
    shader_set(shd_lorikeet);
    texture_set_stage(sampler_index, sprite_get_texture(spr_test_palette, 0));
    shader_set_uniform_f(slot_index, clamp(slot, 0, 1));
}