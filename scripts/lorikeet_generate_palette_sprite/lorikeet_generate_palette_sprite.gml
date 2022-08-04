function lorikeet_generate_palette_sprite(data) {
    var s = surface_create(power(2, ceil(log2(array_length(data)))), 1);
    surface_set_target(s);
    draw_clear(c_white);
    var a = draw_get_alpha();
    draw_set_alpha(1);
    for (var i = 0, n = array_length(data); i < n; i++) {
        draw_point_colour(i, 0, data[i]);
    }
    draw_set_alpha(a);
    surface_reset_target();
    var sprite = sprite_create_from_surface(s, 0, 0, surface_get_width(s), surface_get_height(s), false, false, 0, 0);
    surface_free(s);
    return sprite;
}