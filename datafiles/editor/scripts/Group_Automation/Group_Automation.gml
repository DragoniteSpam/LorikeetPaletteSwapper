function LorikeetAutomation() constructor {
    self.types = [];
    
    self.Type = function() constructor {
        self.name = "";
        self.indices = [];
        
        self.Index = function() constructor {
            self.name = "";
            self.steps = [];
            
            self.AddStep = function(type) {
                array_push(self.steps, new type());
            };
            
            self.RemoveType = function(index) {
                array_delete(self.steps, index, 1);
            };
            
            self.StepShiftLeft = function() constructor {
            };
            
            self.StepShiftRight = function() constructor {
            };
            
            self.StepHSV = function() constructor {
                self.hue = 0;
                self.sat = 0;
                self.val = 0;
            };
            
            self.StepColor = function() constructor {
                self.r = 0;
                self.g = 0;
                self.b = 0;
            };
        };
        
        self.AddIndex = function() {
            var index = new self.Index();
            index.name = "Index" + string(array_length(self.indices));
            array_push(self.indices, index);
        };
        
        self.RemoveIndex = function(index) {
            array_push(self.indices, index, 1);
        };
    };
    
    self.AddType = function() {
        var type = new self.Type();
        type.name = "Type" + string(array_length(self.types));
        array_push(self.types, type);
    };
    
    self.RemoveType = function(index) {
        array_delete(self.types, index, 1);
    };
}