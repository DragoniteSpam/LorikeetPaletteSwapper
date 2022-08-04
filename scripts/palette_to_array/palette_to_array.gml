function palette_to_array(sprite) {
    var s = surface_create(sprite_get_width(sprite), 1);
    surface_set_target(s);
    draw_clear(c_black);
    gpu_set_blendmode(bm_add);
    draw_sprite(sprite, 0, 0, 0);
    gpu_set_blendmode(bm_normal);
    surface_reset_target();
    
    var buffer = buffer_create(surface_get_width(s) * surface_get_height(s) * 4, buffer_fixed, 4);
    buffer_get_surface(buffer, s, 0);
    
    var data = array_create(sprite_get_width(sprite), -1);
    buffer_seek(buffer, buffer_seek_start, 0);
    for (var i = 0, n = array_length(data); i < n; i++) {
        data[i] = buffer_read(buffer, buffer_u32) & 0x00ffffff;
    }
    
    surface_free(s);
    buffer_delete(buffer);
    
    return data;
}