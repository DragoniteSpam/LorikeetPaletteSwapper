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