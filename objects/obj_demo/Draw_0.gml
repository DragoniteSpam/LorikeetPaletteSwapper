draw_clear_alpha(c_black, 1);

self.camera.SetProjection();

lorikeet_set(pal_sky_back, get_palette_index_by_time());
self.camera.SetSkybox(self.skybox, idx_sky_back).DrawSkybox();
gpu_set_alphatestenable(true);
gpu_set_alphatestref(254);
lorikeet_set(pal_sky_fore, get_palette_index_by_time());
self.camera.SetSkybox(self.skybox, idx_sky_fore).DrawSkybox();
gpu_set_alphatestenable(false);

lorikeet_set(pal_water, 0, 0, shd_lorikeet_water_disp);
matrix_set(matrix_world, matrix_build_identity());

var sampler_disp_index = shader_get_sampler_index(shd_lorikeet_water_disp, "samp_Displace");
texture_set_stage(sampler_disp_index, sprite_get_texture(spr_water_disp, 0));
shader_set_uniform_f(shader_get_uniform(shd_lorikeet_water_disp, "u_Time"), (current_time / 20000) % 1);
gpu_set_texrepeat(true);
gpu_set_texfilter_ext(sampler_disp_index, true);
draw_sprite_tiled(idx_water, 0, 0, 0);
gpu_set_texfilter(false);

matrix_set(matrix_world, matrix_build_identity());
lorikeet_set(pal_ground, 0);
draw_tilemap(self.tilemap_ground, 0, 0);

gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_alphatestenable(true);
gpu_set_alphatestref(254);

with (obj_renderable) event_perform(ev_draw, 0);

matrix_set(matrix_world, matrix_build_identity());
shader_reset();
gpu_set_ztestenable(false);
gpu_set_zwriteenable(false);