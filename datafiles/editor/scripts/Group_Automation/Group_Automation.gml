function LorikeetAutomation() constructor {
    self.types = [];
    
    self.Type = function() constructor {
        self.name = "";
        self.indices = [];
        
        self.Index = function() constructor {
            self.name = "";
            self.steps = [];
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