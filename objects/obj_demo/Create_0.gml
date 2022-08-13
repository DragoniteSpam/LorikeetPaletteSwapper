self.depth = 0;
self.player = instance_exists(obj_player) ? obj_player.id : instance_create_depth(64, 64, 0, obj_player);

self.camera = new DragoCamera(0, 0, 100, 100, 100, 0, 0, 0, 1, 60, 1, 10000);
self.camera.Update = method(self, function() {
    var dist = 160;
    var angle = 30;
    self.camera.x = self.player.x;
    self.camera.y = self.player.y + dcos(angle) * dist;
    self.camera.z = /*self.player.z*/ + dsin(angle) * dist;
    self.camera.xto = self.player.x;
    self.camera.yto = self.player.y;
    self.camera.zto = 0;
});

var layer_id = layer_get_id("Tiles_1");
layer_set_visible(layer_id, false);
self.ground_tilemap = layer_tilemap_get_id(layer_id);

window_set_size(1600, 900);
surface_resize(application_surface, 1600, 900);
application_surface_draw_enable(false);