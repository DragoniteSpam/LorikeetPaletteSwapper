function EmuRenderSurfaceSliceCutter(x, y, width, height) : EmuRenderSurface(x, y, width, height, function(mx, my) {
    // render callback
		draw_sprite_tiled(spr_palette_checker, 0, 0, 0);
		lorikeet_set(obj_demo.demo_palette.palette, obj_demo.demo_palette_index, 0, shd_lorikeet_preview);
		shader_set_uniform_f(shader_get_uniform(shd_lorikeet_preview, "u_IndexUnderCursor"), -100);
		shader_set_uniform_f(shader_get_uniform(shd_lorikeet_preview, "u_IndexCount"), array_length(obj_demo.demo_palette.data[0]));
		draw_sprite_ext(obj_demo.demo_sprite_indexed, 0, self.xoffset, self.yoffset, self.zoom, self.zoom, 0, c_white, 1);
		shader_reset();
        
        var sw = obj_demo.slice_width;
        var sh = obj_demo.slice_height;
        var line_color = c_blue;
        var spr = obj_demo.demo_sprite;
        
        if (mx >= 0 && mx <= self.width && my >= 0 && my <= self.height) {
            var mcx = (mx div sw) * sw + self.xoffset;
            var mcy = (my div sh) * sh + self.yoffset;
            
            var tile_color = c_aqua;
            var tile_alpha = 0.25;
            
            draw_set_alpha(tile_alpha);
            draw_rectangle_colour(mcx, mcy, mcx + sw, mcy + sh, tile_color, tile_color, tile_color, tile_color, false);
            draw_set_alpha(1);
        }
        
        var sprw = sprite_get_width(spr);
        var sprh = sprite_get_height(spr);
        var xo = self.xoffset;
        var yo = self.yoffset;
        
        for (var i = 0; i <= sprw; i += sw) {
            draw_line_width_colour(i + xo, yo, i + xo, yo + sprh, 2, line_color, line_color);
        }
        for (var i = 0; i <= sprh; i += sh) {
            draw_line_width_colour(xo, i + yo, sprw + xo, i + yo, 2, line_color, line_color);
        }
    }, function(mx, my) {
        // update callback
        if (!sprite_exists(obj_demo.demo_sprite))
            return;
        
        var sw = obj_demo.slice_width;
        var sh = obj_demo.slice_height;
        var mcx = ((mx - self.xoffset) div sw);
        var mcy = ((my - self.yoffset) div sh);
        
        if (mouse_check_button_pressed(mb_left)) {
            obj_demo.AddSpriteSlice(mcx * sw, mcy * sh, sw, sh);
        }
    }, emu_null) constructor {
        // it's all constructor inheritance
}