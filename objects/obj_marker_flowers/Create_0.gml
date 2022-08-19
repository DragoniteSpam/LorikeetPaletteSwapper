var area = (self.sprite_width * self.sprite_height) / 1024;
var count = area * 6;

repeat (count) {
    var ww = random(self.sprite_width);
    var hh = random(self.sprite_height);
    instance_create_depth(self.x + ww, self.y + hh, 0, obj_flowers);
}

instance_destroy();