if (abs(obj_demo.camera.y - self.y) >= 64 && obj_demo.camera.Dot2D(self.x, self.y) < dcos(obj_demo.camera.fov)) return;

draw_sprite_general(
    self.sprite_index, ceil(self.image_index), 0, 0,
    self.sprite_width, self.sprite_height, self.x - self.sprite_xoffset, self.y - self.sprite_yoffset, 1, 1, 0,
    self.sprite_height, self.sprite_height, c_black, c_black, 1
);

obj_demo.instances_rendered++;