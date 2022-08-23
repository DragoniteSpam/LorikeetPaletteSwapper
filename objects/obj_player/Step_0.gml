var dx = 0, dy = 0;
var mspd = 120;
if (input_check("left")) {
    dx -= mspd;
}
if (input_check("right")) {
    dx += mspd;
}
if (input_check("up")) {
    dy -= mspd;
}
if (input_check("down")) {
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

var previous_state = self.state;

if (place_meeting(self.x, self.y, obj_marker_water)) {
    self.state = EDuckStates.SWIMMING;
    if ((dx != 0 || dy != 0) && random(1) < 0.5) {
        obj_demo.ParticlesBurst(obj_demo.spart_emitter_water, obj_demo.spart_type_water, self.x, self.y, 0, 1);
        if (self.swim_sound_enabled) {
            self.swim_sound_enabled = false;
            call_later(random_range(0.4, 0.75), time_source_units_seconds, function() {
                self.swim_sound_enabled = true;
            });
            audio_play_sound(se_swim, 90, false, random_range(0.8, 0.95) * VOLUME_SE, 0, random_range(0.95, 1.1));
        }
    }
    if (previous_state != self.state) {
        obj_demo.ParticlesBurst(obj_demo.spart_emitter_water, obj_demo.spart_type_water_splash, self.x, self.y, 0, 64);
        audio_play_sound(se_splash, 100, false, VOLUME_SE);
    }
    self.volume_water = min(self.volume_water + MUSIC_FADE_RATE, 1);
} else {
    self.volume_water = max(self.volume_water - MUSIC_FADE_RATE, 0);
    self.state = EDuckStates.WALKING;
    if (previous_state != self.state) {
        obj_demo.ParticlesBurst(obj_demo.spart_emitter_water, obj_demo.spart_type_water_splash_small, self.x, self.y, 0, 24);
    }
}

audio_sound_gain(bgm_strings, self.volume_water * VOLUME_BGM, 0);
audio_sound_gain(bgm_woodwinds, (1 - self.volume_water) * VOLUME_BGM, 0);

if (place_meeting(self.x, self.y, obj_marker_grass)) {
    if ((dx != 0 || dy != 0) && random(1) < 0.125) {
        obj_demo.ParticlesBurst(obj_demo.spart_emitter_grass, obj_demo.spart_type_grass, self.x, self.y, 0, 1);
        if (self.grass_sound_enabled) {
            self.grass_sound_enabled = false;
            call_later(random_range(0.25, 0.4), time_source_units_seconds, function() {
                self.grass_sound_enabled = true;
            });
            var grass_sounds = [
                se_grass_0, se_grass_1, se_grass_2,
                se_grass_3, se_grass_4, se_grass_5,
            ];
            audio_play_sound(grass_sounds[irandom(array_length(grass_sounds) - 1)], 90, false, random_range(0.8, 0.9) * VOLUME_SE, 0, random_range(0.95, 1.5));
        }
    }
}