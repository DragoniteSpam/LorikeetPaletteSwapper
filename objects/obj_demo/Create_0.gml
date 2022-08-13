vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_texcoord();
vertex_format_add_colour();
self.format = vertex_format_end();

show_debug_overlay(true);

var buffer = buffer_load("skybox.vbuff");
self.skybox = vertex_create_buffer_from_buffer(buffer, self.format);
buffer_delete(buffer);

scribble_font_bake_outline_8dir_2px("fnt_game_default", "fnt_game", c_black, false);
scribble_font_set_default("fnt_game");

self.depth = 0;
self.player = instance_exists(obj_player) ? obj_player.id : instance_create_depth(64, 64, 0, obj_player);

self.camera = new DragoCamera(0, 0, 100, 100, 100, 0, 0, 0, 1, 60, 1, 10000);
self.camera.Update = method(self, function() {
    var dist = 160;
    var angle = 30;
    var height = clamp((1024 - self.player.y) / 8, 0, 56);
    self.camera.x = self.player.x;
    self.camera.y = self.player.y + dcos(angle) * dist;
    self.camera.z = /*self.player.z*/ + dsin(angle) * dist;
    self.camera.xto = self.player.x;
    self.camera.yto = self.player.y;
    self.camera.zto = 0 + height;
});

var layer_id = layer_get_id("Tiles_Ground");
layer_set_visible(layer_id, false);
self.tilemap_ground = layer_tilemap_get_id(layer_id);

window_set_size(1600, 900);
surface_resize(application_surface, 1600, 900);
application_surface_draw_enable(false);

self.game_time = 0.65;  // * 24 = 3:36 PM