function lorikeet_palette_delete_palette(palette_sprite, row) {
    var s = surface_create(sprite_get_width(palette_sprite), sprite_get_height(palette_sprite) - 1);
    surface_set_target(s);
    draw_clear_alpha(c_black, 1);
    var bm = gpu_get_blendmode();
    gpu_set_blendmode(bm_add);
    var a = draw_get_alpha();
    draw_set_alpha(1);
    draw_sprite_part(palette_sprite, 0, 0, 0, sprite_get_width(palette_sprite), row, 0, 0);
    draw_sprite_part(palette_sprite, 0, 0, row + 1, sprite_get_width(palette_sprite), sprite_get_height(palette_sprite) - row, 0, row);
    gpu_set_blendmode(bm);
    draw_set_alpha(a);
    surface_reset_target();
    palette_sprite = sprite_create_from_surface(s, 0, 0, surface_get_width(s), surface_get_height(s), false, false, 0, 0);
    surface_free(s);
    return palette_sprite;
}