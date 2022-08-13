if (self.direction <= 45) {
    self.sprite_index = idx_duck_right;
} else if (self.direction < 135) {
    self.sprite_index = idx_duck_up;
} else if (self.direction <= 225) {
    self.sprite_index = idx_duck_left;
} else if (self.direction < 315) {
    self.sprite_index = idx_duck_down;
} else {
    self.sprite_index = idx_duck_right;
}

if (self.velocity > 0) {
    var animation_speed = 6;
    self.image_index += animation_speed * DT;
    if (self.image_index > sprite_get_number(self.sprite_index) + 1) {
        self.image_index -= 2;
    }
} else {
    self.image_index = 0;
}

event_inherited();