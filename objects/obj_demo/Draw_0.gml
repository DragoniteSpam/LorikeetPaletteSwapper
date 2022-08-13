self.camera.SetProjection();

draw_tilemap(self.ground_tilemap, 0, 0);

with (self.player) draw_sprite(self.sprite_index, 0, self.x, self.y);