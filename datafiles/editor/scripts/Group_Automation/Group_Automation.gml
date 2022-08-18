function LorikeetAutomation() constructor {
    self.types = [];
    
    self.Type = function() constructor {
        self.name = "";
        self.indices = [];
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