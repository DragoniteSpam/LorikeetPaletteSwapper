window_set_cursor(cr_none);
cursor_sprite = -1;

self.demo_palette_index += self.demo_palette_speed * (game_get_speed(gamespeed_microseconds) / 1000000);
self.demo_palette_index = (self.demo_palette_index + array_length(self.demo_palette.data)) % array_length(self.demo_palette.data);

var files = file_dropper_get_files([".png", ".bmp"]);
if (array_length(files) > 0) {
    if (EmuOverlay.GetTop()) {
        EmuOverlay.GetTop().DroppedFileHandler(files);
    } else {
        self.ui.DroppedFileHandler(files);
    }
}
file_dropper_flush();