draw_clear_alpha(c_black, 1);
gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_alphatestenable(true);
gpu_set_alphatestref(254);

self.camera.SetProjection();

matrix_set(matrix_world, matrix_build_identity());
lorikeet_set(pal_ground, 0, 0);
draw_tilemap(self.ground_tilemap, 0, 0);

with (obj_renderable) event_perform(ev_draw, 0);

matrix_set(matrix_world, matrix_build_identity());
shader_reset();
gpu_set_ztestenable(false);
gpu_set_zwriteenable(false);