#macro DEBUG                        (os_get_config() == "debug")
#macro DEMO_PLAY_SPEED_FPS          8
#macro C_BUTTON_SELECTED            c_yellow
#macro SAVE_FILE_AUTOMATION         (game_save_id + "automation.json")
#macro SAVE_FILE_AUTOMATION_DEF     "automation-defaults.json"

scribble_font_bake_outline_8dir("fnt_emu_default", "fnt_emu_default_outline", c_black, false);

self.demo_sprite = sprite_duplicate(spr_test_sprite);                               // source sprite
self.demo_palette = new LorikeetPaletteManager();                                   // palette data
var t0 = get_timer();
self.demo_sprite_indexed = self.demo_palette.ExtractPalette(self.demo_sprite);      // indexed color sprite
var starting_extraction_time = (get_timer() - t0) / 1000;

self.demo_palette_index = 0;                                                        // palette index
self.demo_palette_speed = 0;                                                        // palette playback speed
self.demo_sprite_type = 1;                                                          // display type
self.demo_force_full_palettes = false;                                              // extract a palette of size 256?
self.demo_highlight_selection = true;                                               // show the dither pattern on the selected color?

self.demo_mode = EOperationModes.SELECTION;

enum EOperationModes {
    SELECTION,
    EYEDROPPER,
    BUCKET,
}

self.demo_copied_color = 0xff000000;
self.demo_edit_cell = -1;

self.automations = new LorikeetAutomation();
try {
    var buffer = buffer_load(SAVE_FILE_AUTOMATION);
    var buffer_content = buffer_read(buffer, buffer_text);
    buffer_delete(buffer);
    self.automations.Load(json_parse(buffer_content));
} catch (e) {
    try {
        self.automations = new LorikeetAutomation();
        var buffer = buffer_load(SAVE_FILE_AUTOMATION_DEF);
        var buffer_content = buffer_read(buffer, buffer_text);
        buffer_delete(buffer);
        self.automations.Load(json_parse(buffer_content));
    } catch (e) {
        // if the defaults file is corrupted, just give up
        self.automations = new LorikeetAutomation();
    }
}

self.LoadSprite = function(fn = undefined) {
    fn ??= get_open_filename("Image files|*.png;*.bmp", "");
    
    if (file_exists(fn)) {
        var image = sprite_add(fn, 0, false, false, 0, 0);
        
        if (sprite_exists(image)) {
            var t0 = get_timer();
            sprite_delete(self.demo_sprite);
            self.demo_sprite = image;
            self.demo_sprite_indexed = self.demo_palette.ExtractPalette(image, 0, self.demo_force_full_palettes);
            self.demo_palette_index = 0;
            self.demo_edit_cell = -1;
            return (get_timer() - t0) / 1000;
        }
    }
    
    return undefined;
};

self.ReExtract = function() {
    var t0 = get_timer();
    self.demo_sprite_indexed = self.demo_palette.ExtractPalette(self.demo_sprite, 0, self.demo_force_full_palettes);
    self.demo_palette_index = 0;
    self.demo_edit_cell = -1;
    return (get_timer() - t0) / 1000;
};

self.ResetSprite = function() {
    var t0 = get_timer();
    sprite_delete(self.demo_sprite);
    self.demo_sprite = sprite_duplicate(spr_test_sprite);
    self.demo_sprite_indexed = self.demo_palette.ExtractPalette(self.demo_sprite, 0, self.demo_force_full_palettes);
    self.demo_palette_index = 0;
    self.demo_edit_cell = -1;
    return (get_timer() - t0) / 1000;
};

