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
                draw_sprite_ext(obj_demo.demo_sprite, 0, 0, 0, 8, 8, 0, c_white, 1);
                break;
            case 1:
                draw_sprite_ext(obj_demo.demo_sprite_indexed, 0, 0, 0, 8, 8, 0, c_white, 1);
                break;
            case 2:
                lorikeet_set(obj_demo.demo_palette, 0);
                draw_sprite_ext(obj_demo.demo_sprite_indexed, 0, 0, 0, 8, 8, 0, c_white, 1);
                shader_reset();
                break;
        }
    }, function(mx, my) {
        // step
    }, function() {
        // create
    }),
    new EmuRenderSurface(32 + 32 + 32 + ew + 528, EMU_BASE, 384, 704, function(mx, my) {
        // render
        var step = 32;
        var mcx = mx div step;
        var mcy = my div step;
        draw_sprite_tiled(spr_palette_checker, 0, 0, 0);
        
        var palette = obj_demo.demo_palette_data;
        for (var i = 0, n = array_length(palette); i < n; i++) {
            var c = palette[i];
            if (c == -1) break;
            draw_rectangle_color((i % 12) * step, (i div 12) * step, ((i % 12) + 1) * step, ((i div 12) + 1) * step, c, c, c, c, false);
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
    }, function() {
        // create
    }),
]);