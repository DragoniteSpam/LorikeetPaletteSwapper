var hh = floor(self.game_time * 24);
var mm = floor(((self.game_time * 24) % 1) * 60);
var start = 40;
var spacing = 28;
var index = 0;
scribble("Current time: " + string(hh) + ":" + string_replace(string_format(mm, 2, 0), " ", "0"))
    .draw(32, start + spacing * index++);
scribble("Rendering resolution: " + string(surface_get_width(application_surface)) + " x " + string(surface_get_height(application_surface)))
    .draw(32, start + spacing * index++);
scribble("Instances: " + string(self.instances_rendered) + "/" + string(instance_count))
    .draw(32, start + spacing * index++);
scribble("FPS: " + string(fps) + "/" + string(game_get_speed(gamespeed_fps)))
    .draw(32, start + spacing * index++);
scribble("Fullscreen: " + (window_get_fullscreen() ? "True" : "False"))
    .draw(32, start + spacing * index++);

index = 0;
start = window_get_height() - 64;

scribble("Cycle rendering resolutions with Q and E")
    .draw(32, start - spacing * index++);
scribble("Toggle fullscreen with F")
    .draw(32, start - spacing * index++);
scribble("Toggle audio with M")
    .draw(32, start - spacing * index++);

index = 0;
start = 40;
var xx = window_get_width() - 32;

scribble("Build date:")
    .align(fa_right)
    .draw(xx, start + spacing * index++);
scribble(date_datetime_string(GM_build_date))
    .align(fa_right)
    .draw(xx, start + spacing * index++);
scribble("Version: " + LORIKEET_VERSION)
    .align(fa_right)
    .draw(xx, start + spacing * index++);