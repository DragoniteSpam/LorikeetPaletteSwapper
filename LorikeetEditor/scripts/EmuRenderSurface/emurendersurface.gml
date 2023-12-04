// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu
function EmuRenderSurface(x, y, width, height, render, step, create) : EmuCore(x, y, width, height, "") constructor {
    self.cx = width / 2;
    self.cy = height / 2;
    self.grabbing = true;
	self.zoom = 1;
	
    self.dx = 0;
    self.dy = 0;
	
    /// @ignore
    self.callback_render = method(self, render);
    /// @ignore
    self.callback_step = method(self, step);
    /// @ignore
    self.callback_recreate = function() {
        draw_clear(c_black);
        return self;
    };
	
	self.enable_pan = false;
	self.enable_zoom = false;
    
    self.surface = self.surfaceVerify(-1, self.width, self.height).surface;
    surface_set_target(self.surface);
    draw_clear(c_black);
    method(self, create)();
    surface_reset_target();
    
    #region mutators
    static SetRender = function(render) {
        self.callback_render = method(self, render);
        return self;
    };
    
    static SetStep = function(step) {
        self.callback_step = method(self, step);
        return self;
    };
    
    static SetRecreate = function(recreate) {
        self.callback_recreate = method(self, recreate);
        return self;
    };
	
	static SetPanEnabled = function(enabled) {
		self.enable_pan = enabled;
		return self;
	};
	
	static SetZoomEnabled = function(enabled) {
		self.enable_zoom = enabled;
		return self;
	};
	
	static SetZoom = function(zoom) {
		self.zoom = zoom;
        self.cx = self.width / 2 / self.zoom;
        self.cy = self.height / 2 / self.zoom;
		return self;
	};
    
	static SetCenter = function(x, y) {
		self.cx = x;
		self.cy = y;
		return self;
	};
    #endregion
    
    #region accessors
    self.GetSurface = function() {
        return self.surface;
    };
    #endregion
    
    #region other methods
    self.Render = function(x, y, debug_render = false) {
        var x1 = self.x + x;
        var y1 = self.y + y;
        var x2 = x1 + self.width;
        var y2 = y1 + self.height;
        var mx = device_mouse_x_to_gui(0) - x1;
        var my = device_mouse_y_to_gui(0) - y1;
        
		var mouse_in_view = mx >= 0 && mx <= self.width && my >= 0 && my <= self.height;
		
		if (self.enable_pan) {
	        if (!mouse_check_button(mb_middle) || !window_has_focus()) {
	            self.grabbing = false;
	        }
			
	        if (mouse_in_view) {
		        if (mouse_check_button_pressed(mb_middle)) {
		            self.grabbing = true;
		            self.dx = mx;
		            self.dy = my;
		        }
				
		        if (self.grabbing) {
		            self.cx += (self.dx - mx) / self.zoom;
		            self.cy += (self.dy - my) / self.zoom;
		            self.dx = mx;
		            self.dy = my;
                    window_set_cursor(cr_size_all);
		        }
			} else {
                if (self.grabbing) {
                    window_set_cursor(cr_default);
                }
	            self.grabbing = false;
	        }
		}
		
        var localmx = (mx - self.width / 2) / self.zoom + self.cx;
        var localmy = (my - self.height / 2) / self.zoom + self.cy;
        
		if (self.enable_zoom) {
			if (mouse_in_view) {
				// if panning is enabled, we can zoom in specifically on the cursor
		        static zoom_step = 0.25;
				if (self.enable_pan) {
                    var previous_zoom = self.zoom;
                    var cdx = self.cx - localmx;
                    var cdy = self.cy - localmy;
		            if (mouse_wheel_down()) {
		                self.zoom = max(0.25, self.zoom - zoom_step);
		            } else if (mouse_wheel_up()) {
		                self.zoom = min(16, self.zoom + zoom_step);
		            }
                    var zoom_factor = previous_zoom / self.zoom;
                    self.cx = localmx + cdx * zoom_factor;
                    self.cy = localmy + cdy * zoom_factor;
                // otherwise just try to stay in the corner
				} else {
		            if (mouse_wheel_down()) {
		                self.zoom = max(0.25, self.zoom - zoom_step);
		            } else if (mouse_wheel_up()) {
		                self.zoom = min(16, self.zoom + zoom_step);
		            }
                    self.cx = self.width / 2 / self.zoom;
                    self.cy = self.height / 2 / self.zoom;
				}
			}
		}
		
        self.gc.Clean();
        self.update_script();
        self.processAdvancement();
        
        var verify = self.surfaceVerify(self.surface, self.width, self.height);
        self.surface = verify.surface;
        
        if (verify.changed) {
            surface_set_target(self.surface);
            self.callback_recreate();
            surface_reset_target();
        }
        
        if (self.getMouseHover(x1, y1, x2, y2)) {
            self.ShowTooltip();
            if (self.getMousePressed(x1, y1, x2, y2)) {
                self.Activate();
            }
        }
		
		mx = mx - self.cx;
		my = my - self.cy;
        
        self.callback_step(localmx, localmy);
        
        surface_set_target(self.surface);
        var camera = camera_get_active();
        var old_view_mat = camera_get_view_mat(camera);
        var old_proj_mat = camera_get_proj_mat(camera);
        var old_state = gpu_get_state();
		var view_mat = matrix_build_lookat(self.cx, self.cy, -16000, self.cx, self.cy, 16000, 0, -1, 0);
		var proj_mat = matrix_build_projection_ortho(-self.width / self.zoom, -self.height / self.zoom, 1, 32000);
		camera_set_view_mat(camera, view_mat);
        camera_set_proj_mat(camera, proj_mat);
        camera_apply(camera);
        self.callback_render(localmx, localmy);
        camera_set_view_mat(camera, old_view_mat);
        camera_set_proj_mat(camera, old_proj_mat);
        camera_apply(camera);
        gpu_set_state(old_state);
        ds_map_destroy(old_state);
        surface_reset_target();
        
        draw_surface(self.surface, x1, y1);
        
        if (debug_render) self.renderDebugBounds(x1, y1, x2, y2);
    };
    #endregion
    
    static MouseOverCanvas = function() {
        if (!self.isActiveDialog()) return false;
        
        var x1 = self.x + x;
        var y1 = self.y + y;
        var mx = device_mouse_x_to_gui(0) - x1;
        var my = device_mouse_y_to_gui(0) - y1;
        
        return (mx >= 0 && mx <= self.width && my >= 0 && my <= self.height);
    };
}