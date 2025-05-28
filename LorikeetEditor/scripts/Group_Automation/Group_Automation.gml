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
                
                self.Execute = function(indexed, palette) {
                    repeat (self.count) {
                        operation_shift_left(palette);
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
                
                self.Execute = function(indexed, palette) {
                    repeat (self.count) {
                        operation_shift_right(palette);
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
                
                self.Execute = function(indexed, palette) {
                    operation_update_hsv(palette, self.hue, self.sat, self.val);
                    
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
                
                self.Execute = function(indexed, palette) {
                    operation_update_hsv_percent(palette, self.hue, self.sat, self.val);
                    
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
                
                self.Execute = function(indexed, palette) {
                    operation_update_rgb(palette, self.r, self.g, self.b);
                    
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
                
                self.Execute = function(indexed, palette) {
                    operation_update_rgb_percent(palette, self.r, self.g, self.b);
                    
                    return {
                        palette, indexed
                    };
                };
            };
            
            self.StepOutline = function() constructor {
                self.color = c_black;
                self.use_corners = false;
                self.id = EAutomationStepTypes.OUTLINE;
                
                self.toString = function() {
                    static color_to_string = function(color) {
                        if (color == 0) return "#000000";
                        var rr = color_get_red(color);
                        var gg = color_get_green(color);
                        var bb = color_get_blue(color);
                        color = make_color_rgb(bb, gg, rr);
                        var hex = string(ptr(color));
                        return string_copy(hex, 11, 6);
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
                
                self.Execute = function(indexed, palette) {
                    //operation_update_rgb_percent(palette, self.r, self.g, self.b);
                    
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
            ];
            
            self.Execute = function(indexed, palette) {
                for (var i = 0, n = array_length(self.steps); i < n; i++) {
                    var output = self.steps[i].Execute(indexed, palette);
                    indexed = output.indexed;
                    palette = output.palette;
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
        
        self.Execute = function(indexed, source_palette) {
            var new_palette = array_create(array_length(self.indices));
            
            for (var i = 0, n = array_length(self.indices); i < n; i++) {
                new_palette[i] = array_create(array_length(source_palette));
                array_copy(new_palette[i], 0, source_palette, 0, array_length(source_palette));
                var output = self.indices[i].Execute(indexed, new_palette[i]);
                indexed = output.indexed;
            }
            
            return {
                palette: new_palette,
                indexed
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
    OUTLINE
}