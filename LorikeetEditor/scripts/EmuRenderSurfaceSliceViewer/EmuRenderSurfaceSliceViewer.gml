function EmuRenderSurfaceSliceViewer(x, y, width, height) : EmuRenderSurface(x, y, width, height, function(mx, my) {
    // render
    draw_sprite_tiled(spr_palette_checker, 0, 0, 0);
    var xx = 0;
    var yy = 0;
    var yy_next = 0;
    var c = c_black;
    
    var tile_color = c_aqua;
    var tile_alpha = 0.25;
    var to_delete = -1;
    
    for (var i = 0, n = array_length(obj_demo.slices); i < n; i++) {
        var slice = obj_demo.slices[i];
        var xx_next = xx + slice.w;
        if (xx > 0 && xx_next >= self.width) {
            yy = yy_next;
            xx = 0;
            xx_next = xx + slice.w;
        }
		var xscale = slice.flipped_h ? -1 : 1;
		var yscale = slice.flipped_v ? -1 : 1;
		var xoffset = slice.flipped_h ? slice.w : 0;
		var yoffset = slice.flipped_v ? slice.h : 0;
        draw_sprite_part_ext(obj_demo.demo_sprite, 0, slice.x, slice.y, slice.w, slice.h, xx + xoffset, yy + yoffset, xscale, yscale, c_white, 1);
        if (mx > xx && my > yy && mx < xx + slice.w && my < yy + slice.h) {
            draw_set_alpha(tile_alpha);
            draw_rectangle_colour(xx + 1, yy + 1, slice.w + xx - 1, slice.h + yy - 1, tile_color, tile_color, tile_color, tile_color, false);
            draw_set_alpha(1);
            if (mouse_check_button_pressed(mb_right)) {
                to_delete = i;
            }
        }
        draw_rectangle_colour(xx + 1, yy + 1, slice.w + xx - 1, slice.h + yy - 1, c, c, c, c, true);
        xx = xx_next;
        yy_next = max(yy_next, slice.h + yy);
    }
    
    if (to_delete != -1) {
        obj_demo.DeleteSpriteSlice(to_delete);
    }
        }, emu_null, emu_null) constructor {
        // it's all constructor inheritance
}