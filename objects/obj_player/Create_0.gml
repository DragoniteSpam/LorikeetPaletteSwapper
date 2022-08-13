event_inherited();

self.direction = 270;
self.velocity = 0;

self.state = EDuckStates.WALKING;

enum EDuckStates {
    WALKING,
    SWIMMING
}