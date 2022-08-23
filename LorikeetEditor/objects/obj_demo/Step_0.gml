self.demo_palette_index += self.demo_palette_speed * (game_get_speed(gamespeed_microseconds) / 1000000);
self.demo_palette_index = (self.demo_palette_index + array_length(self.demo_palette.data)) % array_length(self.demo_palette.data);

var files = file_dropper_get_files([".png", ".bmp"]);
if (array_length(files) > 0) {
    var dialog = new EmuDialog(480, 240, "Hey!").AddContent([
        new EmuText(480 / 2, 32, 480 - 32 - 32, 120, "[fa_center]Would you like to load [c_aqua]" + filename_name(files[0]) + "[/c] into the editor?")
    ]).AddDefaultConfirmCancelButtons("Yes", function() {
        obj_demo.LoadSprite(self.root.file_to_load);
        self.root.Close();
    }, "No", function() {
        self.root.Close();
    }).CenterInWindow();
    dialog.file_to_load = files[0];
}
file_dropper_flush();