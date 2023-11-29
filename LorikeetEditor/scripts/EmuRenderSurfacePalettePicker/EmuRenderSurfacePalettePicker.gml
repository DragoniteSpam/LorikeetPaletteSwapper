function EmuRenderSurfacePalettePicker(x, y, width, height) : EmuRenderSurface(x, y, width, height, function(mx, my) {
        // render
        var sprite = obj_demo.demo_palette.palette;
        draw_sprite_tiled(spr_palette_checker, 0, 0, 0);
        var hscale = self.width / sprite_get_width(sprite);
        var vscale = self.height / sprite_get_height(sprite);
        var scale = min(hscale, vscale);
        draw_sprite_ext(sprite, 0, 0, 0, scale, scale, 0, c_white, 1);
        draw_sprite_stretched_ext(spr_tile_selector, 0, 0, scale * floor(obj_demo.demo_palette_index), self.width, scale, c_red, 1);
    }, function(mx, my) {
        // step
        if (!self.isActiveDialog()) return;
        if (mx < 0 || mx >= self.width || my < 0 || my >= self.height) return;
        if (mouse_check_button(mb_left)) {
            var sprite = obj_demo.demo_palette.palette;
            var hscale = self.width / sprite_get_width(sprite);
            var vscale = self.height / sprite_get_height(sprite);
            var scale = min(hscale, vscale);
            var row = min(my div scale, sprite_get_height(sprite) - 1);
            obj_demo.demo_palette_index = row;
        }
    }, emu_null) constructor {
        // it's all constructor inheritance
}