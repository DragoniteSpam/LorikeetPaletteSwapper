function lorikeet_palette_modify(sprite, x, y, color) {
    var s = surface_create(sprite_get_width(sprite), sprite_get_height(sprite));
    surface_set_target(s);
    draw_clear_alpha(c_black, 0);
    var bm = gpu_get_blendmode();
    gpu_set_blendmode(bm_add);
    var a = draw_get_alpha();
    draw_set_alpha(1);
    draw_sprite(sprite, 0, 0, 0);
    gpu_set_blendmode(bm_normal);
    draw_point_colour(x, y, color);
    gpu_set_blendmode(bm);
    draw_set_alpha(a);
    surface_reset_target();
    sprite = sprite_create_from_surface(s, 0, 0, surface_get_width(s), surface_get_height(s), false, false, 0, 0);
    surface_free(s);
    return sprite;
}