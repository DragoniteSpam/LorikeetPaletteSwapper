function emu_dialog_show_automation() {
    var ew = 320;
    var eh = 32;
    var c1 = 32;
    var c2 = 32 + 320 + 32;
    var c3 = 32 + 320 + 32 + 320 + 32;
    var c4 = 32 + 320 + 32 + 320 + 32 + 320 + 32;
    (new EmuDialog(c4 + 320 + 32, 544, "Palette Automation"))
        .SetCloseButton(false)
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
                            self.SetValue(string_format(self.data.hue, 1, 2));
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
                            self.SetValue(string_format(self.data.sat, 1, 2));
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
                            self.SetValue(string_format(self.data.val, 1, 2));
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
                            self.SetValue(string_format(self.data.r, 1, 2));
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
                            self.SetValue(string_format(self.data.g, 1, 2));
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
                            self.SetValue(string_format(self.data.b, 1, 2));
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
            var type = self.GetSibling("TYPE LIST").GetSelectedItem();
            if (type) {
                var new_palette = type.Execute(obj_demo.demo_palette.data[0]);
                obj_demo.demo_palette.data = new_palette;
                obj_demo.demo_palette.Refresh();
            }
            self.root.Close();
        }, "Close", function() {
            obj_demo.SaveAutomation();
            self.root.Close();
        })
        .GetChild("DEFAULT CONFIRM").SetInteractive(array_length(obj_demo.demo_palette.data) == 1);
}