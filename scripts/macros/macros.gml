// gameplay
#macro DT                           (game_get_speed(gamespeed_microseconds) / 1000000)
#macro GAME_UPDATE_TIME             ((DT * 360) / 86400)
#macro MUSIC_FADE_RATE              0.005

#macro SETTINGS_FILE                "settings.ini"

// audio
#macro VOLUME_BGM                   (obj_demo.volume.main * obj_demo.volume.bgm)
#macro VOLUME_SE                    (obj_demo.volume.main * obj_demo.volume.se)

// video
#macro FLOWER_DENSITY               3
#macro pi:FLOWER_DENSITY            1.25
#macro DESTROY_PERIMETER_TREES      false
#macro pi:DESTROY_PERIMETER_TREES   true

#macro AVAILABLE_RESOLUTIONS        [\
        { w:   216, h:  120 },\
        { w:   427, h:  240 },\
        { w:   854, h:  480 },\
        { w:  1280, h:  720 },\
        { w:  1366, h:  768 },\
        { w:  1600, h:  900 },\
        { w:  1920, h: 1080 },\
        { w:  2560, h: 1440 },\
        { w:  3840, h: 2160 },\
        { w:  5120, h: 2880 },\
        { w:  7680, h: 4320 },\
    ]
#macro pi:AVAILABLE_RESOLUTIONS        [\
        { w:   216, h:  120 },\
        { w:   427, h:  240 },\
        { w:   854, h:  480 },\
        { w:  1280, h:  720 },\
        { w:  1366, h:  768 },\
        { w:  1600, h:  900 },\
        { w:  1920, h: 1080 },\
        { w:  2560, h: 1440 },\
        { w:  3840, h: 2160 },\
    ]

// function overrides

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