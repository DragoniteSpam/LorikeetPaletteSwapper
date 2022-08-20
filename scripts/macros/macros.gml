#macro DT                           (game_get_speed(gamespeed_microseconds) / 1000000)
#macro GAME_UPDATE_TIME             ((DT * 360) / 86400)
#macro MUSIC_FADE_RATE              0.005

#macro SETTINGS_FILE                "settings.ini"

#macro VOLUME_BGM                   (obj_demo.volume.main * obj_demo.volume.bgm)
#macro VOLUME_SE                    (obj_demo.volume.main * obj_demo.volume.se)

#macro __window_set_size_source     window_set_size
#macro window_set_size              __window_set_size_replacement

function __window_set_size_replacement(w, h) {
    if (os_browser != browser_not_a_browser || os_type == os_operagx) return;
    __window_set_size_source(w, h);
}

#macro __window_set_fullscreen_source   window_set_fullscreen
#macro window_set_fullscreen            __window_set_fullscreen_replacement

function __window_set_fullscreen_replacement(fullscreen) {
    if (os_browser != browser_not_a_browser || os_type == os_operagx) return;
    __window_set_fullscreen_source(fullscreen);
}