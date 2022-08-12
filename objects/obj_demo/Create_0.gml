scribble_font_bake_outline_8dir("fnt_emu_default", "fnt_emu_default_outline", c_black, false);

self.demo_sprite = sprite_duplicate(spr_test_sprite);
var palette_data = lorikeet_palette_extract(self.demo_sprite);
self.demo_sprite_indexed = palette_data.indexed_sprite;
self.demo_palette_data = palette_data.palette_array;
self.demo_palette = palette_data.palette_sprite;
self.demo_palette_index = 0;
self.demo_sprite_type = 0;
self.demo_force_full_palettes = false;

self.LoadSprite = function() {
    var fn = get_open_filename("Image files|*.png;*.bmp", "");
    if (file_exists(fn)) {
        var image = sprite_add(fn, 0, false, false, 0, 0);
        
        if (sprite_exists(image)) {
            var palette_data = lorikeet_palette_extract(image, 0, self.demo_force_full_palettes);
            sprite_delete(self.demo_sprite);
            sprite_delete(self.demo_palette);
            self.demo_sprite = image;
            self.demo_sprite_indexed = palette_data.indexed_sprite;
            self.demo_palette_data = palette_data.palette_array;
            self.demo_palette = palette_data.palette_sprite;
            return palette_data.execution_time;
        }
    }
    
    return undefined;
};

self.ReExtract = function() {
    var palette_data = lorikeet_palette_extract(self.demo_sprite, 0, self.demo_force_full_palettes);
    sprite_delete(self.demo_palette);
    self.demo_sprite_indexed = palette_data.indexed_sprite;
    self.demo_palette_data = palette_data.palette_array;
    self.demo_palette = palette_data.palette_sprite;
    return palette_data.execution_time;
};

self.ResetSprite = function() {
    sprite_delete(self.demo_sprite);
    sprite_delete(self.demo_palette);
    self.demo_sprite = sprite_duplicate(spr_test_sprite);
    var palette_data = lorikeet_palette_extract(self.demo_sprite, 0, self.demo_force_full_palettes);
    self.demo_sprite_indexed = palette_data.indexed_sprite;
    self.demo_palette_data = palette_data.palette_array;
    self.demo_palette = palette_data.palette_sprite;
    return palette_data.execution_time;
};

self.LoadPalette = function() {
    var fn = get_open_filename("Image files|*.png;*.bmp", "");
    if (file_exists(fn)) {
        var image = sprite_add(fn, 0, false, false, 0, 0);
        
        if (sprite_exists(image)) {
            sprite_delete(self.demo_palette);
            self.demo_palette = image;
            self.demo_palette_data = palette_to_array(image);
        }
    }
    
    return undefined;
};

self.SaveIndexedColor = function() {
    var fn = get_save_filename("Image files|*.png", "");
    if (fn != "") {
        sprite_save(self.demo_sprite_indexed, 0, fn);
    }
};

self.SavePaletteSprite = function() {
    var fn = get_save_filename("Image files|*.png", "");
    if (fn != "") {
        sprite_save(self.demo_palette, 0, fn);
    }
};

var ew = 320;
var eh = 32;

