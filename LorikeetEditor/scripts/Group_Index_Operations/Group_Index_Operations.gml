function index_extend_colors(sprite, frame) {
    var sw = sprite_get_width(sprite);
    var sh = sprite_get_height(sprite);
    var surface = surface_create(sw, sh);
    surface_set_target(surface);
    draw_clear_alpha(c_black, 0);
    gpu_set_blendmode(bm_add);
    shader_set(shd_colors_reduce);
    draw_sprite(sprite, frame, sprite_get_xoffset(sprite), sprite_get_yoffset(sprite));
    gpu_set_blendmode(bm_normal);
    shader_reset();
    surface_reset_target();
    
    var reduced_sprite = sprite_create_from_surface(surface, 0, 0, sw, sh, false, false, sprite_get_xoffset(sprite), sprite_get_yoffset(sprite));
    surface_free(surface);
    
    return reduced_sprite;
}

function index_generate_outlines(sprite, outline_value) {
    var w = sprite_get_width(sprite);
    var h = sprite_get_height(sprite);
    var xo = sprite_get_xoffset(sprite);
    var yo = sprite_get_yoffset(sprite);
    
    var cropped = sprite_get_cropped_dimensions(sprite);
    var pad_left = cropped.xmin == 0;
    var pad_top = cropped.ymin == 0;
    var pad_right = cropped.xmax == w;
    var pad_bottom = cropped.ymax == h;
    
    var output_width = w + pad_left + pad_right;
    var output_height = h + pad_top + pad_bottom;
    var output_xoffset = xo + pad_left;
    var output_yoffset = yo + pad_top;
    
    var surface = surface_create(output_width, output_height);
    surface_set_target(surface);
    gpu_set_blendmode(bm_add);
    shader_set(shd_bake_outline);
    shader_set_uniform_f(shader_get_uniform(shd_bake_outline, "u_outline_value"), outline_value);
    draw_sprite(sprite, 0, xo, yo);
    shader_reset();
    gpu_set_blendmode(bm_normal);
    surface_reset_target();
    
    var output_sprite = sprite_create_from_surface(surface, 0, 0, output_width, output_height, false, false, output_xoffset, output_yoffset);
    surface_free(surface);
    
    return output_sprite;
}