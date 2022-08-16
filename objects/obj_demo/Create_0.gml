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

self.game_time = 0.6;   // * 24 = 3:36 PM

application_surface_draw_enable(false);

self.SetWindow = function(w, h, fps, fullscreen) {
    window_set_size(w, h);
    surface_resize(application_surface, w, h);
    game_set_speed(fps, gamespeed_fps);
    window_set_fullscreen(fullscreen);
};

self.settings_buffer = buffer_create(1024, buffer_grow, 1);
self.settings_buffer_load_id = buffer_load_async(self.settings_buffer, SETTINGS_FILE, 0, -1);