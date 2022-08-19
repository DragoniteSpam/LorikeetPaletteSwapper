event_inherited();

self.direction = 270;
self.velocity = 0;

self.state = EDuckStates.SWIMMING;

enum EDuckStates {
    WALKING,
    SWIMMING
}

self.swim_sound_enabled = true;
self.grass_sound_enabled = true;
self.volume_grass = 0;
self.volume_water = 1;