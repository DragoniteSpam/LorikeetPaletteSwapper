if (async_load[? "id"] == self.settings_buffer_load_id) {
    if (!async_load[? "status"]) return;
    var data = json_parse(buffer_peek(self.settings_buffer, 0, buffer_text));
    var w = data[$ "w"] ?? surface_get_width(application_surface);
    var h = data[$ "h"] ?? surface_get_height(application_surface);
    var f = data[$ "fps"] ?? game_get_speed(gamespeed_fps);
    var fullscreen = data[$ "fullscreen"] ?? window_get_fullscreen();
    self.SetWindow(w, h, f, fullscreen);
}