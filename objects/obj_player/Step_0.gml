var dx = 0, dy = 0;
var mspd = 120;
if (keyboard_check(vk_left) || keyboard_check(ord("A"))) {
    dx -= mspd;
}
if (keyboard_check(vk_right) || keyboard_check(ord("D"))) {
    dx += mspd;
}
if (keyboard_check(vk_up) || keyboard_check(ord("W"))) {
    dy -= mspd;
}
if (keyboard_check(vk_down) || keyboard_check(ord("S"))) {
    dy += mspd;
}

dx *= DT;
dy *= DT;

repeat (abs(dx)) {
    if (place_meeting(self.x + sign(dx), self.y, obj_solid)) break;
    self.x += sign(dx);
}

repeat (abs(dy)) {
    if (place_meeting(self.x, self.y + sign(dy), obj_solid)) break;
    self.y += sign(dy);
}

self.velocity = point_distance(0, 0, dx, dy);
if (self.velocity > 0) {
    self.direction = point_direction(0, 0, dx, dy);
}