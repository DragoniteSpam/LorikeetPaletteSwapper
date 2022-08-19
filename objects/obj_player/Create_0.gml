event_inherited();

self.direction = 270;
self.velocity = 0;

self.state = EDuckStates.SWIMMING;

enum EDuckStates {
    WALKING,
    SWIMMING
}