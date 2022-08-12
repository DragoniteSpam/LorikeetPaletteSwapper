#macro DEMO_PLAY_SPEED_FPS          8
#macro C_BUTTON_SELECTED            c_yellow

scribble_font_bake_outline_8dir("fnt_emu_default", "fnt_emu_default_outline", c_black, false);

self.demo_sprite = sprite_duplicate(spr_test_sprite);                               // source sprite
self.demo_palette = new LorikeetPaletteManager();                                   // palette data
var t0 = get_timer();
self.demo_sprite_indexed = self.demo_palette.ExtractPalette(self.demo_sprite);      // indexed color sprite
var starting_extraction_time = (get_timer() - t0) / 1000;

self.demo_palette_index = 0;                                                        // palette index
self.demo_palette_speed = 0;                                                        // palette playback speed
self.demo_sprite_type = 2;                                                          // display type
self.demo_force_full_palettes = false;                                              // extract a palette of size 256?

self.demo_mode = EOperationModes.SELECTION;

enum EOperationModes {
    SELECTION,
    EYEDROPPER,
    BUCKET,
}

self.demo_copied_color = c_black;

self.LoadSprite = function() {
    var fn = get_open_filename("Image files|*.png;*.bmp", "");
    if (file_exists(fn)) {
        var image = sprite_add(fn, 0, false, false, 0, 0);
        
        if (sprite_exists(image)) {
            var t0 = get_timer();
            sprite_delete(self.demo_sprite);
            self.demo_sprite = image;
            self.demo_sprite_indexed = self.demo_palette.ExtractPalette(image, 0, self.demo_force_full_palettes);
            self.demo_palette_index = 0;
            return (get_timer() - t0) / 1000;
        }
    }
    
    return undefined;
};

self.ReExtract = function() {
    var t0 = get_timer();
    sprite_delete(self.demo_sprite);
    self.demo_sprite_indexed = self.demo_palette.ExtractPalette(self.demo_sprite, 0, self.demo_force_full_palettes);
    self.demo_palette_index = 0;
    return (get_timer() - t0) / 1000;
};

self.ResetSprite = function() {
    var t0 = get_timer();
    sprite_delete(self.demo_sprite);
    self.demo_sprite = sprite_duplicate(spr_test_sprite);
    self.demo_sprite_indexed = self.demo_palette.ExtractPalette(self.demo_sprite, 0, self.demo_force_full_palettes);
    return (get_timer() - t0) / 1000;
};

