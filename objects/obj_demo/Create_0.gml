self.demo_sprite = spr_test_sprite;
var palette_data = lorikeet_extract_palette_data(self.demo_sprite, 0);
self.demo_sprite_indexed = palette_data.indexed_sprite;
self.demo_palette_data = palette_data.palette_array;
self.demo_palette = palette_data.palette_sprite;
self.demo_sprite_type = 0;

var ew = 320;
var eh = 32;

self.ui = (new EmuCore(0, 0, window_get_width(), window_get_height())).AddContent([
    new EmuText(32, EMU_AUTO, ew, eh, "[c_aqua]Lorikeet Palette Extraction"),
    new EmuButton(32, EMU_AUTO, ew / 2, eh, "Load Sprite", function() {
    }),
    new EmuButton(32 + ew / 2, EMU_INLINE, ew / 2, eh, "Load Palette", function() {
    }),
    new EmuButton(32, EMU_AUTO, ew / 2, eh, "Save Grayscale", function() {
    }),
    new EmuButton(32 + ew / 2, EMU_INLINE, ew / 2, eh, "Save Palette", function() {
    }),
    new EmuRadioArray(32, EMU_AUTO, ew, eh, "Display type:", 0, function() {
        obj_demo.demo_sprite_type = self.value;
    }).AddOptions(["Original", "Indexed", "Indexed with Palette"]),
    new EmuRenderSurface(32 + 32 + ew, EMU_BASE, 528, 704, function(mx, my) {
        // render
        draw_sprite_tiled(spr_palette_checker, 0, 0, 0);
        switch (obj_demo.demo_sprite_type) {
            case 0:
                draw_sprite_ext(obj_demo.demo_sprite, 0, self.map_x, self.map_y, self.zoom, self.zoom, 0, c_white, 1);
                break;
            case 1:
                draw_sprite_ext(obj_demo.demo_sprite_indexed, 0, self.map_x, self.map_y, self.zoom, self.zoom, 0, c_white, 1);
                break;
            case 2:
                lorikeet_set(obj_demo.demo_palette, 0);
                draw_sprite_ext(obj_demo.demo_sprite_indexed, 0, self.map_x, self.map_y, self.zoom, self.zoom, 0, c_white, 1);
                shader_reset();
                break;
        }
    }, function(mx, my) {
        // step
        if (!self.isActiveDialog()) return;
        var mouse_in_view = (mx >= 0 && mx <= self.width && my >= 0 && my <= self.width);
        if (mouse_in_view) {
            var zoom_step = 0.5;
            if (mouse_wheel_down()) {
                var cx = (mx - self.map_x) / self.zoom;
                var cy = (my - self.map_y) / self.zoom;
                self.zoom = max(1, self.zoom - zoom_step);
                self.map_x = mx - self.zoom * cx;
                self.map_y = my - self.zoom * cy;
            } else if (mouse_wheel_up()) {
                var cx = (mx - self.map_x) / self.zoom;
                var cy = (my - self.map_y) / self.zoom;
                self.zoom = min(16, self.zoom + zoom_step);
                self.map_x = mx - self.zoom * cx;
                self.map_y = my - self.zoom * cy;
            }
        }
        
        if (mouse_in_view && mouse_check_button_pressed(mb_middle)) {
            self.panning = true;
            self.pan_x = mx;
            self.pan_y = my;
        }
        if (mouse_check_button(mb_middle)) {
            self.map_x += mx - self.pan_x;
            self.map_y += my - self.pan_y;
            self.pan_x = mx;
            self.pan_y = my;
            window_set_cursor(cr_size_all);
        } else {
            self.panning = false;
            window_set_cursor(cr_default);
        }
        if (keyboard_check_pressed(vk_enter)) {
            self.zoom = 1;
            self.map_x = 0;
            self.map_y = 0;
            self.panning = false;
            self.pan_x = 0;
            self.pan_y = 0;
        }
    }, function() {
        // create
        self.zoom = 4;
        self.map_x = 0;
        self.map_y = 0;
        self.panning = false;
        self.pan_x = 0;
        self.pan_y = 0;
    }),
    new EmuRenderSurface(32 + 32 + 32 + ew + 528, EMU_BASE, 384, 704, function(mx, my) {
        // render
        var step = 32;
        var hcells = self.width div step;
        var mcx = mx div step;
        var mcy = my div step;
        draw_sprite_tiled(spr_palette_checker, 0, 0, 0);
        
        var palette = obj_demo.demo_palette_data;
        for (var i = 0, n = array_length(palette); i < n; i++) {
            var c = palette[i];
            if (c == -1) break;
            draw_rectangle_color((i % hcells) * step, (i div hcells) * step, ((i % hcells) + 1) * step, ((i div hcells) + 1) * step, c, c, c, c, false);
        }
        
        gpu_set_blendmode_ext(bm_dest_color, bm_inv_src_alpha);
        draw_sprite(spr_palette_checker, 0, mcx * step, mcy * step);
        gpu_set_blendenable(bm_normal);
        
        for (var i = 0; i < self.width; i += step) {
            draw_line_colour(i, 0, i, self.height, c_black, c_black);
        }
        for (var i = 0; i < self.height; i += step) {
            draw_line_colour(0, i, self.width, i, c_black, c_black);
        }
    }, function(mx, my) {
        // step
        static picker = new EmuColorPicker(0, 0, 0, 0, "", c_black, function() {
            var changed = (obj_demo.demo_palette_data[self.palette_index] != self.value);
            obj_demo.demo_palette_data[self.palette_index] = self.value;
            if (changed) {
                sprite_delete(obj_demo.demo_palette);
                obj_demo.demo_palette = lorikeet_generate_palette_sprite(obj_demo.demo_palette_data);
            }
        });
        
        if (!self.isActiveDialog()) return;
        var mouse_in_view = (mx >= 0 && mx <= self.width && my >= 0 && my <= self.width);
        if (!mouse_in_view) return;
        
        var step = 32;
        var hcells = self.width div step;
        var mcx = mx div step;
        var mcy = my div step;
        
        if (mouse_check_button_pressed(mb_left)) {
            var index = mcy * hcells + mcx;
            picker.palette_index = index;
            picker.value = obj_demo.demo_palette_data[index];
            picker.ShowPickerDialog();
        }
    }, function() {
        // create
    }),
]);