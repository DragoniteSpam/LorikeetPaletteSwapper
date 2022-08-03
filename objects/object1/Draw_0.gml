shader_set(shd_lorikeet);
texture_set_stage(shader_get_sampler_index(shd_lorikeet, "samp_Palette"), sprite_get_texture(spr_test_palette, 0));
shader_set_uniform_f(shader_get_uniform(shd_lorikeet, "u_PaletteSlot"), self.t % 1);
draw_sprite(spr_test_sprite, 0, 32, 32);
shader_reset();

self.t += 0.01;