self.LoadPalette = function() {
    var fn = get_open_filename("Image files|*.png;*.bmp", "");
    if (file_exists(fn)) {
        var image = sprite_add(fn, 0, false, false, 0, 0);
        
        if (sprite_exists(image)) {
            self.demo_palette.FromImage(image);
            self.demo_palette_index = 0;
            self.demo_edit_cell = -1;
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
        sprite_save(self.demo_palette.palette, 0, fn);
    }
};

self.SaveAutomation = function() {
    var save_buffer = buffer_create(1024, buffer_grow, 1);
    buffer_write(save_buffer, buffer_text, json_stringify(self.automations.Save()));
    buffer_save(save_buffer, SAVE_FILE_AUTOMATION);
    buffer_delete(save_buffer);
};

self.SaveFullSprite = function(index = -1) {
    var fn = get_save_filename("Image files|*.png", "");
    if (fn != "") {
        if (index != -1) {
            var sprite = self.demo_palette.GetRGBSprite(self.demo_sprite_indexed, index);
            sprite_save(sprite, 0, fn);
            sprite_delete(sprite);
        } else {
            for (var i = 0, n = array_length(self.demo_palette.data); i < n; i++) {
                var sprite = self.demo_palette.GetRGBSprite(self.demo_sprite_indexed, i);
                sprite_save(sprite, 0, fn + "_" + string(i) + ".png");
                sprite_delete(sprite);
            }
        }
    }
};

self.SaveRGBSpriteOrSlices = function() {
    var dw = 1280;
    var dh = 720;
    var ew = 320;
    var eh = 32;
    var c1 = 32;
    var c2 = 32 + ew + 32;
    
    io_clear();
    
    new EmuDialog(dw, dh, "Save RGB Sprite or Slices")
        .AddContent([
            new EmuButton(c1, EMU_AUTO, ew, eh, "Save RGB Sprite", function() {
                obj_demo.SaveFullSprite(obj_demo.demo_palette_index);
            }),
            new EmuButton(c1, EMU_AUTO, ew, eh, "Save All RGB Sprites...", function() {
                obj_demo.SaveFullSprite();
            }),
			new EmuRenderSurfaceZoom(c2, EMU_BASE, dw - 32 - c2, dh - 32 - 64, function(mx, my) {
			    
			}, function(mx, my) {
				
			})
        ])
        .AddDefaultCloseButton();
};

self.ShowAllSaveOptions = function() {
    var dw = 1440;
    var dh = 800;
    var ew = 320;
    var eh = 32;
    var c1 = 32;
    var c2 = 32 + ew + 32;
    
	// palette list
    var palw = 320;
    var palh = 160;
    // slice viewer
    var slicew = 320;
    var sliceh = 120;
    // slice cutter
    var cutw = dw - c2 - 32;
    var cuth = dh - 32 - 64;
    
    io_clear();
    
    new EmuDialog(dw, dh, "All Save Options")
        .AddContent([
            new EmuText(c1, EMU_BASE, ew, eh, "[c_aqua]Slices"),
            new EmuInput(c1, EMU_AUTO, ew, eh, "Slice width:", string(self.slice_width), "The width of each of the sliced sprites", 3, E_InputTypes.INT, function() {
                obj_demo.slice_width = real(self.value);
    			//obj_demo.SaveSettingsFile();
            })
                .SetRealNumberBounds(8, 512)
                .SetID("SLICE W")
                .SetNext("SLICE H")
                .SetPrevious("SLICE H"),
            new EmuInput(c1, EMU_AUTO, ew, eh, "Slice height:", string(self.slice_height), "The height of each of the sliced sprites", 3, E_InputTypes.INT, function() {
                obj_demo.slice_height = real(self.value);
    			//obj_demo.SaveSettingsFile();
            })
                .SetRealNumberBounds(8, 512)
                .SetID("SLICE H")
                .SetNext("SLICE W")
                .SetPrevious("SLICE W"),
            new EmuButton(c1, EMU_AUTO, ew, eh, "Clear", function() {
                obj_demo.ClearSpriteSlices();
            }),
            new EmuButton(c1, EMU_AUTO, ew / 2, eh, "Flip X", function() {
                obj_demo.FlipHorizontally();
            }),
            new EmuButton(c1 + ew / 2, EMU_INLINE, ew / 2, eh, "Flip Y", function() {
                obj_demo.FlipVertically();
            }),
            new EmuCheckbox(c1, EMU_AUTO, ew, eh, "Auto crop?", self.auto_crop, function() {
                obj_demo.auto_crop = self.value;
            }),
            new EmuText(c1, EMU_AUTO, ew, eh, "Palette index:"),
            new EmuRenderSurfacePalettePicker(c1, EMU_AUTO, palw, palh),
            new EmuText(c1, EMU_AUTO, ew, eh, "Slices:"),
            new EmuRenderSurfaceSliceViewer(c1, EMU_AUTO, slicew, sliceh),
            new EmuRenderSurfaceSliceCutter(c2, EMU_BASE, cutw, cuth)
        ])
        .AddDefaultCloseButton()
        .CenterInWindow();
};

self.slices = [];
self.slice_width = 32;
self.slice_height = 32;
self.auto_crop = false;

self.AddSpriteSlice = function(x, y, w, h) {
    array_push(self.slices, new SpriteSliceData(x, y, w, h));
};

self.DeleteSpriteSlice = function(index) {
    array_delete(self.slices, index, 1);
};

self.ClearSpriteSlices = function() {
    self.slices = [];
};

self.FlipHorizontally = function() {
	array_foreach(self.slices, function(item) {
		item.flipped_h = !item.flipped_h;
	});
};

self.FlipVertically = function() {
	array_foreach(self.slices, function(item) {
		item.flipped_v = !item.flipped_v;
	});
};

var ew = 320;
var eh = 32;

self.ui = (new EmuCore(0, 0, window_get_width(), window_get_height())).AddContent([
    new EmuText(32, EMU_AUTO, ew, eh, "[c_aqua]Lorikeet Palette Extraction"),
    new EmuButton(32, EMU_AUTO, ew / 2, eh, "Load Sprite", function() {
        obj_demo.LoadSprite();
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
    new EmuButton(32, EMU_AUTO, ew / 2, eh, "Save RGB or Slices", function() {
        obj_demo.ShowAllSaveOptions();
    }),
    new EmuButton(32 + ew / 2, EMU_INLINE, ew / 2, eh, "Process Folder", function() {
        //obj_demo.ProcessFolder();
    }),
    new EmuButton(32, EMU_AUTO, ew / 2, eh, "Reset Sprite", function() {
        obj_demo.ResetSprite();
    }),
    new EmuButton(32 + ew / 2, EMU_INLINE, ew / 2, eh, "Reset Palette", function() {
        obj_demo.ReExtract();
    }),
    new EmuCheckbox(32, EMU_AUTO, ew, eh, "Extract full palettes?", self.demo_force_full_palettes, function() {
        obj_demo.demo_force_full_palettes = self.value;
        obj_demo.ReExtract();
    }),
    new EmuCheckbox(32, EMU_AUTO, ew, eh, "Highlight selection?", self.demo_highlight_selection, function() {
        obj_demo.demo_highlight_selection = self.value;
    }),
    new EmuRadioArray(32, EMU_AUTO, ew, eh, "Display type:", self.demo_sprite_type, function() {
        obj_demo.demo_sprite_type = self.value;
    })
        .AddOptions(["Original", "Applied", "Indexed"])
        .SetColumns(2, ew / 2),
    new EmuRenderSurfacePalettePicker(32, EMU_AUTO, ew, ew),
    (new EmuButton(32, EMU_AUTO, ew / 3, eh, "Add row", function() {
        obj_demo.demo_palette.AddPaletteRow(obj_demo.demo_palette_index);
    })),
    (new EmuButton(32 + ew / 3, EMU_INLINE, ew / 3, eh, "Delete row", function() {
        obj_demo.demo_palette.RemovePaletteRow(obj_demo.demo_palette_index);
        obj_demo.demo_palette_index = min(obj_demo.demo_palette_index, array_length(obj_demo.demo_palette.data) - 1);
        obj_demo.demo_edit_cell = -1;
    })),
    (new EmuButton(32 + 2 * ew / 3, EMU_INLINE, ew / 3, eh, "Auto", emu_dialog_show_automation)),
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
	// main image
    new EmuRenderSurface(32 + 32 + ew, EMU_BASE, 762, 836, function(mx, my, screenmx, screenmy) {
        // render
        draw_clear_alpha(c_black, 0);
        
        switch (obj_demo.demo_sprite_type) {
            case 0:
                // skips the paint bucket feature
                draw_sprite_tiled(spr_palette_checker, 0, 0, 0);
                draw_sprite_ext(obj_demo.demo_sprite, 0, 0, 0, 1, 1, 0, c_white, 1);
                return;
            case 1:
                draw_sprite_ext(obj_demo.demo_sprite_indexed, 0, 0, 0, 1, 1, 0, c_white, 1);
                break;
            case 2:
                // skips the paint bucket feature
                draw_sprite_tiled(spr_palette_checker, 0, 0, 0);
                draw_sprite_ext(obj_demo.demo_sprite_indexed, 0, 0, 0, 1, 1, 0, c_white, 1);
                return;
        }
        
        var index_under_cursor = -1000;
        
        if (self.MouseOverCanvas(mx, my)) {
            if (mouse_check_button(mb_right)) {
                obj_demo.demo_edit_cell = -1;
            }
            
            var c = surface_getpixel_ext(self.surface, screenmx, screenmy);
            var idx = colour_get_red(c);
            var g = colour_get_green(c);
            var b = colour_get_blue(c);
            var a = int64(c) >> 24;
            
            if (a > 0) {
                var palette = obj_demo.demo_palette.data[obj_demo.demo_palette_index];
                index_under_cursor = idx / 256 * array_length(palette);
                
                if (mouse_check_button(mb_left)) {
                    switch (obj_demo.demo_mode) {
                        case EOperationModes.SELECTION:
                            obj_demo.demo_edit_cell = index_under_cursor;
                            break;
                        case EOperationModes.EYEDROPPER:
                            obj_demo.demo_copied_color = obj_demo.demo_palette.data[obj_demo.demo_palette_index][index_under_cursor];
                            break;
                        case EOperationModes.BUCKET:
                            obj_demo.demo_palette.Modify(index_under_cursor, obj_demo.demo_palette_index, obj_demo.demo_copied_color);
                            break;
                    }
                }
            }
        }
        
        if (index_under_cursor == -1000 && obj_demo.demo_edit_cell != -1) {
            index_under_cursor = obj_demo.demo_edit_cell;
        }
        
        draw_clear_alpha(c_black, 0);
        
        // after the color has been sampled, do it again
        lorikeet_set(obj_demo.demo_palette.palette, obj_demo.demo_palette_index, 0, shd_lorikeet_preview);
        shader_set_uniform_f(shader_get_uniform(shd_lorikeet_preview, "u_IndexUnderCursor"), obj_demo.demo_highlight_selection ? index_under_cursor : -100);
        shader_set_uniform_f(shader_get_uniform(shd_lorikeet_preview, "u_IndexCount"), array_length(obj_demo.demo_palette.data[0]));
        draw_sprite(obj_demo.demo_sprite_indexed, 0, 0, 0);
        shader_reset();
        
        draw_rectangle_colour(0, 0, sprite_get_width(obj_demo.demo_sprite_indexed) - 1, sprite_get_height(obj_demo.demo_sprite_indexed) - 1, c_black, c_black, c_black, c_black, true);
    }, emu_null, emu_null)
        .SetRenderBegin(function(mx, my) {
            draw_sprite_tiled(spr_palette_checker, 0, 0, 0);
        })
        .SetRenderUI(function(mx, my) {
            // color picker
            draw_clear_alpha(c_black, 0);
            
            var size = 64;
            draw_set_alpha((obj_demo.demo_copied_color >> 24) / 0xff);
            draw_rectangle_colour(1, self.height - size + 1, size - 1, self.height - 1, obj_demo.demo_copied_color, obj_demo.demo_copied_color, obj_demo.demo_copied_color, obj_demo.demo_copied_color, false);
            draw_set_alpha(1);
            draw_sprite_stretched(spr_tile_selector, 0, 1, self.height - size + 1, size - 2, size - 2);
            draw_sprite(spr_modes, 2, size / 2, self.height - size / 2);
            
            static picker = new EmuColorPicker(0, 0, 0, 0, "", 0xff000000, function() {
                obj_demo.demo_copied_color = self.value;
            })
                .SetAlphaUsed(true);
            
            if (mx > 1 && my > self.height - size + 1 && mx < size - 1 && my < self.height - 1) {
                if (mouse_check_button_pressed(mb_left)) {
                    picker.value = obj_demo.demo_copied_color;
                    picker.ShowPickerDialog().SetActiveShade(0);
                }
                set_cursor_sprite_auto();
            }
            
            draw_set_font(fnt_emu_default_sdf);
            draw_text(32, 20, "Middle mouse button to pan");
            draw_text(32, 48, "Middle wheel to zoom");
        })
		.SetPanEnabled(true)
		.SetZoomEnabled(true, 1, 16)
		.SetZoom(8),
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
	// palette contents
    new EmuRenderSurface(32 + 32 + 32 + ew + 762, EMU_AUTO, 384, 384, function(mx, my) {
        // render
        var palette = obj_demo.demo_palette.data[obj_demo.demo_palette_index];
        
        draw_sprite_tiled(spr_palette_checker, 0, 0, 0);
        
        var step = 24;
        var hcells = self.width div step;
        var index = -1;
        
        for (var i = 0, n = array_length(palette); i < n; i++) {
            var c = palette[i];
            if (c == -1) break;
            var xx = (i % hcells);
            var yy = (i div hcells);
            draw_set_alpha((c >> 24) / 0xff);
            draw_rectangle_color(xx * step, yy * step, (xx + 1) * step, (yy + 1) * step, c, c, c, c, false);
        }
        
        draw_set_alpha(1);
        
        var mouse_in_view = (mx >= 0 && mx <= self.width && my >= 0 && my <= self.height);
        if (mouse_in_view) {
            var mcx = mx div step;
            var mcy = my div step;
            index = min(mcy * hcells + mcx, array_length(palette) - 1);
            mcx = index % hcells;
            mcy = index div hcells;
            
            draw_sprite_stretched(spr_tile_selector, 0, mcx * step, mcy * step, step, step);
        }
        
        if (index != obj_demo.demo_edit_cell && obj_demo.demo_edit_cell != -1) {
            mcx = obj_demo.demo_edit_cell % hcells;
            mcy = obj_demo.demo_edit_cell div hcells;
            draw_sprite_stretched(spr_tile_selector, 0, mcx * step, mcy * step, step, step);
        }
        
        var max_row = ceil(array_length(palette) / hcells);
        var max_column = array_length(palette) % hcells;
        
        draw_set_alpha(0.5);
        if (max_column > 0) {
            draw_rectangle_colour(max_column * step, (max_row - 1) * step, self.width, max_row * step, c_black, c_black, c_black, c_black, false);
        }
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
        
        var step = 24;
        var hcells = self.width div step;
        var mcx = mx div step;
        var mcy = my div step;
        var index = min(mcy * hcells + mcx, array_length(obj_demo.demo_palette.data[obj_demo.demo_palette_index]) - 1);
        
        if (mouse_check_button_pressed(mb_left)) {
            switch (obj_demo.demo_mode) {
                case EOperationModes.SELECTION:
                    if (obj_demo.demo_edit_cell == index) {
                        picker.palette_index = index;
                        picker.value = obj_demo.demo_palette.data[obj_demo.demo_palette_index][index];
                        picker.ShowPickerDialog().SetActiveShade(0);
                    } else {
                        obj_demo.demo_edit_cell = index;
                    }
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
        
        set_cursor_sprite_auto();
    }, function() {
        // create
    }),
    new EmuButton(32 + 32 + 32 + ew + 762, EMU_AUTO, 384 / 2, eh, "Shift Left", function() {
        var data = obj_demo.demo_palette.data[obj_demo.demo_palette_index];
        operation_shift_left(data);
        obj_demo.demo_palette.Refresh();
    }),
    new EmuButton(32 + 32 + 32 + ew + 762 + 384 / 2, EMU_INLINE, 384 / 2, eh, "Shift Right", function() {
        var data = obj_demo.demo_palette.data[obj_demo.demo_palette_index];
        operation_shift_right(data);
        obj_demo.demo_palette.Refresh();
    }),
    new EmuButton(32 + 32 + 32 + ew + 762, EMU_AUTO, 384 / 2, eh, "Hue/Sat/Value", function() {
        var ew = 480;
        var eh = 32;
        var dialog = (new EmuDialog(32 + 32 + 480, 360, "Hue/Saturation/Value")).AddContent([
            new EmuInput(32, EMU_AUTO, ew, eh, "Hue:", "0", "-180...+180", 7, E_InputTypes.REAL, function() {
                var val = clamp(real(self.value), -180, 180);
                self.root.stored_hue = val;
                self.GetSibling("H BAR").value = val;
                self.root.UpdateColors();
                if (string(val) != self.value) self.SetValue(val);
            })
                .SetNext("SAT").SetPrevious("VAL")
                .SetRealNumberBounds(-999999, 9999999)
                .SetID("HUE"),
            new EmuProgressBar(32, EMU_AUTO, ew, eh, 8, -180, 180, true, 0, function() {
                self.GetSibling("HUE").SetValue(self.value);
                self.root.stored_hue = self.value;
                self.root.UpdateColors();
            })
                .SetID("H BAR"),
            new EmuInput(32, EMU_AUTO, ew, eh, "Saturation:", "0", "-255...+255", 7, E_InputTypes.REAL, function() {
                var val = clamp(real(self.value), -255, 255);
                self.root.stored_sat = val;
                self.GetSibling("S BAR").value = val;
                self.root.UpdateColors();
                if (string(val) != self.value) self.SetValue(val);
            })
                .SetNext("VAL").SetPrevious("HUE")
                .SetRealNumberBounds(-999999, 9999999)
                .SetID("SAT"),
            new EmuProgressBar(32, EMU_AUTO, ew, eh, 8, -255, 255, true, 0, function() {
                var val = clamp(real(self.value), -255, 255);
                self.GetSibling("SAT").SetValue(self.value);
                self.root.stored_sat = self.value;
                self.root.UpdateColors();
                if (string(val) != self.value) self.SetValue(val);
            })
                .SetID("S BAR"),
            new EmuInput(32, EMU_AUTO, ew, eh, "Value:", "0", "-255...+255", 7, E_InputTypes.REAL, function() {
                var val = clamp(real(self.value), -255, 255);
                self.root.stored_val = val;
                self.GetSibling("V BAR").value = val;
                self.root.UpdateColors();
            })
                .SetNext("HUE").SetPrevious("SAT")
                .SetRealNumberBounds(-999999, 9999999)
                .SetID("VAL"),
            new EmuProgressBar(32, EMU_AUTO, ew, eh, 8, -255, 255, true, 0, function() {
                self.GetSibling("VAL").SetValue(self.value);
                self.root.stored_val = self.value;
                self.root.UpdateColors();
            })
                .SetID("V BAR"),
        ])
        .SetActiveShade(0)
        .AddDefaultConfirmCancelButtons("Done", function() {
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
            array_copy(self.palette_data, 0, self.original_data, 0, array_length(self.original_data));
            operation_update_hsv(self.palette_data, self.stored_hue, self.stored_sat, self.stored_val);
            obj_demo.demo_palette.Refresh();
        });
    }),
    new EmuButton(32 + 32 + 32 + ew + 762 + 384 / 2, EMU_INLINE, 384 / 2, eh, "Color Channels", function() {
        var ew = 480;
        var eh = 32;
        var dialog = (new EmuDialog(32 + 32 + 480, 360, "Color Channels")).AddContent([
            new EmuInput(32, EMU_AUTO, ew, eh, "Red:", "0", "-255...+255", 7, E_InputTypes.REAL, function() {
                var val = clamp(real(self.value), -255, 255);
                self.root.stored_r = val;
                self.GetSibling("R BAR").value = val;
                self.root.UpdateColors();
                if (string(val) != self.value) self.SetValue(val);
            })
                .SetNext("G").SetPrevious("B")
                .SetRealNumberBounds(-999999, 9999999)
                .SetID("R"),
            new EmuProgressBar(32, EMU_AUTO, ew, eh, 8, -255, 255, true, 0, function() {
                self.GetSibling("R").SetValue(self.value);
                self.root.stored_r = self.value;
                self.root.UpdateColors();
            })
                .SetID("R BAR"),
            new EmuInput(32, EMU_AUTO, ew, eh, "Green:", "0", "-255...+255", 7, E_InputTypes.REAL, function() {
                var val = clamp(real(self.value), -255, 255);
                self.root.stored_g = val;
                self.GetSibling("G BAR").value = val;
                self.root.UpdateColors();
                if (string(val) != self.value) self.SetValue(val);
            })
                .SetNext("B").SetPrevious("R")
                .SetRealNumberBounds(-999999, 9999999)
                .SetID("G"),
            new EmuProgressBar(32, EMU_AUTO, ew, eh, 8, -255, 255, true, 0, function() {
                self.GetSibling("G").SetValue(self.value);
                self.root.stored_g = self.value;
                self.root.UpdateColors();
            })
                .SetID("G BAR"),
            new EmuInput(32, EMU_AUTO, ew, eh, "Blue:", "0", "-255...+255", 7, E_InputTypes.REAL, function() {
                var val = clamp(real(self.value), -255, 255);
                self.root.stored_b = val;
                self.GetSibling("B BAR").value = val;
                self.root.UpdateColors();
                if (string(val) != self.value) self.SetValue(val);
            })
                .SetNext("R").SetPrevious("G")
                .SetRealNumberBounds(-999999, 9999999)
                .SetID("B"),
            new EmuProgressBar(32, EMU_AUTO, ew, eh, 8, -255, 255, true, 0, function() {
                self.GetSibling("B").SetValue(self.value);
                self.root.stored_b = self.value;
                self.root.UpdateColors();
            })
                .SetID("B BAR"),
        ])
        .SetActiveShade(0)
        .AddDefaultConfirmCancelButtons("Done", function() {
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
            array_copy(self.palette_data, 0, self.original_data, 0, array_length(self.original_data));
            operation_update_rgb(self.palette_data, self.stored_r, self.stored_g, self.stored_b);
            obj_demo.demo_palette.Refresh();
        });
    }),
    new EmuButton(32 + 32 + 32 + ew + 762/* + 384 / 2*/, EMU_AUTO, 384 / 2, eh, "Generate Outline", function() {
        var ew = 480;
        var eh = 32;
        
        var palette_length = array_length(obj_demo.demo_palette.data[obj_demo.demo_palette_index]);
        
        if (palette_length == 256) {
            new EmuDialog(ew, 240, "Hey!")
                .AddContent([
                    new EmuText(32, eh / 3, ew - 32 - 32, 160, "Automatic outlines are only available if the palette has fewer than 256 colors")
                        .SetAlign(fa_center, fa_middle)
                ])
                .AddDefaultCloseButton()
                .CenterInWindow();
        } else {
            var dialog = new EmuDialog(32 + 32 + ew, 240, "Generate Outline")
                .SetActiveShade(0)
                .CenterInWindow()
                .AddContent([
                    new EmuColorPicker(32, EMU_AUTO, ew, eh, "Outline color:", 0xff000000, function() {
                        self.root.outline_color = self.value;
                        self.root.palette_data[self.root.outline_index] = self.value;
                        var palette = obj_demo.demo_palette;
                        for (var i = 0, n = array_length(palette.data); i < n; i++) {
                            palette.data[i][self.root.outline_index] = self.value;
                        }
                        palette.RegeneratePaletteFromData();
                    })
                        .SetAlphaUsed(true),
                    new EmuCheckbox(32, EMU_AUTO, ew, eh, "Corner outlines?", true, function() {
                        obj_demo.demo_sprite_indexed = self.value ? self.root.index_with_diagonals : self.root.index_without_diagonals;
                    })
                ])
                .SetCloseButton(false)
                .AddDefaultConfirmCancelButtons("Done", function() {
                    if (self.root.original_indexed_sprite != obj_demo.demo_sprite_indexed) {
                        sprite_delete(self.root.original_indexed_sprite);
                    }
                    if (self.root.index_with_diagonals != obj_demo.demo_sprite_indexed && sprite_exists(self.root.index_with_diagonals)) {
                        sprite_delete(self.root.index_with_diagonals);
                    }
                    if (self.root.index_without_diagonals != obj_demo.demo_sprite_indexed && sprite_exists(self.root.index_without_diagonals)) {
                        sprite_delete(self.root.index_without_diagonals);
                    }
                    self.root.Close();
                }, "Cancel", function() {
                    obj_demo.demo_palette.data[obj_demo.demo_palette_index] = self.root.original_data;
                    obj_demo.demo_palette.palette_used_size = self.root.original_used_size;
                    obj_demo.demo_palette.Refresh();
                    if (self.root.original_indexed_sprite != obj_demo.demo_sprite_indexed) {
                        sprite_delete(obj_demo.demo_sprite_indexed);
                        obj_demo.demo_sprite_indexed = self.root.original_indexed_sprite;
                    }
                    if (self.root.index_with_diagonals != obj_demo.demo_sprite_indexed && sprite_exists(self.root.index_with_diagonals)) {
                        sprite_delete(self.root.index_with_diagonals);
                    }
                    if (self.root.index_without_diagonals != obj_demo.demo_sprite_indexed && sprite_exists(self.root.index_without_diagonals)) {
                        sprite_delete(self.root.index_without_diagonals);
                    }
                    self.root.Close();
                });
        
            dialog.outline_color = 0xff000000;
            dialog.outline_index = obj_demo.demo_palette.palette_used_size;
            dialog.palette_data = obj_demo.demo_palette.data[obj_demo.demo_palette_index];
            dialog.original_data = variable_clone(obj_demo.demo_palette.data[obj_demo.demo_palette_index]);
            dialog.original_used_size = obj_demo.demo_palette.palette_used_size;
            dialog.original_indexed_sprite = obj_demo.demo_sprite_indexed;
            
            var old_size = array_length(obj_demo.demo_palette.data[obj_demo.demo_palette_index]);
            obj_demo.demo_palette.AddPaletteColor(dialog.outline_color);
            var new_size = array_length(obj_demo.demo_palette.data[obj_demo.demo_palette_index]);
            
            if (new_size != old_size) {
                var new_demo_sprite = index_extend_colors(obj_demo.demo_sprite_indexed, 0);
                obj_demo.demo_sprite_indexed = new_demo_sprite;
            }
            
            dialog.index_without_diagonals = index_generate_outlines(obj_demo.demo_sprite_indexed, dialog.outline_index / array_length(dialog.palette_data), false);
            dialog.index_with_diagonals = index_generate_outlines(obj_demo.demo_sprite_indexed, dialog.outline_index / array_length(dialog.palette_data), true);
             
            obj_demo.demo_sprite_indexed = dialog.index_with_diagonals;
        }
    })
]);

self.ui.DroppedFileHandler = method(self.ui, function(files) {
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
});

font_enable_effects(fnt_emu_default_sdf, true, {
    outlineEnable: true,
    outlineDistance: 2,
    outlineColour: c_black
});