self.LoadPalette = function() {
    var fn = get_open_filename("Image files|*.png;*.bmp", "");
    if (file_exists(fn)) {
        var image = sprite_add(fn, 0, false, false, 0, 0);
        
        if (sprite_exists(image)) {
            self.demo_palette.FromImage(image);
            self.demo_palette_index = 0;
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
    new EmuRadioArray(32, EMU_AUTO, ew, eh, "Display type:", self.demo_sprite_type, function() {
        obj_demo.demo_sprite_type = self.value;
    }).AddOptions(["Original", "Indexed", "Indexed with Palette"]),
    new EmuText(32, EMU_AUTO, ew, eh, "Palette extraction time: " + string(starting_extraction_time) + " ms")
        .SetID("TIME"),
    new EmuRenderSurface(32, EMU_AUTO, ew, ew, function(mx, my) {
        // render
        var sprite = obj_demo.demo_palette.palette;
        draw_sprite_tiled(spr_palette_checker, 0, 0, 0);
        var hscale = self.width / sprite_get_width(sprite);
        var sh = sprite_get_height(sprite);
        var vscale = self.height / sh;
        var scale = min(hscale, vscale);
        draw_sprite_ext(sprite, 0, 0, 0, scale, scale, 0, c_white, 1);
        draw_sprite_stretched_ext(spr_tile_selector, 0, 0, hscale * floor(obj_demo.demo_palette_index), self.width, hscale, c_red, 1);
    }, function(mx, my) {
        // step
        if (mx < 0 || mx >= self.width || my < 0 || my >= self.height) return;
        if (mouse_check_button(mb_left)) {
            var sprite = obj_demo.demo_palette.palette;
            var hscale = self.width / sprite_get_width(sprite);
            var row = min(my div hscale, sprite_get_height(sprite) - 1);
            obj_demo.demo_palette_index = row;
        }
    }, emu_null),
    (new EmuButton(32, EMU_AUTO, ew / 2, eh, "Add row", function() {
        obj_demo.demo_palette.AddPaletteRow(obj_demo.demo_palette_index);
    })),
    (new EmuButton(32 + ew / 2, EMU_INLINE, ew / 2, eh, "Delete row", function() {
        obj_demo.demo_palette.RemovePaletteRow(obj_demo.demo_palette_index);
        obj_demo.demo_palette_index = min(obj_demo.demo_palette_index, array_length(obj_demo.demo_palette.data) - 1);
    })),
    (new EmuButtonImage(32 + 0 * ew / 4, EMU_AUTO, ew / 4, eh, spr_controls, 0, c_white, 1, false, function() {
        // step back
        obj_demo.demo_palette_index = (--obj_demo.demo_palette_index + array_length(obj_demo.demo_palette.data)) % array_length(obj_demo.demo_palette.data);
    })),
    (new EmuButtonImage(32 + 1 * ew / 4, EMU_INLINE, ew / 4, eh, spr_controls, 1, c_white, 1, false, function() {
        // pause
        obj_demo.demo_palette_speed = 0;
    }))
        .SetUpdate(function() {
            self.color_sprite_interactive = function() {
                return (obj_demo.demo_palette_speed == 0) ? C_BUTTON_SELECTED : EMU_COLOR_SPRITE_INTERACTIVE;
            };
        }),
    (new EmuButtonImage(32 + 2 * ew / 4, EMU_INLINE, ew / 4, eh, spr_controls, 2, c_white, 1, false, function() {
        // play
        obj_demo.demo_palette_speed = DEMO_PLAY_SPEED_FPS;
    }))
        .SetUpdate(function() {
            self.color_sprite_interactive = function() {
                return (obj_demo.demo_palette_speed != 0) ? C_BUTTON_SELECTED : EMU_COLOR_SPRITE_INTERACTIVE;
            };
        }),
    (new EmuButtonImage(32 + 3 * ew / 4, EMU_INLINE, ew / 4, eh, spr_controls, 3, c_white, 1, false, function() {
        // step forward
        obj_demo.demo_palette_index = ++obj_demo.demo_palette_index % array_length(obj_demo.demo_palette.data);
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
                lorikeet_set(obj_demo.demo_palette.palette, obj_demo.demo_palette_index);
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
    (new EmuButtonImage(32 + 32 + 32 + ew + 762 + 0 * 384 / 3, EMU_BASE, 384 / 3, eh, spr_modes, 0, c_white, 1, false, function() {
        obj_demo.demo_mode = EOperationModes.SELECTION;
    }))
        .SetUpdate(function() {
            self.color_sprite_interactive = function() {
                return (obj_demo.demo_mode == EOperationModes.SELECTION) ? C_BUTTON_SELECTED : EMU_COLOR_SPRITE_INTERACTIVE;
            };
        }),
    (new EmuButtonImage(32 + 32 + 32 + ew + 762 + 1 * 384 / 3, EMU_INLINE, 384 / 3, eh, spr_modes, 1, c_white, 1, false, function() {
        obj_demo.demo_mode = EOperationModes.EYEDROPPER;
    }))
        .SetUpdate(function() {
            self.color_sprite_interactive = function() {
                return (obj_demo.demo_mode == EOperationModes.EYEDROPPER) ? C_BUTTON_SELECTED : EMU_COLOR_SPRITE_INTERACTIVE;
            };
        }),
    (new EmuButtonImage(32 + 32 + 32 + ew + 762 + 2 * 384 / 3, EMU_INLINE, 384 / 3, eh, spr_modes, 2, c_white, 1, false, function() {
        obj_demo.demo_mode = EOperationModes.BUCKET;
    }))
        .SetUpdate(function() {
            self.color_sprite_interactive = function() {
                return (obj_demo.demo_mode == EOperationModes.BUCKET) ? C_BUTTON_SELECTED : EMU_COLOR_SPRITE_INTERACTIVE;
            };
        }),
    new EmuRenderSurface(32 + 32 + 32 + ew + 762, EMU_AUTO, 384, 704, function(mx, my) {
        // render
        var palette = obj_demo.demo_palette.data[obj_demo.demo_palette_index];
        
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
            obj_demo.demo_palette.Modify(self.palette_index, obj_demo.demo_palette_index, self.value);
        });
        
        if (!self.isActiveDialog()) return;
        var mouse_in_view = (mx >= 0 && mx <= self.width && my >= 0 && my <= self.height);
        if (!mouse_in_view) return;
        
        var step = 32;
        var hcells = self.width div step;
        var mcx = mx div step;
        var mcy = my div step;
        var index = min(mcy * hcells + mcx, array_length(obj_demo.demo_palette.data[obj_demo.demo_palette_index]) - 1);
        
        if (mouse_check_button_pressed(mb_left)) {
            switch (obj_demo.demo_mode) {
                case EOperationModes.SELECTION:
                    picker.palette_index = index;
                    picker.value = obj_demo.demo_palette.data[obj_demo.demo_palette_index][index];
                    picker.ShowPickerDialog().SetActiveShade(0);
                    break;
                case EOperationModes.EYEDROPPER:
                    obj_demo.demo_copied_color = obj_demo.demo_palette.data[obj_demo.demo_palette_index][index];
                    var color_string = string(ptr(obj_demo.demo_copied_color));
                    var rr = string_copy(color_string, string_length(color_string) - 1, 2);
                    var gg = string_copy(color_string, string_length(color_string) - 3, 2);
                    var bb = string_copy(color_string, string_length(color_string) - 5, 2);
                    clipboard_set_text(rr + gg + bb);
                    break;
                case EOperationModes.BUCKET:
                    if (obj_demo.demo_palette.data[obj_demo.demo_palette_index][index] != obj_demo.demo_copied_color) {
                        obj_demo.demo_palette.Modify(index, obj_demo.demo_palette_index, obj_demo.demo_copied_color);
                    }
                    break;
            }
        }
    }, function() {
        // create
    }),
    new EmuButton(32 + 32 + 32 + ew + 762, EMU_AUTO, 384 / 2, eh, "Shift Left", function() {
        var data = obj_demo.demo_palette.data[obj_demo.demo_palette_index];
        var value0 = data[0];
        array_delete(data, 0, 1);
        array_push(data, -1);
        for (var i = 0, n = array_length(data); i < n; i++) {
            if (data[i] == -1) {
                data[i] = value0;
                break;
            }
        }
        obj_demo.demo_palette.Refresh();
    }),
    new EmuButton(32 + 32 + 32 + ew + 762 + 384 / 2, EMU_INLINE, 384 / 2, eh, "Shift Right", function() {
        var data = obj_demo.demo_palette.data[obj_demo.demo_palette_index];
        for (var i = array_length(data) - 1; i >= 0; i--) {
            if (data[i] != -1) {
                array_insert(data, 0, data[i]);
                array_delete(data, i + 1, 1);
                break;
            }
        }
        obj_demo.demo_palette.Refresh();
    }),
    new EmuButton(32 + 32 + 32 + ew + 762, EMU_AUTO, 384 / 2, eh, "Hue/Sat/Value", function() {
        var ew = 480;
        var eh = 32;
        var dialog = (new EmuDialog(32 + 32 + 480, 360, "Hue/Saturation/Value")).AddContent([
            new EmuText(32, EMU_AUTO, ew, eh, "Hue: +0")
                .SetID("HUE"),
            new EmuProgressBar(32, EMU_AUTO, ew, eh, 8, -180, 180, true, 0, function() {
                self.GetSibling("HUE").text = "Hue: " + ((self.value > 0) ? "+" : "") + string(round(self.value));
                self.root.stored_hue = self.value;
                self.root.UpdateColors();
            }),
            new EmuText(32, EMU_AUTO, ew, eh, "Saturation: +0")
                .SetID("SAT"),
            new EmuProgressBar(32, EMU_AUTO, ew, eh, 8, -255, 255, true, 0, function() {
                self.GetSibling("SAT").text = "Saturation: " + ((self.value > 0) ? "+" : "") + string(round(self.value));
                self.root.stored_sat = self.value;
                self.root.UpdateColors();
            }),
            new EmuText(32, EMU_AUTO, ew, eh, "Value: +0")
                .SetID("VAL"),
            new EmuProgressBar(32, EMU_AUTO, ew, eh, 8, -255, 255, true, 0, function() {
                self.GetSibling("VAL").text = "Value: " + ((self.value > 0) ? "+" : "") + string(round(self.value));
                self.root.stored_val = self.value;
                self.root.UpdateColors();
            }),
        ]).AddDefaultConfirmCancelButtons("Done", function() {
            self.root.Close();
        }, "Cancel", function() {
            obj_demo.demo_palette.data[obj_demo.demo_palette_index] = self.root.original_data;
            obj_demo.demo_palette.Refresh();
            self.root.Close();
        });
        
        dialog.palette_data = obj_demo.demo_palette.data[obj_demo.demo_palette_index];
        dialog.original_data = json_parse(json_stringify(obj_demo.demo_palette.data[obj_demo.demo_palette_index]));
        dialog.stored_hue = 0;
        dialog.stored_sat = 0;
        dialog.stored_val = 0;
        
        dialog.UpdateColors = method(dialog, function() {
            for (var i = 0, n = array_length(self.original_data); i < n; i++) {
                var cc = self.original_data[i];
                var hh = (colour_get_hue(cc) + self.stored_hue + 255) % 255;
                var ss = clamp(colour_get_saturation(cc) + self.stored_sat - self.stored_val, 0, 255);
                var vv = clamp(colour_get_value(cc) + self.stored_val, 0, 255);
                self.palette_data[i] = make_colour_hsv(hh, ss, vv);
            }
            
            obj_demo.demo_palette.Refresh();
        });
    }),
    new EmuButton(32 + 32 + 32 + ew + 762 + 384 / 2, EMU_INLINE, 384 / 2, eh, "Color Channels", function() {
        var ew = 480;
        var eh = 32;
        var dialog = (new EmuDialog(32 + 32 + 480, 360, "Color Channels")).AddContent([
            new EmuText(32, EMU_AUTO, ew, eh, "Red: +0")
                .SetID("R"),
            new EmuProgressBar(32, EMU_AUTO, ew, eh, 8, -255, 255, true, 0, function() {
                self.GetSibling("R").text = "Red: " + ((self.value > 0) ? "+" : "") + string(round(self.value));
                self.root.stored_r = self.value;
                self.root.UpdateColors();
            }),
            new EmuText(32, EMU_AUTO, ew, eh, "Green: +0")
                .SetID("G"),
            new EmuProgressBar(32, EMU_AUTO, ew, eh, 8, -255, 255, true, 0, function() {
                self.GetSibling("B").text = "Green: " + ((self.value > 0) ? "+" : "") + string(round(self.value));
                self.root.stored_g = self.value;
                self.root.UpdateColors();
            }),
            new EmuText(32, EMU_AUTO, ew, eh, "Blue: +0")
                .SetID("B"),
            new EmuProgressBar(32, EMU_AUTO, ew, eh, 8, -255, 255, true, 0, function() {
                self.GetSibling("B").text = "Blue: " + ((self.value > 0) ? "+" : "") + string(round(self.value));
                self.root.stored_b = self.value;
                self.root.UpdateColors();
            }),
        ]).AddDefaultConfirmCancelButtons("Done", function() {
            self.root.Close();
        }, "Cancel", function() {
            obj_demo.demo_palette.data[obj_demo.demo_palette_index] = self.root.original_data;
            obj_demo.demo_palette.Refresh();
            self.root.Close();
        });
        
        dialog.palette_data = obj_demo.demo_palette.data[obj_demo.demo_palette_index];
        dialog.original_data = json_parse(json_stringify(obj_demo.demo_palette.data[obj_demo.demo_palette_index]));
        dialog.stored_r = 0;
        dialog.stored_g = 0;
        dialog.stored_b = 0;
        
        dialog.UpdateColors = method(dialog, function() {
            for (var i = 0, n = array_length(self.original_data); i < n; i++) {
                var cc = self.original_data[i];
                var rr = clamp(colour_get_red(cc) + self.stored_r, 0, 255);
                var gg = clamp(colour_get_green(cc) + self.stored_g, 0, 255);
                var bb = clamp(colour_get_blue(cc) + self.stored_b, 0, 255);
                self.palette_data[i] = make_colour_rgb(rr, gg, bb);
            }
            
            obj_demo.demo_palette.Refresh();
        });
    }),
]);