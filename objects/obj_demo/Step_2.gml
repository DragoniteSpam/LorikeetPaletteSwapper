self.camera.Update();

self.game_time += GAME_UPDATE_TIME;
self.game_time %= 1;
show_debug_message(string_format(game_time, 1, 4));