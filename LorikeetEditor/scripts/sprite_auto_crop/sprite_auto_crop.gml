function sprite_auto_crop(sprite, w, h) {
	var frames = sprite_get_number(sprite);
	
	gpu_set_blendmode(bm_add);
	
	var cropped_dimensions = sprite_get_cropped_dimensions(sprite);
	
	var cw = cropped_dimensions.xmax - cropped_dimensions.xmin;
	var ch = cropped_dimensions.ymax - cropped_dimensions.ymin;
	
	var cropped_surface = surface_create(frames * cw, ch);
	surface_set_target(cropped_surface);
	draw_clear_alpha(c_black, 0);
	
	for (var i = 0; i < frames; i++) {
		var xx = i * cw;
		draw_sprite_part(sprite, i, cropped_dimensions.xmin, cropped_dimensions.ymin, cw, ch, xx, 0);
	}
	
	surface_reset_target();
	var cropped_sprite = sprite_create_from_surface(cropped_surface, 0, 0, surface_get_width(cropped_surface), surface_get_height(cropped_surface), false, false, 0, 0);
	
	surface_free(cropped_surface);
	gpu_set_blendmode(bm_normal);
	
	return cropped_sprite;
}

function sprite_get_cropped_dimensions(sprite) {
    var w = sprite_get_width(sprite);
    var h = sprite_get_height(sprite);
	var xmin = 0;
	var ymin = 0;
	var xmax = w;
	var ymax = h;
    
    var frames = sprite_get_number(sprite);
    
    gpu_set_blendmode(bm_add);
    
    // write the pixel data of every frame to a buffer
	var buffers = array_create_ext(frames, method({ xmax, ymax, sprite }, function(i) {
		var surface = surface_create(self.xmax, self.ymax);
		surface_set_target(surface);
		draw_clear_alpha(c_black, 0);
		draw_sprite(self.sprite, i, 0, 0);
		surface_reset_target();
		var buffer = buffer_create(self.xmax * self.ymax * 4, buffer_fixed, 1);
		buffer_get_surface(buffer, surface, 0);
		surface_free(surface);
		return buffer;
	}));
	
	var test_pixel = function(buffers, i, j, w, h) {
		var addr = (j * w + i) * 4;
		return array_any(buffers, method({ addr }, function(buffer) {
			var a = buffer_peek(buffer, self.addr, buffer_u8);
			return a != 0;
		}));
	};
	
	// walk across the sprite and work out the min/max on the horizontal
	for (var i = 0; i < w; i++) {
		var found = false;
		for (var j = 0; j < h; j++) {
			if (test_pixel(buffers, i, j, w, h)) {
				found = true;
				break;
			}
		}
		if (found) break;
		xmin++;
	}
	for (var i = w - 1; i >= xmin; i--) {
		var found = false;
		for (var j = 0; j < h; j++) {
			if (test_pixel(buffers, i, j, w, h)) {
				found = true;
				break;
			}
		}
		if (found) break;
		xmax--;
	}
	
	// walk across the sprite and work out the min/max on the vertical
	for (var j = 0; j < h; j++) {
		var found = false;
		for (var i = xmin; i <= xmax; i++) {
			if (test_pixel(buffers, i, j, w, h)) {
				found = true;
				break;
			}
		}
		if (found) break;
		ymin++;
	}
	for (var j = h - 1; j >= ymin; j--) {
		var found = false;
		for (var i = xmin; i < xmax; i++) {
			if (test_pixel(buffers, i, j, w, h)) {
				found = true;
				break;
			}
		}
		if (found) break;
		ymax--;
	}
    
	array_foreach(buffers, buffer_delete);
    
    gpu_set_blendmode(bm_normal);
    
    return {
        xmin,
        xmax,
        ymin,
        ymax
    };
}