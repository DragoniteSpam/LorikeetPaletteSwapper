function sprite_atlas_cheap(sprites) {
    array_sort(sprites, function(a, b) {
        return sprite_get_width(b) - sprite_get_width(a);
    });
    
    var count = array_length(sprites);
    var positions = array_create(count);
    
    var xx = 0;
    var yy = 0;
    var maxw = 0;
    var maxh = 0;
    
    var padding = 2;
    var limit = 4096;
    
    for (var i = 0; i < count; i++) {
        var sprite = sprites[i];
        positions[i] = {
            x: xx,
            y: yy,
            w: sprite_get_width(sprite),
            h: sprite_get_height(sprite),
            sprite: sprites[i]
        };
        
        maxw = max(maxw, xx + sprite_get_width(sprite) + padding);
        
        if (yy + sprite_get_height(sprite) + padding > limit) {
            yy = 0;
            xx = maxw;
        } else {
            yy += sprite_get_height(sprite) + padding;
        }
        
        maxh = max(maxh, yy);
    }
    
    var surface = surface_create(maxw, maxh);
    surface_set_target(surface);
    draw_clear_alpha(c_black, 0);
    gpu_set_blendmode(bm_add);
    
    array_foreach(positions, function(data) {
        draw_sprite(data.sprite, 0, data.x, data.y);
    });
    
    gpu_set_blendmode(bm_normal);
    surface_reset_target();
    
    var atlas = sprite_create_from_surface(surface, 0, 0, maxw, maxh, false, false, 0, 0);
    surface_free(surface);
    
    return {
        atlas: atlas,
        uvs: positions
    };
}