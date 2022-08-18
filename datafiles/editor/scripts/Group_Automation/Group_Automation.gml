function LorikeetAutomation() constructor {
    self.types = [];
    
    self.Type = function() constructor {
        self.name = "";
        self.indices = [];
        
        self.Index = function() constructor {
            self.name = "";
            self.steps = [];
            
            self.AddStep = function(type) {
                var addition = new type();
                array_push(self.steps, addition);
                return addition;
            };
            
            self.RemoveStep = function(index) {
                array_delete(self.steps, index, 1);
            };
            
            self.StepShiftLeft = function() constructor {
                self.name = "Shift Left 1";
                self.count = 1;
                self.id = EAutomationStepTypes.SHIFT_LEFT;
            };
            
            self.StepShiftRight = function() constructor {
                self.name = "Shift Right 1";
                self.count = 1;
                self.id = EAutomationStepTypes.SHIFT_RIGHT;
            };
            
            self.StepHSV = function() constructor {
                self.name = "HSV: 0/0/0";
                self.hue = 0;
                self.sat = 0;
                self.val = 0;
                self.id = EAutomationStepTypes.HSV;
            };
            
            self.StepHSVPercent = function() constructor {
                self.name = "HSV: 1.00/1.00/1.00";
                self.hue = 1;
                self.sat = 1;
                self.val = 1;
                self.id = EAutomationStepTypes.HSV_PERCENT;
            };
            
            self.StepColor = function() constructor {
                self.name = "Color: 0/0/0";
                self.r = 0;
                self.g = 0;
                self.b = 0;
                self.id = EAutomationStepTypes.COLOR;
            };
            
            self.StepColorPercent = function() constructor {
                self.name = "Color: 1.00/1.00/1.00";
                self.r = 1;
                self.g = 1;
                self.b = 1;
                self.id = EAutomationStepTypes.COLOR_PERCENT;
            };
            
            self.choices = [
                self.StepShiftLeft,
                self.StepShiftRight,
                self.StepHSV,
                self.StepHSVPercent,
                self.StepColor,
                self.StepColorPercent,
            ];
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
}