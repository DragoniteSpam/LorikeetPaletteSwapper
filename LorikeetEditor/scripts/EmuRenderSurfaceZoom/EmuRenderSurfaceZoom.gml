function EmuRenderSurfaceZoom(x, y, width, height, render, step) : EmuRenderSurface(x, y, width, height, render, step, function() {
        self.xoffset = 0;
        self.yoffset = 0;
        self.grabbing = true;
        
        self.dx = 0;
        self.dy = 0;
    }) constructor {
    
    static HandlePanAndZoom = function(mx, my) {
        if (!mouse_check_button(mb_middle) || !window_has_focus()) {
            self.grabbing = false;
        }
        
        if (!(mx >= 0 && mx <= self.width && my >= 0 && my <= self.height)) {
            self.grabbing = false;
            return;
        }
        
        if (mouse_check_button_pressed(mb_middle)) {
            self.grabbing = true;
            self.dx = mx;
            self.dy = my;
        }
        
        if (self.grabbing) {
            self.xoffset -= (self.dx - mx);
            self.yoffset -= (self.dy - my);
            self.dx = mx;
            self.dy = my;
        }
    };
    
    static TransformMouseX = function(mx) {
        return mx - self.xoffset;
    };
    
    static TransformMouseY = function(my) {
        return my - self.yoffset;
    };
}