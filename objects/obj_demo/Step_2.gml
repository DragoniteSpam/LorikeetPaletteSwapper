self.camera.Update();

self.game_time += GAME_UPDATE_TIME;
self.game_time %= 1;

if (keyboard_check_pressed(ord("Q")) || keyboard_check_pressed(ord("E"))) {
    var resolutions = AVAILABLE_RESOLUTIONS;
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

if (keyboard_check_pressed(ord("M"))) {
    self.volume.main = (self.volume.main == 1) ? 0 : 1;
}

if (keyboard_check_pressed(vk_escape)) {
    game_end();
}

var hour = self.game_time * 24;
var night_volume = clamp(2 * abs(hour - 13) - 10, 0, 1);
var day_volume = 1 - night_volume;
audio_sound_gain(bgm_piano, night_volume * VOLUME_BGM, 0);
audio_sound_gain(bgm_guitar, day_volume * VOLUME_BGM, 0);
audio_sound_gain(bgm_pad, day_volume * VOLUME_BGM, 0);
audio_sound_gain(bgm_bass, VOLUME_BGM, 0);
audio_sound_gain(bgm_percussion, VOLUME_BGM, 0);