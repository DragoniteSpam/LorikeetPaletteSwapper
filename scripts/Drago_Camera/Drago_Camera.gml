function DragoCamera(x, y, z, xto, yto, zto, xup, yup, zup, fov, znear, zfar) constructor {
    self.def_x = x;
    self.def_y = y;
    self.def_z = z;
    self.def_xto = xto;
    self.def_yto = yto;
    self.def_zto = zto;
    self.def_xup = xup;
    self.def_yup = yup;
    self.def_zup = zup;
    self.def_fov = fov;
    self.def_pitch = darctan2(z - zto, point_distance(x, y, xto, yto));
    self.def_direction = point_direction(x, y, xto, yto);
    
    self.camera = camera_create();
    
    self.znear = znear;
    self.zfar = zfar;
    
    self.center = new Vector2(window_get_width() / 2, window_get_height() / 2);
    
    self.x = x;
    self.y = y;
    self.z = z;
    self.xto = xto;
    self.yto = yto;
    self.zto = zto;
    self.xup = xup;
    self.yup = yup;
    self.zup = zup;
    self.fov = fov;
    self.direction = self.def_direction;
    self.pitch = self.def_pitch;
    
    self.scale = 1;
    self.base_speed = 256;
    self.accelerate_time = 6;
    
    self.run_enabled = true;
    self.run_speed = 3.2;
    self.run_fov = 1.2;
    self.run_fov_active = 1;
    self.running = false;
    self.run_key = vk_shift;
    
    self.view_mat = undefined;
    self.proj_mat = undefined;
    
    self.skybox = -1;
    self.skybox_mesh = -1;
    
    self.get_width = function() {
        return window_get_width();
    };
    
    self.get_height = function() {
        return window_get_height();
    };
    
    self.SetViewportAspect = function(width_function, height_function) {
        self.get_width = method(self, width_function);
        self.get_height = method(self, height_function);
        return self;
    };
    
    self.SetCenter = function(cx, cy) {
        self.center.x = cx;
        self.center.y = cy;
        return self;
    };
    
    self.SetSkybox = function(vertex_buffer, sprite) {
        self.skybox = sprite;
        self.skybox_mesh = vertex_buffer;
        return self;
    };
    
    self.GetCameraSpeed = function(z = self.z) {
        return max(1, (self.base_speed * (logn(32, max(z, 1)) + 1)) * (1 / game_get_speed(gamespeed_fps))) * (self.running ? self.run_speed : 1);
    };
    
    self.Update = function() {
        
    };
    
    self.UpdateFree = function() {
        self.running = self.run_enabled && keyboard_check(self.run_key);
        self.run_fov_active = lerp(self.run_fov_active, self.running ? self.run_fov : 1, 0.05);
        
        // move the camera
        var mspd = self.GetCameraSpeed();
        var xspeed = 0;
        var yspeed = 0;
        var zspeed = 0;
        
        if (keyboard_check(vk_up) || keyboard_check(ord("W"))) {
            xspeed += dcos(self.direction) * mspd;
            yspeed -= dsin(self.direction) * mspd;
            zspeed -= dsin(self.pitch) * mspd;
        }
        
        if (keyboard_check(vk_down) || keyboard_check(ord("S"))) {
            xspeed -= dcos(self.direction) * mspd;
            yspeed += dsin(self.direction) * mspd;
            zspeed += dsin(self.pitch) * mspd;
        }
        
        if (keyboard_check(vk_left) || keyboard_check(ord("A"))) {
            xspeed -= dsin(self.direction) * mspd;
            yspeed -= dcos(self.direction) * mspd;
        }
        
        if (keyboard_check(vk_right) || keyboard_check(ord("D"))) {
            xspeed += dsin(self.direction) * mspd;
            yspeed += dcos(self.direction) * mspd;
        }
        
        if (mouse_check_button_pressed(mb_middle)) {
            window_mouse_set(self.center.x, self.center.y);
        } else if (mouse_check_button(mb_middle)) {
            window_mouse_set(self.center.x, self.center.y);
            var dx = (mouse_x - self.center.x) / 16;
            var dy = (mouse_y - self.center.y) / 16;
            self.direction = (360 + self.direction - dx) % 360;
            self.pitch = clamp(self.pitch + dy, -89, 89);
            self.xto = self.x + dcos(self.direction) * dcos(self.pitch);
            self.yto = self.y - dsin(self.direction) * dcos(self.pitch);
            self.zto = self.z - dsin(self.pitch);
        }
        
        self.x += xspeed;
        self.y += yspeed;
        self.z += zspeed;
        self.xto += xspeed;
        self.yto += yspeed;
        self.zto += zspeed;
        self.xup = 0;
        self.yup = 0;
        self.zup = 1;
    };
    
    self.EndStep = function() {
        
    };
    
    self.SetProjection = function() {
        self.view_mat = matrix_build_lookat(self.x, self.y, self.z, self.xto, self.yto, self.zto, self.xup, self.yup, self.zup);
        self.proj_mat = matrix_build_projection_perspective_fov(-self.fov * self.run_fov_active, -self.get_width() / self.get_height(), self.znear, self.zfar);
        
        camera_set_view_mat(self.camera, self.view_mat);
        camera_set_proj_mat(self.camera, self.proj_mat);
        camera_apply(self.camera);
    };
    
    self.SetProjectionOrtho = function() {
        self.view_mat = matrix_build_lookat(self.x, self.y, self.zfar - 256, self.x, self.y, 0, 0, 1, 0);
        self.proj_mat = matrix_build_projection_ortho(-self.get_width() * self.scale, self.get_height() * self.scale, self.znear, self.zfar);
        
        camera_set_view_mat(self.camera, self.view_mat);
        camera_set_proj_mat(self.camera, self.proj_mat);
        camera_apply(self.camera);
    };
    
    self.SetProjectionGUI = function() {
        var view_mat = matrix_build_lookat(self.get_width() / 2, self.get_height() / 2, 1, self.get_width() / 2, self.get_height() / 2, -1, 0, -1, 0);
        var proj_mat = matrix_build_projection_ortho(self.get_width(), -self.get_height(), 1, 10);
        
        camera_set_view_mat(self.camera, view_mat);
        camera_set_proj_mat(self.camera, proj_mat);
        camera_apply(self.camera);
        
        gpu_set_ztestenable(false);
        gpu_set_zwriteenable(false);
        gpu_set_cullmode(cull_noculling);
        matrix_set(matrix_world, matrix_build_identity());
        shader_reset();
    };
    
    self.DrawSkybox = function() {
        if (!sprite_exists(self.skybox)) return;
        if (self.skybox_mesh = -1) return;
        matrix_set(matrix_world, matrix_build(self.x, self.y, self.z, 0, 0, 0, 1, 1, 1));
        vertex_submit(self.skybox_mesh, pr_trianglelist, sprite_get_texture(self.skybox, 0));
    };
    
    self.DrawSkyboxOrtho = function() {
        if (!sprite_exists(self.skybox)) return;
        if (self.skybox_buffer = -1) return;
        draw_clear_alpha(c_black, 1);
        gpu_set_zwriteenable(false);
        gpu_set_ztestenable(false);
        matrix_set(matrix_world, matrix_build(self.x, self.y, self.zfar - 256, 0, 0, 0, 1, 1, 1));
        vertex_submit(self.skybox_buffer, pr_trianglelist, sprite_get_texture(self.skybox, 0));
        gpu_set_zwriteenable(true);
        gpu_set_ztestenable(true);
    };
    
    self.Reset = function() {
        self.x = self.def_x;
        self.y = self.def_y;
        self.z = self.def_z;
        self.xto = self.def_xto;
        self.yto = self.def_yto;
        self.zto = self.def_zto;
        self.xup = self.def_xup;
        self.yup = self.def_yup;
        self.zup = self.def_zup;
        self.fov = self.def_fov;
        self.direction = self.def_direction;
        self.pitch = self.def_pitch;
        self.scale = 1;
    };
    
    self.Save = function() {
        return {
            x: self.x,
            y: self.y,
            z: self.z,
            xto: self.xto,
            yto: self.yto,
            zto: self.zto,
            xup: self.xup,
            yup: self.yup,
            zup: self.zup,
            fov: self.fov,
            direction: self.direction,
            pitch: self.pitch,
            base_speed: self.base_speed,
            accelerate_time: self.accelerate_time,
        };
    };
    
    self.Load = function(source) {
        try {
            self.x = source.x;
            self.y = source.y;
            self.z = source.z;
            self.xto = source.xto;
            self.yto = source.yto;
            self.zto = source.zto;
            self.xup = source.xup;
            self.yup = source.yup;
            self.zup = source.zup;
            self.fov = source.fov;
            self.direction = source.direction;
            self.pitch = source.pitch;
            self.base_speed = source.base_speed;
            self.accelerate_time = source.accelerate_time;
        } catch (e) {
            self.Reset();
        }
    };
    
    self.GetVPMatrix = function() {
        if (self.view_mat == undefined || self.proj_mat == undefined) return undefined;
        return matrix_multiply(self.view_mat, self.proj_mat);
    };
    
    self.DistanceTo = function(x, y, z) {
        return point_distance_3d(self.x, self.y, self.z, x, y, z);
    };
    
    self.DistanceTo2D = function(x, y) {
        return point_distance(self.x, self.y, x, y);
    };
    
    self.Dot = function(x, y, z) {
        return dot_product_3d_normalized(self.xto - self.x, self.yto - self.y, self.zto - self.z, x - self.x, y - self.y, z - self.z);
    };
    
    self.Dot2D = function(x, y) {
        return dot_product_normalized(self.xto - self.x, self.yto - self.y, x - self.x, y - self.y);
    };
    
    self.GetScreenSpace = function(x, y, z) {
        return world_to_screen(x, y, z, self.view_mat, self.proj_mat, self.get_width(), self.get_height());
    };
    
    self.GetWorldSpace = function(x, y) {
        return screen_to_world(x, y, self.view_mat, self.proj_mat, self.get_width(), self.get_height());
    };
    
    // this method is NOT super efficient so try not to have to do it more
    // than once per frame
    self.GetFrustum = function() {
        var inverse_view = matrix_inverse(self.view_mat);
        var inverse_proj = matrix_inverse(self.proj_mat);
        var ndc_corner_ltn = new Vector4(-1, -1, -1, 1);
        var ndc_corner_rtn = new Vector4( 1, -1, -1, 1);
        var ndc_corner_lbn = new Vector4(-1,  1, -1, 1);
        var ndc_corner_rbn = new Vector4( 1,  1, -1, 1);
        var ndc_corner_ltf = new Vector4(-1, -1, 1, 1);
        var ndc_corner_rtf = new Vector4( 1, -1, 1, 1);
        var ndc_corner_lbf = new Vector4(-1,  1, 1, 1);
        var ndc_corner_rbf = new Vector4( 1,  1, 1, 1);
        
        var view_corner_ltn_h = matrix_multiply_vec4(ndc_corner_ltn, inverse_proj);
        var view_corner_rtn_h = matrix_multiply_vec4(ndc_corner_rtn, inverse_proj);
        var view_corner_lbn_h = matrix_multiply_vec4(ndc_corner_lbn, inverse_proj);
        var view_corner_rbn_h = matrix_multiply_vec4(ndc_corner_rbn, inverse_proj);
        var view_corner_ltf_h = matrix_multiply_vec4(ndc_corner_ltf, inverse_proj);
        var view_corner_rtf_h = matrix_multiply_vec4(ndc_corner_rtf, inverse_proj);
        var view_corner_lbf_h = matrix_multiply_vec4(ndc_corner_lbf, inverse_proj);
        var view_corner_rbf_h = matrix_multiply_vec4(ndc_corner_rbf, inverse_proj);
        
        var view_corner_ltn = view_corner_ltn_h.Mul(1 / view_corner_ltn_h.w);
        var view_corner_rtn = view_corner_rtn_h.Mul(1 / view_corner_rtn_h.w);
        var view_corner_lbn = view_corner_lbn_h.Mul(1 / view_corner_lbn_h.w);
        var view_corner_rbn = view_corner_rbn_h.Mul(1 / view_corner_rbn_h.w);
        var view_corner_ltf = view_corner_ltf_h.Mul(1 / view_corner_ltf_h.w);
        var view_corner_rtf = view_corner_rtf_h.Mul(1 / view_corner_rtf_h.w);
        var view_corner_lbf = view_corner_lbf_h.Mul(1 / view_corner_lbf_h.w);
        var view_corner_rbf = view_corner_rbf_h.Mul(1 / view_corner_rbf_h.w);
        
        return {
            ltn: matrix_multiply_vec4(view_corner_ltn, inverse_view),
            rtn: matrix_multiply_vec4(view_corner_rtn, inverse_view),
            lbn: matrix_multiply_vec4(view_corner_lbn, inverse_view),
            rbn: matrix_multiply_vec4(view_corner_rbn, inverse_view),
            ltf: matrix_multiply_vec4(view_corner_ltf, inverse_view),
            rtf: matrix_multiply_vec4(view_corner_rtf, inverse_view),
            lbf: matrix_multiply_vec4(view_corner_lbf, inverse_view),
            rbf: matrix_multiply_vec4(view_corner_rbf, inverse_view),
        };
    };
}