matrix_set(matrix_world, matrix_build(self.x, self.y, 0, 90, 0, 0, 1, 1, 1));
lorikeet_set(self.palette_sprite, self.palette_index);
draw_sprite(self.sprite_index, ceil(self.image_index), 0, 0);