self.ui = (new EmuCore(0, 0, window_get_width(), window_get_height())).AddContent([
    new EmuText(32, EMU_AUTO, ew, eh, "[c_aqua]Lorikeet Palette Extraction"),
    new EmuButton(32, EMU_AUTO, ew / 2, eh, "Load Sprite", function() {
        var load_results = obj_demo.LoadSprite();
        self.GetSibling("TIME").text = "Palette extraction time: " + string(load_results) + " ms";
    }),
    new EmuButton(32 + ew / 2, EMU_INLINE, ew / 2, eh, "Load Palette", function() {
        obj_demo.LoadPalette();
    }),
    new EmuButton(32, EMU_AUTO, ew / 2, eh, "Save Indexed Color", function() {
        obj_demo.SaveIndexedColor();
    }),
    new EmuButton(32 + ew / 2, EMU_INLINE, ew / 2, eh, "Save Palette", function() {
        obj_demo.SavePaletteSprite();
    }),
    new EmuButton(32, EMU_AUTO, ew, eh, "Reset Demo Sprite", function() {
        var load_results = obj_demo.ResetSprite();
        self.GetSibling("TIME").text = "Palette extraction time: " + string(load_results) + " ms";
    }),
    new EmuCheckbox(32, EMU_AUTO, ew, eh, "Extract full palettes?", self.demo_force_full_palettes, function() {
        obj_demo.demo_force_full_palettes = self.value;
        obj_demo.ReExtract();
    }),
    new EmuRadioArray(32, EMU_AUTO, ew, eh, "Display type:", 0, function() {
        obj_demo.demo_sprite_type = self.value;
    }).AddOptions(["Original", "Indexed", "Indexed with Palette"]),
    new EmuText(32, EMU_AUTO, ew, eh, "Palette extraction time: " + string(palette_data.execution_time) + " ms")
        .SetID("TIME"),
    new EmuRenderSurface(32, EMU_AUTO, ew, ew, function(mx, my) {
        // render
        var sprite = obj_demo.demo_palette;
        draw_sprite_tiled(spr_palette_checker, 0, 0, 0);
        var hscale = self.width / sprite_get_width(sprite);
        var sh = sprite_get_height(sprite);
        var vscale = self.height / sh;
        var scale = min(hscale, vscale);
        draw_sprite_ext(sprite, 0, 0, 0, scale, scale, 0, c_white, 1);
        draw_sprite_stretched_ext(spr_tile_selector, 0, 0, hscale * sh * obj_demo.demo_palette_index, self.width, hscale, c_red, 1);
    }, function(mx, my) {
        // step
    }, emu_null),
    (new EmuButton(32, EMU_AUTO, ew / 2, eh, "Add row", function() {
        var new_palette = lorikeet_palette_add_palette(obj_demo.demo_palette, obj_demo.demo_palette_index);
        sprite_delete(obj_demo.demo_palette);
        obj_demo.demo_palette = new_palette;
    })),
    (new EmuButton(32 + ew / 2, EMU_INLINE, ew / 2, eh, "Delete row", function() {
        
    })),
    new EmuRenderSurface(32 + 32 + ew, EMU_BASE, 762, 836, function(mx, my) {
        // render
        draw_sprite_tiled(spr_palette_checker, 0, 0, 0);
        switch (obj_demo.demo_sprite_type) {
            case 0:
                draw_sprite_ext(obj_demo.demo_sprite, 0, self.map_x, self.map_y, self.zoom, self.zoom, 0, c_white, 1);
                break;
            case 1:
                draw_sprite_ext(obj_demo.demo_sprite_indexed, 0, self.map_x, self.map_y, self.zoom, self.zoom, 0, c_white, 1);
                break;
            case 2:
                lorikeet_set(obj_demo.demo_palette, 0);
                draw_sprite_ext(obj_demo.demo_sprite_indexed, 0, self.map_x, self.map_y, self.zoom, self.zoom, 0, c_white, 1);
                shader_reset();
                break;
        }
        
        scribble("[fnt_emu_default_outline]Middle mouse button to pan")
            .draw(32, 32);
        scribble("[fnt_emu_default_outline]Mouse wheel to zoom")
            .draw(32, 48);
    }, function(mx, my) {
        // step
        if (!self.isActiveDialog()) return;
        var mouse_in_view = (mx >= 0 && mx <= self.width && my >= 0 && my <= self.height);
        if (mouse_in_view) {
            var zoom_step = 0.5;
            if (mouse_wheel_down()) {
                var cx = (mx - self.map_x) / self.zoom;
                var cy = (my - self.map_y) / self.zoom;
                self.zoom = max(1, self.zoom - zoom_step);
                self.map_x = mx - self.zoom * cx;
                self.map_y = my - self.zoom * cy;
            } else if (mouse_wheel_up()) {
                var cx = (mx - self.map_x) / self.zoom;
                var cy = (my - self.map_y) / self.zoom;
                self.zoom = min(16, self.zoom + zoom_step);
                self.map_x = mx - self.zoom * cx;
                self.map_y = my - self.zoom * cy;
            }
        }
        
        if (mouse_in_view && mouse_check_button_pressed(mb_middle)) {
            self.panning = true;
            self.pan_x = mx;
            self.pan_y = my;
        }
        if (mouse_check_button(mb_middle)) {
            self.map_x += mx - self.pan_x;
            self.map_y += my - self.pan_y;
            self.pan_x = mx;
            self.pan_y = my;
            window_set_cursor(cr_size_all);
        } else {
            self.panning = false;
            window_set_cursor(cr_default);
        }
        if (keyboard_check_pressed(vk_enter)) {
            self.zoom = 1;
            self.map_x = 0;
            self.map_y = 0;
            self.panning = false;
            self.pan_x = 0;
            self.pan_y = 0;
        }
    }, function() {
        // create
        self.zoom = 8;
        self.map_x = 0;
        self.map_y = 0;
        self.panning = false;
        self.pan_x = 0;
        self.pan_y = 0;
    }),
    new EmuRenderSurface(32 + 32 + 32 + ew + 762, EMU_BASE, 384, 704, function(mx, my) {
        // render
        var palette = obj_demo.demo_palette_data[obj_demo.demo_palette_index];
        
        var step = 32;
        var hcells = self.width div step;
        var mcx = mx div step;
        var mcy = my div step;
        var index = min(mcy * hcells + mcx, array_length(palette) - 1);
        mcx = index % hcells;
        mcy = index div hcells;
        draw_sprite_tiled(spr_palette_checker, 0, 0, 0);
        
        for (var i = 0, n = array_length(palette); i < n; i++) {
            var c = palette[i];
            if (c == -1) break;
            draw_rectangle_color((i % hcells) * step, (i div hcells) * step, ((i % hcells) + 1) * step, ((i div hcells) + 1) * step, c, c, c, c, false);
        }
        
        var mouse_in_view = (mx >= 0 && mx <= self.width && my >= 0 && my <= self.height);
        if (mouse_in_view) {
            draw_sprite(spr_tile_selector, 0, mcx * step, mcy * step);
        }
        
        var max_row = ceil(array_length(palette) / hcells);
        var max_column = array_length(palette) % hcells;
        
        draw_set_alpha(0.5);
        draw_rectangle_colour(max_column * step, (max_row - 1) * step, self.width, max_row * step, c_black, c_black, c_black, c_black, false);
        draw_rectangle_colour(0, max_row * step, self.width, self.height, c_black, c_black, c_black, c_black, false);
        draw_set_alpha(1);
        
        for (var i = 0; i < self.width; i += step) {
            draw_line_colour(i, 0, i, self.height, c_black, c_black);
        }
        for (var i = 0; i < self.height; i += step) {
            draw_line_colour(0, i, self.width, i, c_black, c_black);
        }
    }, function(mx, my) {
        // step
        static picker = new EmuColorPicker(0, 0, 0, 0, "", c_black, function() {
            var palette_slot = obj_demo.demo_palette_data[obj_demo.demo_palette_index][self.palette_index];
            var changed = (palette_slot != self.value);
            obj_demo.demo_palette_data[obj_demo.demo_palette_index][self.palette_index] = self.value;
            if (changed) {
                var new_palette = lorikeet_palette_modify(obj_demo.demo_palette, self.palette_index, obj_demo.demo_palette_index, self.value);
                sprite_delete(obj_demo.demo_palette);
                obj_demo.demo_palette = new_palette;
            }
        });
        
        if (!self.isActiveDialog()) return;
        var mouse_in_view = (mx >= 0 && mx <= self.width && my >= 0 && my <= self.height);
        if (!mouse_in_view) return;
        
        var step = 32;
        var hcells = self.width div step;
        var mcx = mx div step;
        var mcy = my div step;
        
        if (mouse_check_button_pressed(mb_left)) {
            var index = mcy * hcells + mcx;
            picker.palette_index = index;
            picker.value = obj_demo.demo_palette_data[obj_demo.demo_palette_index][index];
            picker.ShowPickerDialog().SetActiveShade(0);
        }
    }, function() {
        // create
    }),
    new EmuButton(32 + 32 + 32 + ew + 762, EMU_AUTO, 384 / 2, eh, "Shift Left", function() {
        var data = obj_demo.demo_palette_data[obj_demo.demo_palette_index];
        var value0 = data[0];
        array_delete(data, 0, 1);
        array_push(data, -1);
        for (var i = 0, n = array_length(data); i < n; i++) {
            if (data[i] == -1) {
                data[i] = value0;
                break;
            }
        }
        var new_palette = lorikeet_palette_create(obj_demo.demo_palette_data);
        sprite_delete(obj_demo.demo_palette);
        obj_demo.demo_palette = new_palette;
    }),
    new EmuButton(32 + 32 + 32 + ew + 762 + 384 / 2, EMU_INLINE, 384 / 2, eh, "Shift Right", function() {
        var data = obj_demo.demo_palette_data[obj_demo.demo_palette_index];
        for (var i = array_length(data) - 1; i >= 0; i--) {
            if (data[i] != -1) {
                array_insert(data, 0, data[i]);
                array_delete(data, i + 1, 1);
                break;
            }
        }
        var new_palette = lorikeet_palette_create(obj_demo.demo_palette_data);
        sprite_delete(obj_demo.demo_palette);
        obj_demo.demo_palette = new_palette;
    }),
    new EmuButton(32 + 32 + 32 + ew + 762, EMU_AUTO, 384 / 2, eh, "HSV", function() {
        
    }),
    new EmuButton(32 + 32 + 32 + ew + 762 + 384 / 2, EMU_INLINE, 384 / 2, eh, "Color Channels", function() {
        
    }),
]);