function lorikeet_extract_palette(sprite, index) {
    var t = get_timer();
    
    var map = { };
    var s = surface_create(sprite_get_width(sprite), sprite_get_height(sprite));
    surface_set_target(s);
    draw_clear_alpha(c_black, 0);
    gpu_set_blendmode(bm_add);
    draw_sprite(sprite, index, 0, 0);
    gpu_set_blendmode(bm_normal);
    surface_reset_target();
    var buffer = buffer_create(sprite_get_width(sprite) * sprite_get_height(sprite) * 4, buffer_fixed, 4);
    buffer_get_surface(buffer, s, 0);
    buffer_seek(buffer, buffer_seek_start, 0);
    surface_free(s);
    
    var step = buffer_sizeof(buffer_u32);
    for (var i = 0, n = buffer_get_size(buffer); i < n; i += step) {
        var cc = buffer_read(buffer, buffer_u32) & 0x00ffffff;
        map[$ string(cc)] ??= 0;
        map[$ string(cc)]++;
    }
    
    buffer_delete(buffer);
    
    var keys = variable_struct_get_names(map);
    var sorting = array_create(array_length(keys), 0);
    var results = array_create(array_length(keys), -1);
    
    for (var i = 0, n = array_length(keys); i < n; i++) {
        sorting[i] = { color: real(keys[i]), count: map[$ keys[i]] };
    }
    
    array_sort(sorting, function(a, b) {
        return b.count - a.count;
    });
    
    // to do: quantize colors properly
    
    for (var i = 0, n = array_length(sorting); i < n; i++) {
        results[i] = sorting[i].color;
    }
    
    var count = array_length(results);
    array_resize(results, 256);
    
    for (var i = count, n = array_length(results); i < n; i++) {
        results[i] = -1;
    }
    
    show_debug_message("Palette extraction took " + string((get_timer() - t) / 1000) + " ms");
    
    return results;
}