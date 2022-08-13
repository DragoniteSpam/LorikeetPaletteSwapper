var hh = floor(self.game_time * 24);
var mm = floor(((self.game_time * 24) % 1) * 60);
scribble("Current time: " + string(hh) + ":" + string_replace(string_format(mm, 2, 0), " ", "0"))
    .draw(32, 32);
scribble("FPS: " + string(fps))
    .draw(32, 64);