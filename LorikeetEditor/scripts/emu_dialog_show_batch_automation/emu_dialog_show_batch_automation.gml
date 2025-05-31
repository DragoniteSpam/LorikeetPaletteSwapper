function emu_dialog_show_batch_automation(files, type) {
    if (array_length(files) == 0) return;
    if (type == undefined) return;
    
    var dialog = new EmuDialog(480, 240, "Hey!").AddContent([
        new EmuText(480 / 2, 32, 480 - 32 - 32, 120, "[fa_center]Would you like to perform the automation [c_aqua]" + type.name + "[/c] on " + ((array_length(files) == 1) ? ("[c_aqua]" + filename_name(files[0]) + "[/c]") : ("these " + string(array_length(files)) + " files")) + "?")
    ]).AddDefaultConfirmCancelButtons("Yes", function() {
        var output_path = filename_path(get_save_filename("Image files|*.png", "Save everything here"));
        if (output_path = "") return;
        
        for (var i = 0, n = array_length(self.root.files); i < n; i++) {
            var file = self.root.files[i];
            if (!file_exists(file)) continue;
            
            var image = sprite_add(file, 0, false, false, 0, 0);
            
            if (sprite_exists(image)) {
                var palette_manager = new LorikeetPaletteManager();
                var sprite_indexed = palette_manager.ExtractPalette(image, 0, obj_demo.demo_force_full_palettes);
                var output = self.root.type.Execute(sprite_indexed, palette_manager);
                sprite_indexed = output.indexed;
                palette_manager.Refresh();
                sprite_save(sprite_indexed, 0, output_path + "idx_" + filename_name(file));
                sprite_save(palette_manager.palette, 0, output_path + "pal_" + filename_name(file));
                sprite_delete(image);
                sprite_delete(sprite_indexed);
                palette_manager.Destroy();
            }
        }
        self.root.Close();
    }, "No", function() {
        self.root.Close();
    }).CenterInWindow();
    
    dialog.type = type;
    dialog.files = files;
}

function emu_dialog_show_batch_automation_fused(files, type) {
    var output_file = get_save_filename("Image files|*.png", "output.png");
    var output_path = filename_path(output_file);
    if (output_path = "") return;
    
    var count = array_length(files);
    
    var sprites = array_filter(array_map(files, function(filename) {
        if (file_exists(filename)) {
            return sprite_add(filename, 0, false, false, 0, 0);
        }
        
        return undefined;
    }), function(sprite) {
        return sprite_exists(sprite);
    });
    
    var atlas = sprite_atlas_pack_dll(sprites, 2, 4, false);
    
    if (DEBUG) {
        show_debug_message($"{count} sprites atlased to {sprite_get_width(atlas.atlas)} x {sprite_get_height(atlas.atlas)}");
    }
    
    var palette_manager = new LorikeetPaletteManager();
    var sprite_indexed = palette_manager.ExtractPalette(atlas.atlas, 0, obj_demo.demo_force_full_palettes);
    sprite_indexed = type.Execute(sprite_indexed, palette_manager).indexed;
    palette_manager.Refresh();
    
    var surface = surface_create(sprite_get_width(sprite_indexed), sprite_get_height(sprite_indexed));
    surface_set_target(surface);
    draw_clear_alpha(c_black, 0);
    gpu_set_blendmode(bm_add);
    draw_sprite(sprite_indexed, 0, 0, 0);
    gpu_set_blendmode(bm_normal);
    surface_reset_target();
    
    for (var i = 0; i < count; i++) {
        var data = atlas.uvs[i];
        surface_save_part(surface, $"{output_path}idx_{filename_name(files[i])}", data.x, data.y, data.w, data.h);
    }
    
    sprite_save(atlas.atlas, 0, output_path + $"pal_{filename_name(output_file)}.png");
    
    if (DEBUG) {
        sprite_save(sprite_indexed, 0, $"{output_path}idx_{filename_name(output_file)}");
        sprite_save(palette_manager.palette, 0, $"{output_path}pal_{filename_name(output_file)}");
    }
    
    surface_free(surface);
    sprite_delete(sprite_indexed);
    palette_manager.Destroy();
    
    sprite_delete(atlas.atlas);
    array_foreach(sprites, sprite_delete);
}