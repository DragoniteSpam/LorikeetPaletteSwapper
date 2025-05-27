function LorikeetPaletteManager(source_palette = undefined) constructor {
    self.palette = undefined;
    self.data = undefined;
    
    static ExtractPalette = function(sprite, index = 0, force_full_palette = false) {
        if (self.palette != undefined) sprite_delete(self.palette);
        var t = get_timer();
        
        var sw = sprite_get_width(sprite);
        var sh = sprite_get_height(sprite);
        
        var map = { };
        var surface_sprite = surface_create(sw, sh);
        surface_set_target(surface_sprite);
        draw_clear_alpha(c_black, 0);
        gpu_set_blendmode(bm_add);
        draw_sprite(sprite, index, 0, 0);
        gpu_set_blendmode(bm_normal);
        surface_reset_target();
        var buffer_sprite = buffer_create(sw * sh * 4, buffer_fixed, 4);
        buffer_get_surface(buffer_sprite, surface_sprite, 0);
        buffer_seek(buffer_sprite, buffer_seek_start, 0);
        
        var palette_array = array_create(256, 0);
        var palette_count = 0;
        
        var step = buffer_sizeof(buffer_u32);
        // address = (x + (y * width)) * size
        for (var i = 0; i < sw; i++) {
            for (var j = 0; j < sh; j++) {
                var cc = buffer_peek(buffer_sprite, (i + j * sw) * step, buffer_u32);
                if ((cc >> 24) == 0) continue;
                cc &= 0x00ffffff;
                var cname = string(cc);
                map[$ cname] ??= palette_count++;
                palette_array[map[$ cname]] = cc;
            }
        }
        
        // to do: quantize colors properly
        // previously we used to sort the colors in order form most common to
        // least common but that seemed to introduce some randomness into how
        // the colors were extracted which i don't feel like fixing now
        
        var palette_size = force_full_palette ? 256 : min(256, power(2, ceil(log2(palette_count))));
        array_resize(palette_array, palette_size);
        
        // zero out the unused parts of the palette array
        for (var i = palette_count, n = array_length(palette_array); i < n; i++) {
            palette_array[i] = -1;
        }
        
        var palette_buffer = buffer_create(palette_size * 4, buffer_fixed, 4);
        for (var i = 0, n = array_length(palette_array); i < n; i++) {
            buffer_write(palette_buffer, buffer_u32, 0xff000000 | palette_array[i]);
        }
        
        var palette_surface = surface_create(palette_size, 1);
        buffer_set_surface(palette_buffer, palette_surface, 0);
        var palette_sprite = sprite_create_from_surface(palette_surface, 0, 0, palette_size, 1, false, false, 0, 0);
        
        var palette_color_spacing = 256 / palette_size;
        
        for (var i = 0, n = buffer_get_size(buffer_sprite); i < n; i += step) {
            var cc = buffer_peek(buffer_sprite, i, buffer_u32);
            if ((cc >> 24) == 0) continue;
            var idx = map[$ string(cc & 0x00ffffff)] * palette_color_spacing;
            buffer_poke(buffer_sprite, i, buffer_u32, (cc & 0xff000000) | make_colour_rgb(idx, idx, idx));
        }
        
        buffer_set_surface(buffer_sprite, surface_sprite, 0);
        var indexed_sprite = sprite_create_from_surface(surface_sprite, 0, 0, sw, sh, false, false, 0, 0);
        
        buffer_delete(buffer_sprite);
        surface_free(surface_sprite);
        buffer_delete(palette_buffer);
        surface_free(palette_surface);
        
        self.palette = palette_sprite;
        self.data = [palette_array];
        
        show_debug_message($"Palette extraction took {(get_timer() - t) / 1000} ms");
        
        return indexed_sprite;
    };
    
    static FromImage = function(palette_sprite) {
        if (self.palette != undefined && sprite_exists(self.palette)) sprite_delete(self.palette);
        
        var s = surface_create(sprite_get_width(palette_sprite), sprite_get_height(palette_sprite));
        surface_set_target(s);
        draw_clear(c_black);
        gpu_set_blendmode(bm_add);
        draw_sprite(palette_sprite, 0, 0, 0);
        gpu_set_blendmode(bm_normal);
        surface_reset_target();
    
        var buffer = buffer_create(surface_get_width(s) * surface_get_height(s) * 4, buffer_fixed, 4);
        buffer_get_surface(buffer, s, 0);
    
        var data = array_create(sprite_get_height(palette_sprite), -1);
        buffer_seek(buffer, buffer_seek_start, 0);
        for (var j = 0, nh = sprite_get_height(palette_sprite); j < nh; j++) {
            data[j] = array_create(sprite_get_width(palette_sprite));
            for (var i = 0, nw = sprite_get_width(palette_sprite); i < nw; i++) {
                data[j][i] = buffer_read(buffer, buffer_u32) & 0x00ffffff;
            }
        }
    
        surface_free(s);
        buffer_delete(buffer);
        
        self.palette = palette_sprite;
        self.data = data;
    };
    
    static Modify = function(x, y, color) {
        if (color == self.data[y][x]) return;
        self.data[y][x] = color;
        var s = surface_create(sprite_get_width(self.palette), sprite_get_height(self.palette));
        surface_set_target(s);
        draw_clear_alpha(c_black, 0);
        var bm = gpu_get_blendmode();
        gpu_set_blendmode(bm_add);
        var a = draw_get_alpha();
        draw_set_alpha(1);
        draw_sprite(self.palette, 0, 0, 0);
        gpu_set_blendmode(bm_normal);
        draw_point_colour(x, y, color);
        gpu_set_blendmode(bm);
        draw_set_alpha(a);
        surface_reset_target();
        if (self.palette != undefined && sprite_exists(self.palette)) sprite_delete(self.palette);
        self.palette = sprite_create_from_surface(s, 0, 0, surface_get_width(s), surface_get_height(s), false, false, 0, 0);
        surface_free(s);
    };
    
    static Refresh = function() {
        var s = surface_create(power(2, ceil(log2(array_length(self.data[0])))), array_length(self.data));
        surface_set_target(s);
        draw_clear(c_white);
        var a = draw_get_alpha();
        draw_set_alpha(1);
        for (var i = 0, n = array_length(self.data); i < n; i++) {
            for (var j = 0, n2 = array_length(self.data[i]); j < n2; j++) {
                draw_point_colour(j, i, self.data[i][j]);
            }
        }
        draw_set_alpha(a);
        surface_reset_target();
        if (sprite_exists(self.palette)) sprite_delete(self.palette);
        self.palette = sprite_create_from_surface(s, 0, 0, surface_get_width(s), surface_get_height(s), false, false, 0, 0);
        surface_free(s);
    };
    
    static AddPaletteRow = function(source_row = -1) {
        source_row = (source_row == -1) ? (array_length(self.data) - 1) : source_row;
        var final_row = self.data[source_row];
        var new_row = array_create(array_length(final_row));
        array_copy(new_row, 0, final_row, 0, array_length(final_row));
        array_push(self.data, new_row);
        
        var s = surface_create(sprite_get_width(self.palette), sprite_get_height(self.palette) + 1);
        surface_set_target(s);
        draw_clear_alpha(c_black, 1);
        var bm = gpu_get_blendmode();
        gpu_set_blendmode(bm_add);
        var a = draw_get_alpha();
        draw_set_alpha(1);
        draw_sprite(self.palette, 0, 0, 0);
        gpu_set_blendmode(bm_normal);
        if (source_row != -1) {
            draw_sprite_part(self.palette, 0, 0, source_row, sprite_get_width(self.palette), 1, 0, sprite_get_height(self.palette));
        }
        gpu_set_blendmode(bm);
        draw_set_alpha(a);
        surface_reset_target();
        self.palette = sprite_create_from_surface(s, 0, 0, surface_get_width(s), surface_get_height(s), false, false, 0, 0);
        surface_free(s);
    };
    
    static RemovePaletteRow = function(row = array_length(self.data) - 1) {
        if (array_length(self.data) == 1) return;
        array_delete(self.data, row, 1);
        var s = surface_create(sprite_get_width(self.palette), sprite_get_height(self.palette) - 1);
        surface_set_target(s);
        draw_clear_alpha(c_black, 1);
        var bm = gpu_get_blendmode();
        gpu_set_blendmode(bm_add);
        var a = draw_get_alpha();
        draw_set_alpha(1);
        draw_sprite_part(self.palette, 0, 0, 0, sprite_get_width(self.palette), row, 0, 0);
        draw_sprite_part(self.palette, 0, 0, row + 1, sprite_get_width(self.palette), sprite_get_height(self.palette) - row, 0, row);
        gpu_set_blendmode(bm);
        draw_set_alpha(a);
        surface_reset_target();
        if (self.palette != undefined && sprite_exists(self.palette)) sprite_delete(self.palette);
        self.palette = sprite_create_from_surface(s, 0, 0, surface_get_width(s), surface_get_height(s), false, false, 0, 0);
        surface_free(s);
    };
    
    static GetRGBSprite = function(sprite, palette_index) {
        var s = array_length(self.data[palette_index]);
        var w = sprite_get_width(sprite);
        var h = sprite_get_height(sprite);
        var surface = surface_create(w, h);
        surface_set_target(surface);
        draw_clear_alpha(c_black, 0);
        gpu_set_blendmode(bm_add);
        draw_sprite(sprite, 0, 0, 0);
        gpu_set_blendmode(bm_normal);
        surface_reset_target();
        
        var sprite_data = buffer_create(w * h * 4, buffer_fixed, 1);
        buffer_get_surface(sprite_data, surface, 0);
        
        for (var i = 0, n = w * h * 4; i < n; i += 4) {
            var buffer_value = buffer_peek(sprite_data, i, buffer_u32);
            var buffer_index = (buffer_value & 0xff) / 256 * s;
            var buffer_alpha = buffer_value & 0xff000000;
            buffer_poke(sprite_data, i, buffer_u32, buffer_alpha | self.data[palette_index][buffer_index]);
        }
        
        buffer_set_surface(sprite_data, surface, 0);
        var color_sprite = sprite_create_from_surface(surface, 0, 0, w, h, false, false, 0, 0);
        surface_free(surface);
        buffer_delete(sprite_data);
        
        return color_sprite;
    };
    
    if (source_palette != undefined && sprite_exists(source_palette)) {
        self.FromImage(source_palette);
    }
}