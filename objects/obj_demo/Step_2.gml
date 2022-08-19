self.camera.Update();

self.game_time += GAME_UPDATE_TIME;
self.game_time %= 1;

if (keyboard_check_pressed(ord("Q")) || keyboard_check_pressed(ord("E"))) {
    var resolutions = [
        { w:  216, h:  120 },
        { w:  427, h:  240 },
        { w:  854, h:  480 },
        { w: 1280, h:  720 },
        { w: 1366, h:  768 },
        { w: 1600, h:  900 },
        { w: 1920, h: 1080 },
        { w: 2560, h: 1440 },
        { w: 3840, h: 2160 },
    ];
    var ww = surface_get_width(application_surface);
    var hh = surface_get_height(application_surface);
    var found = false;
    for (var i = 0, n = array_length(resolutions); i < n; i++) {
        if (resolutions[i].w == ww && resolutions[i].h == hh) {
            if (keyboard_check_pressed(ord("Q"))) {
                if (i > 0) {
                    self.SetWindow(resolutions[i - 1].w, resolutions[i - 1].h);
                }
            } else if (keyboard_check_pressed(ord("E"))) {
                if (i < array_length(resolutions) - 1) {
                    self.SetWindow(resolutions[i + 1].w, resolutions[i + 1].h);
                }
            }
            found = true;
            break;
        }
    }
    if (!found) {
        self.SetWindow(resolutions[3].w, resolutions[3].h);
    }
}

if (keyboard_check_pressed(ord("F"))) {
    self.SetWindow(, , , !window_get_fullscreen());
}

if (keyboard_check_pressed(vk_escape)) {
    game_end();
}