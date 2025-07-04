function LorikeetAutomation() constructor {
    self.types = [];
    
    self.Save = function() {
        var json = {
            types: array_create(array_length(self.types)),
        };
        for (var i = 0, n = array_length(self.types); i < n; i++) {
            json.types[i] = self.types[i].Save();
        }
        return json;
    };
    
    self.Load = function(json) {
        self.types = array_create(array_length(json.types));
        for (var i = 0, n = array_length(json.types); i < n; i++) {
            self.types[i] = new self.Type();
            self.types[i].Load(json.types[i]);
        }
    };
    
    self.Type = function() constructor {
        self.name = "";
        self.indices = [];
        
        self.toString = function() {
            return self.name;
        };
        
        self.Save = function() {
            var json = {
                name: self.name,
                indices: array_create(array_length(self.indices)),
            };
            for (var i = 0, n = array_length(self.indices); i < n; i++) {
                json.indices[i] = self.indices[i].Save();
            }
            return json;
        };
        
        self.Load = function(json) {
            self.name = json.name;
            self.indices = array_create(array_length(json.indices));
            for (var i = 0, n = array_length(json.indices); i < n; i++) {
                self.indices[i] = new self.Index();
                self.indices[i].Load(json.indices[i]);
            }
        };
        
        self.Index = function() constructor {
            self.name = "";
            self.steps = [];
            
            self.toString = function() {
                return self.name;
            };
            
            self.Load = function(json) {
                self.name = json.name;
                self.steps = array_create(array_length(json.steps));
                for (var i = 0, n = array_length(json.steps); i < n; i++) {
                    self.steps[i] = new self.choices[json.steps[i].id]();
                    self.steps[i].Load(json.steps[i]);
                }
            };
            
            self.Save = function() {
                var json = {
                    name: self.name,
                    steps: array_create(array_length(self.steps)),
                };
                for (var i = 0, n = array_length(self.steps); i < n; i++) {
                    json.steps[i] = self.steps[i].Save();
                }
                return json;
            };
            
            self.AddStep = function(type) {
                var addition = new type();
                array_push(self.steps, addition);
                return addition;
            };
            
            self.RemoveStep = function(index) {
                array_delete(self.steps, index, 1);
            };
            
            self.StepShiftLeft = function() constructor {
                self.count = 1;
                self.id = EAutomationStepTypes.SHIFT_LEFT;
                
                self.toString = function() {
                    return "Shift Left 1";
                };
                
                self.Save = function() {
                    return {
                        id: self.id,
                        count: self.count
                    };
                };
                
                self.Load = function(json) {
                    self.count = json.count;
                };
                
                self.Execute = function(indexed, palette, row) {
                    repeat (self.count) {
                        operation_shift_left(palette.data[row]);
                    }
                    
                    return {
                        palette, indexed
                    };
                };
            };
            
            self.StepShiftRight = function() constructor {
                self.count = 1;
                self.id = EAutomationStepTypes.SHIFT_RIGHT;
                
                self.toString = function() {
                    return "Shift Right 1";
                };
                
                self.Load = function(json) {
                    self.count = json.count;
                };
                
                self.Save = function() {
                    return {
                        id: self.id,
                        count: self.count
                    };
                };
                
                self.Execute = function(indexed, palette, row) {
                    repeat (self.count) {
                        operation_shift_right(palette.data[row]);
                    }
                    
                    return {
                        palette, indexed
                    };
                };
            };
            
            self.StepHSV = function() constructor {
                self.hue = 0;
                self.sat = 0;
                self.val = 0;
                self.id = EAutomationStepTypes.HSV;
                
                self.toString = function() {
                    return "HSV: " +
                        (self.hue > 0 ? "+" : "") + string(self.hue) + "/" +
                        (self.sat > 0 ? "+" : "") + string(self.sat) + "/" +
                        (self.val > 0 ? "+" : "") + string(self.val);
                };
                
                self.Save = function() {
                    return {
                        id: self.id,
                        hue: self.hue,
                        sat: self.sat,
                        val: self.val,
                    };
                };
                
                self.Load = function(json) {
                    self.hue = json.hue;
                    self.sat = json.sat;
                    self.val = json.val;
                };
                
                self.Execute = function(indexed, palette, row) {
                    operation_update_hsv(palette.data[row], self.hue, self.sat, self.val);
                    
                    return {
                        palette, indexed
                    };
                };
            };
            
            self.StepHSVPercent = function() constructor {
                self.hue = 1;
                self.sat = 1;
                self.val = 1;
                self.id = EAutomationStepTypes.HSV_PERCENT;
                
                self.toString = function () {
                    return "HSV: " +
                        string_format(self.hue, 1, 2) + "/" +
                        string_format(self.sat, 1, 2) + "/" +
                        string_format(self.val, 1, 2);
                };
                
                self.Save = function() {
                    return {
                        id: self.id,
                        hue: self.hue,
                        sat: self.sat,
                        val: self.val,
                    };
                };
                
                self.Load = function(json) {
                    self.hue = json.hue;
                    self.sat = json.sat;
                    self.val = json.val;
                };
                
                self.Execute = function(indexed, palette, row) {
                    operation_update_hsv_percent(palette.data[row], self.hue, self.sat, self.val);
                    
                    return {
                        palette, indexed
                    };
                };
            };
            
            self.StepColor = function() constructor {
                self.r = 0;
                self.g = 0;
                self.b = 0;
                self.id = EAutomationStepTypes.COLOR;
                
                self.toString = function() {
                    return "RGB: " +
                        (self.r > 0 ? "+" : "-") + string(self.r) + "/" +
                        (self.g > 0 ? "+" : "-") + string(self.g) + "/" +
                        (self.b > 0 ? "+" : "-") + string(self.b);
                };
                
                self.Save = function() {
                    return {
                        id: self.id,
                        r: self.r,
                        g: self.g,
                        b: self.b,
                    };
                };
                
                self.Load = function(json) {
                    self.r = json.r;
                    self.g = json.g;
                    self.b = json.b;
                };
                
                self.Execute = function(indexed, palette, row) {
                    operation_update_rgb(palette.data[row], self.r, self.g, self.b);
                    
                    return {
                        palette, indexed
                    };
                };
            };
            
            self.StepColorPercent = function() constructor {
                self.r = 1;
                self.g = 1;
                self.b = 1;
                self.id = EAutomationStepTypes.COLOR_PERCENT;
                
                self.toString = function() {
                    return "RGB: " +
                        string_format(self.r, 1, 2) + "/" +
                        string_format(self.g, 1, 2) + "/" +
                        string_format(self.b, 1, 2);
                };
                
                self.Save = function() {
                    return {
                        id: self.id,
                        r: self.r,
                        g: self.g,
                        b: self.b,
                    };
                };
                
                self.Load = function(json) {
                    self.r = json.r;
                    self.g = json.g;
                    self.b = json.b;
                };
                
                self.Execute = function(indexed, palette, row) {
                    operation_update_rgb_percent(palette.data[row], self.r, self.g, self.b);
                    
                    return {
                        palette, indexed
                    };
                };
            };
            
            self.StepOutline = function() constructor {
                self.color = 0xff000000;
                self.use_corners = false;
                self.id = EAutomationStepTypes.OUTLINE;
                
                self.toString = function() {
                    static color_to_string = function(color) {
                        if ((color & 0x00ffffff) == 0) return $"#000000@{floor(((color >> 24) / 255) * 100)}%";
                        var hex = string(ptr(color));
                        return $"{string_copy(hex, 11, 6)}@{floor(((color >> 24) / 255) * 100)}%";
                    };
                    return "Outline: " +
                        color_to_string(self.color) + "/" +
                        (self.use_corners ? "corners" : "no corners");
                };
                
                self.Save = function() {
                    return {
                        id: self.id,
                        color: self.color,
                        use_corners: self.use_corners
                    };
                };
                
                self.Load = function(json) {
                    self.color = json.color;
                    self.use_corners = json.use_corners;
                };
                
                self.Execute = function(indexed, palette, row) {
                    var outline_index = palette.palette_used_size;
                    var original_size = array_length(palette.data[row]);
                    palette.AddPaletteColor(self.color);
                    var new_size = array_length(palette.data[row]);
                    var outline_value = outline_index / array_length(palette.data[row]);
                    
                    if (original_size != new_size) {
                        var extended = index_extend_colors(indexed, 0);
                        sprite_delete(indexed);
                        indexed = extended;
                    }
                    
                    var outlined_sprite = index_generate_outlines(indexed, outline_value, self.use_corners);
                    sprite_delete(indexed);
                    
                    return {
                        palette, indexed: outlined_sprite
                    };
                };
            };
            
            self.StepSetColor = function() constructor {
                self.color = c_black;
                self.index = 0;
                self.id = EAutomationStepTypes.SET_COLOR;
                
                self.toString = function() {
                    static color_to_string = function(color) {
                        if ((color & 0x00ffffff) == 0) return $"#000000@{floor(((color >> 24) / 255) * 100)}%";
                        var hex = string(ptr(color));
                        return $"{string_copy(hex, 11, 6)}@{floor(((color >> 24) / 255) * 100)}%";
                    };
                    return $"Set Color: {color_to_string(self.color)} to index {self.index}";
                };
                
                self.Save = function() {
                    return {
                        id: self.id,
                        color: self.color,
                        index: self.index
                    };
                };
                
                self.Load = function(json) {
                    self.color = json.color;
                    self.index = json.index;
                };
                
                self.Execute = function(indexed, palette, row) {
                    var active_index = (self.index >= 0) ? self.index : (palette.palette_used_size + self.index);
                    palette.data[row][active_index] = self.color;
                    
                    return {
                        palette, indexed
                    };
                };
            };
            
            self.choices = [
                self.StepShiftLeft,
                self.StepShiftRight,
                self.StepHSV,
                self.StepHSVPercent,
                self.StepColor,
                self.StepColorPercent,
                self.StepOutline,
                self.StepSetColor
            ];
            
            self.Execute = function(indexed, palette, row) {
                for (var i = 0, n = array_length(self.steps); i < n; i++) {
                    var output = self.steps[i].Execute(indexed, palette, row);
                    indexed = output.indexed;
                }
                
                return {
                    palette, indexed
                };
            };
        };
        
        self.AddIndex = function() {
            var index = new self.Index();
            index.name = "PaletteIndex" + string(array_length(self.indices));
            array_push(self.indices, index);
            return index;
        };
        
        self.RemoveIndex = function(index) {
            array_delete(self.indices, index, 1);
        };
        
        self.Execute = function(indexed, palette) {
            var template_row = array_length(palette.data) - 1;
            for (var i = 0, n = array_length(self.indices); i < n; i++) {
                palette.AddPaletteRow(template_row);
                var output = self.indices[i].Execute(indexed, palette, array_length(palette.data) - 1);
                indexed = output.indexed;
            }
            
            // the last row before the automation chain is the "template" row,
            // and gets removed at the end
            palette.RemovePaletteRow(template_row);
            
            return {
                palette, indexed
            };
        };
    };
    
    self.AddType = function() {
        var type = new self.Type();
        type.name = "Type" + string(array_length(self.types));
        array_push(self.types, type);
        return type;
    };
    
    self.RemoveType = function(index) {
        array_delete(self.types, index, 1);
    };
}

enum EAutomationStepTypes {
    SHIFT_LEFT,
    SHIFT_RIGHT,
    HSV,
    HSV_PERCENT,
    COLOR,
    COLOR_PERCENT,
    OUTLINE,
    SET_COLOR
}