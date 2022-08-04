function lorikeet_extract_palette_data(sprite, index = 0, force_full_palette = false) {
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
    
    var step = buffer_sizeof(buffer_u32);
    repeat (buffer_get_size(buffer_sprite) / step) {
        var cc = buffer_read(buffer_sprite, buffer_u32) & 0x00ffffff;
        map[$ string(cc)] ??= { color: cc, count: 0, rank: -1 };
        map[$ string(cc)].count++;
    }
    
    var keys = variable_struct_get_names(map);
    var sorting = array_create(array_length(keys), 0);
    var palette_array = array_create(array_length(keys), -1);
    
    for (var i = 0, n = array_length(keys); i < n; i++) {
        sorting[i] = map[$ keys[i]];
    }
    
    array_sort(sorting, function(a, b) {
        return b.count - a.count;
    });
    
    // to do: quantize colors properly
    
    for (var i = 0, n = array_length(sorting); i < n; i++) {
        palette_array[i] = sorting[i].color;
        sorting[i].rank = i;
    }
    
    var count = array_length(palette_array);
    var palette_size = force_full_palette ? 256 : min(256, power(2, ceil(log2(count))));
    array_resize(palette_array, palette_size);
    
    for (var i = count, n = array_length(palette_array); i < n; i++) {
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
        var rank = map[$ string(cc & 0x00ffffff)].rank * palette_color_spacing;
        buffer_poke(buffer_sprite, i, buffer_u32, (cc & 0xff000000) | make_colour_rgb(rank, rank, rank));
    }
    
    buffer_set_surface(buffer_sprite, surface_sprite, 0);
    var indexed_sprite = sprite_create_from_surface(surface_sprite, 0, 0, sw, sh, false, false, 0, 0);
    
    buffer_delete(buffer_sprite);
    surface_free(surface_sprite);
    buffer_delete(palette_buffer);
    surface_free(palette_surface);
    
    show_debug_message("Palette extraction took " + string((get_timer() - t) / 1000) + " ms");
    
    return { indexed_sprite: indexed_sprite, palette_array: palette_array, palette_sprite: palette_sprite };
}