function operation_shift_left(data) {
    var value0 = data[0];
    array_delete(data, 0, 1);
    array_push(data, -1);
    for (var i = 0, n = array_length(data); i < n; i++) {
        if (data[i] == -1) {
            data[i] = value0;
            break;
        }
    }
}

function operation_shift_right(data) {
    for (var i = array_length(data) - 1; i >= 0; i--) {
        if (data[i] != -1) {
            array_insert(data, 0, data[i]);
            array_delete(data, i + 1, 1);
            break;
        }
    }
}

function operation_update_hsv(data, h, s, v) {
    for (var i = 0, n = array_length(data); i < n; i++) {
        var cc = data[i];
        var hh = (colour_get_hue(cc) + (h / 360 * 255) + 255) % 255;
        var ss = clamp(colour_get_saturation(cc) + s - v, 0, 255);
        var vv = clamp(colour_get_value(cc) + v, 0, 255);
        data[i] = make_colour_hsv(hh, ss, vv);
    }
}

function operation_update_hsv_percent(data, h, s, v) {
    for (var i = 0, n = array_length(data); i < n; i++) {
        var cc = data[i];
        // hue is still done the normal way since it's cyclical
        var hh = (colour_get_hue(cc) + (h / 360 * 255) + 255) % 255;
        var ss = clamp(colour_get_saturation(cc) * s, 0, 255);
        var vv = clamp(colour_get_value(cc) * v, 0, 255);
        data[i] = make_colour_hsv(hh, ss, vv);
    }
}

function operation_update_rgb(data, r, g, b) {
    for (var i = 0, n = array_length(data); i < n; i++) {
        var cc = data[i];
        var rr = clamp(colour_get_red(cc) + r, 0, 255);
        var gg = clamp(colour_get_green(cc) + g, 0, 255);
        var bb = clamp(colour_get_blue(cc) + b, 0, 255);
        data[i] = make_colour_rgb(rr, gg, bb);
    }
}

function operation_update_rgb_percent(data, r, g, b) {
    for (var i = 0, n = array_length(data); i < n; i++) {
        var cc = data[i];
        var rr = clamp(colour_get_red(cc) * r, 0, 255);
        var gg = clamp(colour_get_green(cc) * g, 0, 255);
        var bb = clamp(colour_get_blue(cc) * b, 0, 255);
        data[i] = make_colour_rgb(rr, gg, bb);
    }
}