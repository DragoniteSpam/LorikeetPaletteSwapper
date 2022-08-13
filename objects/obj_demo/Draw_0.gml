self.camera.SetProjection();

matrix_set(matrix_world, matrix_build_identity());
lorikeet_set(pal_ground, 0, 0);
draw_tilemap(self.ground_tilemap, 0, 0);

with (obj_renderable) event_perform(ev_draw, 0);

matrix_set(matrix_world, matrix_build_identity());
shader_reset();