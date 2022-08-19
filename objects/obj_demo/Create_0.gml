vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_texcoord();
vertex_format_add_colour();
self.format = vertex_format_end();

gml_release_mode(true);

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

self.game_time = 0.7;       // * 24 = 4:48 PM

application_surface_draw_enable(false);

self.SetWindow = function(
        w = surface_get_width(application_surface),
        h = surface_get_height(application_surface),
        fps = game_get_speed(gamespeed_fps),
        fullscreen = window_get_fullscreen()
    ) {
    window_set_size(min(w, display_get_width()), min(h, display_get_height()));
    surface_resize(application_surface, w, h);
    game_set_speed(fps, gamespeed_fps);
    window_set_fullscreen(fullscreen);
    display_set_gui_maximize();
};

self.SaveSettings = function() {
    var buffer = buffer_create(1024, buffer_grow, 1);
    buffer_write(buffer, buffer_text, json_stringify({
        w: surface_get_width(application_surface),
        h: surface_get_height(application_surface),
        fps: game_get_speed(gamespeed_fps),
        fullscreen: window_get_fullscreen(),
    }));
    buffer_save_async(buffer, SETTINGS_FILE, 0, buffer_tell(buffer));
    buffer_delete(buffer);
};

self.settings_buffer = buffer_create(1024, buffer_grow, 1);
self.settings_buffer_load_id = buffer_load_async(self.settings_buffer, SETTINGS_FILE, 0, -1);

call_later(10, time_source_units_seconds, function() {
    self.SaveSettings();
}, true);

self.spart_system_water = new spart_system([1024, 4096]);
self.spart_emitter_water = new spart_emitter(self.spart_system_water);
self.spart_type_water = new spart_type();
self.spart_type_water_splash = new spart_type();

self.particle_palette_sprite = pal_bubbles;

with (self.spart_type_water) {
    setSprite(idx_bubbles, -1, 0);
    setSize(2, 6, 0, 0, 0, 200);
    setLife(0.25, 0.6);
    setSpeed(64, 64, 0, 0);
    setDirection(0, 0, 1, 30, false);
    setGravity(96, 0, 0, -1);
}

with (self.spart_type_water_splash) {
    setSprite(idx_bubbles, -1, 0);
    setSize(6, 10, 0, 0, 0, 200);
    setLife(0.4, 0.75);
    setSpeed(96, 96, 0, 0);
    setDirection(0, 0, 1, 30, false);
    setGravity(96, 0, 0, -1);
}

self.spart_system_grass = new spart_system([256, 1024]);
self.spart_emitter_grass = new spart_emitter(self.spart_system_grass);
self.spart_type_grass = new spart_type();

with (self.spart_type_grass) {
    setSprite(idx_grass_rustle, -1, 0);
    setSize(6, 10, -1, 0, 0, 200);
    setLife(0.5, 0.8);
    setSpeed(64, 64, 0, 0);
    setDirection(0, 0, 1, 30, false);
    setGravity(64, 0, 0, -1);
}

self.ParticlesBurst = function(emitter, type, x, y, z, amount) {
    emitter.setRegion(matrix_build(x, y, z, 0, 0, 0, 1, 1, 1), 1, 1, 1, spart_shape_cube, spart_distr_linear, false);
    emitter.burst(type, amount, true);
};