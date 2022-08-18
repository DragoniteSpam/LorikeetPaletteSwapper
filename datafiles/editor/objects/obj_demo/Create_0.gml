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

self.automations = new LorikeetAutomation();
var type_day_night = self.automations.AddType();
type_day_night.name = "Day/Night Cycle";

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
        sprite_save(self.demo_palette.palette, 0, fn);
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
    new EmuButton(32, EMU_AUTO, ew / 2, eh, "Reset Sprite", function() {
        var load_results = obj_demo.ResetSprite();
        self.GetSibling("TIME").text = "Palette extraction time: " + string(load_results) + " ms";
    }),
    new EmuButton(32 + ew / 2, EMU_INLINE, ew / 2, eh, "Reset Palette", function() {
        var load_results = obj_demo.ReExtract();
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
    (new EmuButton(32, EMU_AUTO, ew / 3, eh, "Add row", function() {
        obj_demo.demo_palette.AddPaletteRow(obj_demo.demo_palette_index);
    })),
    (new EmuButton(32 + ew / 3, EMU_INLINE, ew / 3, eh, "Delete row", function() {
        obj_demo.demo_palette.RemovePaletteRow(obj_demo.demo_palette_index);
        obj_demo.demo_palette_index = min(obj_demo.demo_palette_index, array_length(obj_demo.demo_palette.data) - 1);
    })),
    (new EmuButton(32 + 2 * ew / 3, EMU_INLINE, ew / 3, eh, "Auto", function() {
        var ew = 320;
        var eh = 32;
        var c1 = 32;
        var c2 = 32 + 320 + 32;
        var c3 = 32 + 320 + 32 + 320 + 32;
        var c4 = 32 + 320 + 32 + 320 + 32 + 320 + 32;
        (new EmuDialog(c4 + 320 + 32, 544, "Palette Automation"))
            .AddContent([
                #region column 1
                (new EmuList(c1, EMU_AUTO, ew, eh, "Automation types:", eh, 10, function() {
                    if (!self.root) return;
                    self.root.Refresh({ type: self.GetSelectedItem() });
                }))
                    .SetEntryTypes(E_ListEntryTypes.STRUCTS)
                    .SetList(obj_demo.automations.types)
                    .SetID("TYPE LIST"),
                (new EmuButton(c1 + 0 * ew / 2, EMU_AUTO, ew / 2, eh, "Add Type", function() {
                    obj_demo.automations.AddType();
                }))
                    .SetID("ADD TYPE"),
                (new EmuButton(c1 + 1 * ew / 2, EMU_INLINE, ew / 2, eh, "Delete Type", function() {
                    var index = self.GetSibling("TYPE LIST").GetSelection();
                    obj_demo.automations.RemoveType(index);
                    self.GetSibling("TYPE LIST").ClearSelection();
                }))
                    .SetRefresh(function(data) {
                        if (variable_struct_exists(data, "type")) {
                            self.SetInteractive(!!data.type);
                        }
                    })
                    .SetInteractive(false)
                    .SetID("DELETE TYPE"),
                (new EmuInput(c1, EMU_AUTO, ew, eh, "Name:", "", "Automation name", 16, E_InputTypes.STRING, function() {
                    self.GetSibling("TYPE LIST").GetSelectedItem().name = self.value;
                }))
                    .SetRefresh(function(data) {
                        if (variable_struct_exists(data, "type")) {
                            self.SetInteractive(!!data.type);
                            if (data.type) {
                                self.SetValue(data.type.name);
                            }
                        }
                    })
                    .SetInteractive(false)
                    .SetID("TYPE NAME"),
                #endregion
                #region column 2
                (new EmuList(c2, EMU_BASE, ew, eh, "Palette indices:", eh, 10, function() {
                    if (!self.root) return;
                    self.root.Refresh({ index: self.GetSelectedItem() });
                }))
                    .SetRefresh(function(data) {
                        if (variable_struct_exists(data, "type")) {
                            self.SetInteractive(!!data.type);
                            if (data.type && data.type.indices != self.entries) {
                                self.SetList(data.type.indices);
                            }
                        }
                    })
                    .SetEntryTypes(E_ListEntryTypes.STRUCTS)
                    .SetInteractive(false)
                    .SetID("SLOTS"),
                (new EmuButton(c2 + 0 * ew / 2, EMU_AUTO, ew / 2, eh, "Add index", function() {
                    self.GetSibling("TYPE LIST").GetSelectedItem().AddIndex();
                }))
                    .SetRefresh(function(data) {
                        if (variable_struct_exists(data, "type")) {
                            self.SetInteractive(!!data.type);
                        }
                    })
                    .SetInteractive(false)
                    .SetID("ADD SLOT"),
                (new EmuButton(c2 + 1 * ew / 2, EMU_INLINE, ew / 2, eh, "Delete index", function() {
                    var type = self.GetSibling("TYPE LIST").GetSelectedItem();
                    var index = self.GetSibling("SLOTS").GetSelection();
                    type.RemoveIndex(index);
                    self.GetSibling("SLOTS").ClearSelection();
                }))
                    .SetRefresh(function(data) {
                        if (variable_struct_exists(data, "index")) {
                            self.SetInteractive(!!data.index && (array_length(self.GetSibling("TYPE LIST").GetSelectedItem().indices) > 0));
                        }
                    })
                    .SetInteractive(false)
                    .SetID("DELETE SLOT"),
                (new EmuInput(c2, EMU_AUTO, ew, eh, "Name:", "", "Index name", 16, E_InputTypes.STRING, function() {
                    self.GetSibling("SLOTS").GetSelectedItem().name = self.value;
                }))
                    .SetRefresh(function(data) {
                        if (variable_struct_exists(data, "index")) {
                            self.SetInteractive(!!data.index);
                            if (data.index) {
                                self.SetValue(data.index.name);
                            }
                        }
                    })
                    .SetInteractive(false)
                    .SetID("SLOT NAME"),
                #endregion
                #region column 3
                (new EmuList(c3, EMU_BASE, ew, eh, "Steps:", eh, 10, function() {
                    if (!self.root) return;
                    self.root.Refresh({ step_number: self.GetSelection(), slot: self.GetSibling("SLOTS").GetSelectedItem() });
                    self.GetSibling("SLOT OPERATION TYPE").callback();
                }))
                    .SetRefresh(function(data) {
                        if (variable_struct_exists(data, "index")) {
                            self.SetInteractive(!!data.index);
                            if (data.index && data.index.steps != self.entries) {
                                self.SetList(data.index.steps);
                            }
                        }
                    })
                    .SetEntryTypes(E_ListEntryTypes.STRUCTS)
                    .SetInteractive(false)
                    .SetID("STEPS"),
                (new EmuButton(c3 + 0 * ew / 2, EMU_AUTO, ew / 2, eh, "Add step", function() {
                    var index = self.GetSibling("SLOTS").GetSelectedItem();
                    index.AddStep(index.StepColor);
                }))
                    .SetRefresh(function(data) {
                        if (variable_struct_exists(data, "index")) {
                            self.SetInteractive(!!data.index);
                        }
                    })
                    .SetInteractive(false)
                    .SetID("ADD STEP"),
                (new EmuButton(c3 + 1 * ew / 2, EMU_INLINE, ew / 2, eh, "Delete step", function() {
                    var index = self.GetSibling("SLOTS").GetSelectedItem();
                    var step = self.GetSibling("STEPS").GetSelection();
                    index.RemoveStep(step);
                    self.GetSibling("STEPS").ClearSelection();
                }))
                    .SetRefresh(function(data) {
                        self.SetInteractive(false);
                        if (variable_struct_exists(data, "step_number")) {
                            self.SetInteractive(data.step_number > -1 && (array_length(self.GetSibling("SLOTS").GetSelectedItem().steps) > 0));
                        }
                    })
                    .SetInteractive(false)
                    .SetID("DELETE STEP"),
                #endregion
                #region column 4
                (new EmuRadioArray(c4, EMU_BASE, ew, eh, "Operation type:", 0, function() {
                    var slot = self.GetSibling("SLOTS").GetSelectedItem();
                    if (!slot) return;
                    var step_number = self.GetSibling("STEPS").GetSelection();
                    if (step_number == -1) return;
                    
                    if (self.value != slot.steps[step_number].id) {
                        slot.steps[step_number] = new slot.choices[self.value]();
                    }
                    
                    var refresh_data = { data: slot.steps[step_number] };
                    
                    self.GetSibling("PANEL:SHIFT").SetEnabled(false);
                    self.GetSibling("PANEL:HSV").SetEnabled(false);
                    self.GetSibling("PANEL:HSVPERCENT").SetEnabled(false);
                    self.GetSibling("PANEL:COLORS").SetEnabled(false);
                    self.GetSibling("PANEL:COLORSPERCENT").SetEnabled(false);
                    
                    switch (self.value) {
                        case EAutomationStepTypes.SHIFT_LEFT: self.GetSibling("PANEL:SHIFT").SetEnabled(true).Refresh(refresh_data); break;
                        case EAutomationStepTypes.SHIFT_RIGHT: self.GetSibling("PANEL:SHIFT").SetEnabled(true).Refresh(refresh_data); break;
                        case EAutomationStepTypes.HSV: self.GetSibling("PANEL:HSV").SetEnabled(true).Refresh(refresh_data); break;
                        case EAutomationStepTypes.HSV_PERCENT: self.GetSibling("PANEL:HSVPERCENT").SetEnabled(true).Refresh(refresh_data); break;
                        case EAutomationStepTypes.COLOR: self.GetSibling("PANEL:COLORS").SetEnabled(true).Refresh(refresh_data); break;
                        case EAutomationStepTypes.COLOR_PERCENT: self.GetSibling("PANEL:COLORSPERCENT").SetEnabled(true).Refresh(refresh_data); break;
                    }
                }))
                    .AddOptions([
                        "Shift Left", "Shift Right", "Edit HSV", "Edit HSV (Percent)", "Edit Colors", "Edit Colors (Percent)",
                    ])
                    .SetRefresh(function(data) {
                        self.SetInteractive(false);
                        if (variable_struct_exists(data, "step_number")) {
                            self.SetInteractive(data.step_number > -1);
                            if (data.step_number > -1) {
                                self.value = data.slot.steps[data.step_number].id;
                            }
                        }
                    })
                    .SetInteractive(false)
                    .SetID("SLOT OPERATION TYPE"),
                (new EmuCore(c4 - 32, EMU_AUTO, ew, ew))
                    .AddContent([
                        (new EmuInput(c1, EMU_BASE, ew, eh, "Places:", 0, "Number of places to shift", 3, E_InputTypes.INT, function() {
                            self.data.count = real(self.value);
                            self.data.name = ((self.data.id == EAutomationStepTypes.SHIFT_LEFT) ? "Shift Left " : "Shift Right ") + string(self.value);
                        }))
                        .SetRealNumberBounds(0, 255)
                        .SetRefresh(function(data) {
                            if (variable_struct_exists(data, "data")) {
                                self.data = data.data;
                                self.SetValue(data.data.count);
                            }
                        })
                    ])
                    .SetRefresh(function() {
                        self.override_root_check = true;
                    })
                    .SetEnabled(false)
                    .SetID("PANEL:SHIFT"),
                (new EmuCore(c4 - 32, EMU_INLINE, ew, ew))
                    .AddContent([
                        (new EmuInput(c1, EMU_BASE, ew, eh, "Hue:", 0, "-180 to +180", 4, E_InputTypes.INT, function() {
                            self.data.hue = real(self.value);
                            self.root.name_update_cb(self.data);
                        }))
                        .SetRealNumberBounds(-180, 180)
                        .SetRefresh(function(data) {
                            if (variable_struct_exists(data, "data")) {
                                self.data = data.data;
                                self.SetValue(self.data.hue);
                            }
                        }),
                        (new EmuInput(c1, EMU_AUTO, ew, eh, "Saturation:", 0, "-100 to +100", 4, E_InputTypes.INT, function() {
                            self.data.sat = real(self.value);
                            self.root.name_update_cb(self.data);
                        }))
                        .SetRealNumberBounds(-100, 100)
                        .SetRefresh(function(data) {
                            if (variable_struct_exists(data, "data")) {
                                self.data = data.data;
                                self.SetValue(self.data.sat);
                            }
                        }),
                        (new EmuInput(c1, EMU_AUTO, ew, eh, "Value:", 0, "-180 to +180", 4, E_InputTypes.INT, function() {
                            self.data.val = real(self.value);
                            self.root.name_update_cb(self.data);
                        }))
                        .SetRealNumberBounds(-100, 100)
                        .SetRefresh(function(data) {
                            if (variable_struct_exists(data, "data")) {
                                self.data = data.data;
                                self.SetValue(self.data.val);
                            }
                        })
                    ])
                    .SetRefresh(function() {
                        self.override_root_check = true;
                        self.name_update_cb = method(self, function(data) {
                            data.name = "HSV: " +
                                (data.hue > 0 ? "+" : "") + string(data.hue) + "/" +
                                (data.sat > 0 ? "+" : "") + string(data.sat) + "/" +
                                (data.val > 0 ? "+" : "") + string(data.val);
                        });
                    })
                    .SetEnabled(false)
                    .SetID("PANEL:HSV"),
                (new EmuCore(c4 - 32, EMU_INLINE, ew, ew))
                    .AddContent([
                        (new EmuInput(c1, EMU_BASE, ew, eh, "Hue:", 0, "0.0x to 10.0x", 4, E_InputTypes.REAL, function() {
                            self.data.hue = real(self.value);
                            self.root.name_update_cb(self.data);
                        }))
                        .SetRealNumberBounds(0, 10)
                        .SetRefresh(function(data) {
                            if (variable_struct_exists(data, "data")) {
                                self.data = data.data;
                                self.SetValue(self.data.hue);
                            }
                        }),
                        (new EmuInput(c1, EMU_AUTO, ew, eh, "Saturation:", 0, "0.0x to 10.0x", 4, E_InputTypes.REAL, function() {
                            self.data.sat = real(self.value);
                            self.root.name_update_cb(self.data);
                        }))
                        .SetRealNumberBounds(0, 10)
                        .SetRefresh(function(data) {
                            if (variable_struct_exists(data, "data")) {
                                self.data = data.data;
                                self.SetValue(self.data.sat);
                            }
                        }),
                        (new EmuInput(c1, EMU_AUTO, ew, eh, "Value:", 0, "0.0x to 10.0x", 4, E_InputTypes.REAL, function() {
                            self.data.val = real(self.value);
                            self.root.name_update_cb(self.data);
                        }))
                        .SetRealNumberBounds(0, 10)
                        .SetRefresh(function(data) {
                            if (variable_struct_exists(data, "data")) {
                                self.data = data.data;
                                self.SetValue(self.data.val);
                            }
                        })
                    ])
                    .SetRefresh(function() {
                        self.override_root_check = true;
                        self.name_update_cb = method(self, function(data) {
                            data.name = "HSV: " +
                                string_format(data.hue, 1, 2) + "/" +
                                string_format(data.sat, 1, 2) + "/" +
                                string_format(data.val, 1, 2);
                        });
                    })
                    .SetEnabled(false)
                    .SetID("PANEL:HSVPERCENT"),
                (new EmuCore(c4 - 32, EMU_INLINE, ew, ew))
                    .AddContent([
                        (new EmuInput(c1, EMU_BASE, ew, eh, "Red:", 0, "-255 to +255", 4, E_InputTypes.INT, function() {
                            self.data.r = real(self.value);
                            self.root.name_update_cb(self.data);
                        }))
                        .SetRealNumberBounds(-255, 255)
                        .SetRefresh(function(data) {
                            if (variable_struct_exists(data, "data")) {
                                self.data = data.data;
                                self.SetValue(self.data.r);
                            }
                        }),
                        (new EmuInput(c1, EMU_AUTO, ew, eh, "Green:", 0, "-255 to +255", 4, E_InputTypes.INT, function() {
                            self.data.g = real(self.value);
                            self.root.name_update_cb(self.data);
                        }))
                        .SetRealNumberBounds(-255, 255)
                        .SetRefresh(function(data) {
                            if (variable_struct_exists(data, "data")) {
                                self.data = data.data;
                                self.SetValue(self.data.g);
                            }
                        }),
                        (new EmuInput(c1, EMU_AUTO, ew, eh, "Blue:", 0, "-255 to +255", 4, E_InputTypes.INT, function() {
                            self.data.b = real(self.value);
                            self.root.name_update_cb(self.data);
                        }))
                        .SetRealNumberBounds(-255, 255)
                        .SetRefresh(function(data) {
                            if (variable_struct_exists(data, "data")) {
                                self.data = data.data;
                                self.SetValue(self.data.b);
                            }
                        }),
                    ])
                    .SetRefresh(function() {
                        self.override_root_check = true;
                        self.name_update_cb = method(self, function(data) {
                            data.name = "RGB: " +
                                (data.r > 0 ? "+" : "-") + string(data.r) + "/" +
                                (data.g > 0 ? "+" : "-") + string(data.g) + "/" +
                                (data.b > 0 ? "+" : "-") + string(data.b);
                        });
                    })
                    .SetEnabled(false)
                    .SetID("PANEL:COLORS"),
                (new EmuCore(c4 - 32, EMU_INLINE, ew, ew))
                    .AddContent([
                        (new EmuInput(c1, EMU_BASE, ew, eh, "Red:", 0, "0.0x to 10.0x", 4, E_InputTypes.REAL, function() {
                            self.data.r = real(self.value);
                            self.root.name_update_cb(self.data);
                        }))
                        .SetRealNumberBounds(0, 10)
                        .SetRefresh(function(data) {
                            if (variable_struct_exists(data, "data")) {
                                self.data = data.data;
                                self.SetValue(self.data.r);
                            }
                        }),
                        (new EmuInput(c1, EMU_AUTO, ew, eh, "Green:", 0, "0.0x to 10.0x", 4, E_InputTypes.REAL, function() {
                            self.data.g = real(self.value);
                            self.root.name_update_cb(self.data);
                        }))
                        .SetRealNumberBounds(0, 10)
                        .SetRefresh(function(data) {
                            if (variable_struct_exists(data, "data")) {
                                self.data = data.data;
                                self.SetValue(self.data.g);
                            }
                        }),
                        (new EmuInput(c1, EMU_AUTO, ew, eh, "Blue:", 0, "0.0x to 10.0x", 4, E_InputTypes.REAL, function() {
                            self.data.b = real(self.value);
                            self.root.name_update_cb(self.data);
                        }))
                        .SetRealNumberBounds(0, 10)
                        .SetRefresh(function(data) {
                            if (variable_struct_exists(data, "data")) {
                                self.data = data.data;
                                self.SetValue(self.data.b);
                            }
                        }),
                    ])
                    .SetRefresh(function() {
                        self.override_root_check = true;
                        self.name_update_cb = method(self, function(data) {
                            data.name = "RGB: " +
                                string_format(data.r, 1, 2) + "/" +
                                string_format(data.g, 1, 2) + "/" +
                                string_format(data.b, 1, 2);
                        });
                    })
                    .SetEnabled(false)
                    .SetID("PANEL:COLORSPERCENT"),
                #endregion
            ])
            .AddDefaultConfirmCancelButtons("Apply", function() {
                
                self.root.Close();
            }, "Close", function() {
                self.root.Close();
            })
            .GetChild("DEFAULT CONFIRM").SetInteractive(array_length(obj_demo.demo_palette.data) == 1);
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
                var hh = (colour_get_hue(cc) + (self.stored_hue / 360 * 255) + 255) % 255;
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