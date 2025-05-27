// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu
function EmuRenderSurface(x, y, width, height, render, step, create) : EmuCore(x, y, width, height, "") constructor {
    self.cx = width / 2;
    self.cy = height / 2;
    self.grabbing = true;
	self.zoom = 1;
    self.zoom_target = 1;
    self.zoom_min = 1;
    self.zoom_max = 1;
    self.zoom_step = 1;
	
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
    
    /// @ignore
    self.callback_render_begin = function(mx, my) { };
    /// @ignore
    self.callback_render_ui = function(mx, my) { };
	
	self.enable_pan = false;
	self.enable_zoom = false;
    
    self.surface = self.surfaceVerify(-1, self.width, self.height).surface;
    self.surface_begin = undefined;
    self.surface_ui = undefined;
    surface_set_target(self.surface);
    draw_clear(c_black);
    method(self, create)();
    surface_reset_target();
    
    #region mutators
    static SetRender = function(render) {
        self.callback_render = method(self, render);
        return self;
    };
    
    static SetRenderBegin = function(render) {
        self.callback_render_begin = method(self, render);
        self.surface_begin = self.surfaceVerify(-1, self.width, self.height).surface;
        surface_set_target(self.surface_begin);
        draw_clear_alpha(c_black, 0);
        surface_reset_target();
        return self;
    };
    
    static SetRenderUI = function(render) {
        self.callback_render_ui = method(self, render);
        self.surface_ui = self.surfaceVerify(-1, self.width, self.height).surface;
        surface_set_target(self.surface_ui);
        draw_clear_alpha(c_black, 0);
        surface_reset_target();
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
	
	static SetZoomEnabled = function(enabled, zoom_min, zoom_max, zoom_step = 1) {
		self.enable_zoom = enabled;
        self.zoom_min = zoom_min;
        self.zoom_max = zoom_max;
        self.zoom_step = zoom_step;
		return self;
	};
	
	static SetZoom = function(zoom) {
		self.zoom = zoom;
        self.zoom_target = zoom;
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
		
        var localmx = (mx - self.width / 2) / self.zoom_target + self.cx;
        var localmy = (my - self.height / 2) / self.zoom_target + self.cy;
        
		if (self.enable_zoom) {
			if (mouse_in_view) {
		        if (mouse_wheel_down()) {
		            self.zoom_target = max(self.zoom_min, self.zoom_target - self.zoom_step);
		        } else if (mouse_wheel_up()) {
		            self.zoom_target = min(self.zoom_max, self.zoom_target + self.zoom_step);
		        }
			}
            
            // if panning is enabled, we can zoom in specifically on the cursor
			if (self.enable_pan) {
                var previous_zoom = self.zoom;
                var cdx = self.cx - localmx;
                var cdy = self.cy - localmy;
                self.zoom = lerp(self.zoom, self.zoom_target, 0.1);
                // if you are 99.9% of the way there, snap to avoid potential aliasing issues
                if (abs(self.zoom / self.zoom_target - 1) < 0.001) {
                    self.zoom = self.zoom_target;
                }
                var zoom_factor = previous_zoom / self.zoom;
                self.cx = localmx + cdx * zoom_factor;
                self.cy = localmy + cdy * zoom_factor;
            // otherwise just try to stay in the corner
			} else {
		        self.zoom = lerp(self.zoom, self.zoom_target, 0.1);
                if (abs(self.zoom / self.zoom_target - 1) < 0.001) {
                    self.zoom = self.zoom_target;
                }
                self.cx = self.width / 2 / self.zoom;
                self.cy = self.height / 2 / self.zoom;
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
        
        if (self.surface_begin != undefined) {
            verify = self.surfaceVerify(self.surface_begin, self.width, self.height);
            self.surface_begin = verify.surface;
        }
        
        if (surface_exists(self.surface_begin)) {
            if (verify.changed) {
                surface_set_target(self.surface_begin);
                draw_clear_alpha(c_black, 0);
                surface_reset_target();
            }
        }
        
        if (self.surface_ui != undefined) {
            verify = self.surfaceVerify(self.surface_ui, self.width, self.height);
            self.surface_ui = verify.surface;
        }
        
        if (surface_exists(self.surface_ui)) {
            if (verify.changed) {
                surface_set_target(self.surface_ui);
                draw_clear_alpha(c_black, 0);
                surface_reset_target();
            }
        }
        
        if (self.getMouseHover(x1, y1, x2, y2)) {
            self.ShowTooltip();
            if (self.getMousePressed(x1, y1, x2, y2)) {
                self.Activate();
            }
        }
		
        self.callback_step(localmx, localmy, mx, my);
        
        var camera = camera_get_active();
        var old_state = gpu_get_state();
        
        if (self.surface_begin != undefined) {
            surface_set_target(self.surface_begin);
            self.callback_render_begin(mx, my);
            surface_reset_target();
            gpu_set_state(old_state);
        }
        
        surface_set_target(self.surface);
		var view_mat = matrix_build_lookat(self.cx, self.cy, -16000, self.cx, self.cy, 16000, 0, -1, 0);
		var proj_mat = matrix_build_projection_ortho(-self.width / self.zoom, -self.height / self.zoom, 1, 32000);
		camera_set_view_mat(camera, view_mat);
        camera_set_proj_mat(camera, proj_mat);
        camera_apply(camera);
        self.callback_render(localmx, localmy, mx, my);
        
        gpu_set_state(old_state);
        surface_reset_target();
        
        if (self.surface_ui != undefined) {
            surface_set_target(self.surface_ui);
            self.callback_render_ui(mx, my);
            surface_reset_target();
            gpu_set_state(old_state);
        }
        
        gpu_set_state(old_state);
        ds_map_destroy(old_state);
        
        if (self.surface_begin != undefined) {
            draw_surface(self.surface_begin, x1, y1);
        }
        draw_surface(self.surface, x1, y1);
        if (self.surface_ui != undefined) {
            draw_surface(self.surface_ui, x1, y1);
        }
        
        if (debug_render) self.renderDebugBounds(x1, y1, x2, y2);
    };
    #endregion
    
    static MouseOverCanvas = function(mx, my) {
        if (!self.isActiveDialog()) return false;
        
        var x1 = mx - self.width / 2 / self.zoom;
        var y1 = my - self.height/ 2 / self.zoom;
        var x2 = mx + self.width / 2 / self.zoom;
        var y2 = my + self.height/ 2 / self.zoom;
        
        return (mx > x1 && mx < x2 && my >= y1 && my <= y2);
    };
    
    static MouseOverUI = function(mx, my) {
        if (!self.isActiveDialog()) return false;
        
        return (mx >= 0 && mx <= self.width && my >= 0 && my <= self.height);
    };
}