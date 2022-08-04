self.demo_sprite = spr_test_sprite;
self.demo_sprite_indexed = -1;
self.demo_palette = spr_test_palette;
self.demo_palette_data = array_create(256, 0);
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
    }).AddOptions(["Original", "Indexed"]),
    new EmuRenderSurface(32 + 32 + ew, EMU_BASE, 528, 704, function(mx, my) {
        // render
        draw_sprite_tiled(spr_palette_checker, 0, 0, 0);
        if (obj_demo.demo_sprite_type == 0) {
            if (sprite_exists(obj_demo.demo_sprite)) {
                draw_sprite(obj_demo.demo_sprite, 0, 0, 0);
            }
        } else {
            if (sprite_exists(obj_demo.demo_sprite_indexed)) {
                draw_sprite(obj_demo.demo_sprite_indexed, 0, 0, 0);
            } else if (sprite_exists(obj_demo.demo_sprite)) {
                draw_sprite(obj_demo.demo_sprite, 0, 0, 0);
            }
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