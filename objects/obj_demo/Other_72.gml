if (async_load[? "id"] == self.settings_buffer_load_id) {
    if (!async_load[? "status"]) return;
    var data = json_parse(buffer_peek(self.settings_buffer, 0, buffer_text));
    var w = data[$ "w"] ?? window_get_width();
    var h = data[$ "h"] ?? window_get_height();
    var f = data[$ "f"] ?? game_get_speed(gamespeed_fps);
    var fullscreen = data[$ "fullscreen"] ?? window_get_fullscreen();
    self.SetWindow(w, h, f, fullscreen);
}