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

function index_generate_outlines(sprite, outline_value, use_diagonals) {
    var w = sprite_get_width(sprite);
    var h = sprite_get_height(sprite);
    var xo = sprite_get_xoffset(sprite);
    var yo = sprite_get_yoffset(sprite);
    
    var cropped = sprite_get_cropped_dimensions(sprite);
    var pad_left = cropped.xmin == 0;
    var pad_top = cropped.ymin == 0;
    var pad_right = cropped.xmax == w - 1;
    var pad_bottom = cropped.ymax == h - 1;
    
    var output_width = w + pad_left + pad_right;
    var output_height = h + pad_top + pad_bottom;
    var output_xoffset = pad_left;
    var output_yoffset = pad_top;
    
    gpu_set_blendmode(bm_add);
    
    // draw the sprite onto a surface of the new size first, so that any extra pixels around
    // the edge will be properly accounted for
    var surface_base_size = surface_create(output_width, output_height);
    draw_clear_alpha(c_black, 0);
    surface_set_target(surface_base_size);
    draw_sprite(sprite, 0, output_xoffset, output_yoffset);
    surface_reset_target();
    
    // bake the outlines using the surface with a potentially larger size
    var surface_outline = surface_create(output_width, output_height);
    surface_set_target(surface_outline);
    draw_clear_alpha(c_black, 0);
    shader_set(shd_bake_outline);
    shader_set_uniform_f(shader_get_uniform(shd_bake_outline, "u_outline_value"), outline_value);
    shader_set_uniform_f(shader_get_uniform(shd_bake_outline, "u_use_diagonals"), use_diagonals);
    draw_surface(surface_base_size, 0, 0);
    shader_reset();
    surface_reset_target();
    
    var output_sprite = sprite_create_from_surface(surface_outline, 0, 0, output_width, output_height, false, false, 0, 0);
    surface_free(surface_outline);
    surface_free(surface_base_size);
    gpu_set_blendmode(bm_normal);
    
    return output_sprite;
}