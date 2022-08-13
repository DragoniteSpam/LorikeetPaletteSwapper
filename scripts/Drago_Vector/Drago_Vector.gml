function Vector2(x, y) constructor {
    self.x = x;
    self.y = y;
};

function Vector3(x, y, z) constructor {
    self.x = x;
    self.y = y;
    self.z = z;
    
    static Add = function(val) {
        if (is_numeric(val)) {
            return new Vector3(self.x + val, self.y + val, self.z + val);
        }
        return new Vector3(self.x + val.x, self.y + val.y, self.z + val.z);
    };
    
    static Sub = function(val) {
        if (is_numeric(val)) {
            return new Vector3(self.x - val, self.y - val, self.z - val);
        }
        return new Vector3(self.x - val.x, self.y - val.y, self.z - val.z);
    };
    
    static Mul = function(val) {
        if (is_numeric(val)) {
            return new Vector3(self.x * val, self.y * val, self.z * val);
        }
        return new Vector3(self.x * val.x, self.y * val.y, self.z * val.z);
    };
    
    static Div = function(val) {
        if (is_numeric(val)) {
            return new Vector3(self.x / val, self.y / val, self.z / val);
        }
        return new Vector3(self.x / val.x, self.y / val.y, self.z / val.z);
    };
    
    static Magnitude = function() {
        return point_distance_3d(0, 0, 0, self.x, self.y, self.z);
    };
    
    static DistanceTo = function(val) {
        return point_distance_3d(val.x, val.y, val.z, self.x, self.y, self.z);
    };
    
    static Dot = function(val) {
        return dot_product_3d(self.x, self.y, self.z, val.x, val.y, val.z);
    };
    
    static Cross = function(val) {
        return new Vector3(self.y * val.z - val.y * self.z, self.z * val.x - val.z * self.x, self.x * val.y - val.x * self.y);
    };
    
    static Equals = function(val) {
        return (self.x == val.x) && (self.y == val.y) && (self.z == val.z);
    };
    
    static Normalize = function() {
        var mag = self.Magnitude();
        return new Vector3(self.x / mag, self.y / mag, self.z / mag);
    };
    
    static Abs = function() {
        return new Vector3(abs(self.x), abs(self.y), abs(self.z));
    };
    
    static Project = function(direction) {
        var dot = self.Dot(direction);
        var mag = direction.Magnitude();
        return direction.Mul(dot / (mag * mag));
    };
    
    static MoveTowards = function(dest, dist) {
        return dest.Sub(self).Normalize().Mul(min(dist, self.DistanceTo(dest))).Add(self);
    };
};

function Vector4(x, y, z, w) constructor {
    self.x = x;
    self.y = y;
    self.z = z;
    self.w = w;
    
    static Add = function(val) {
        return new Vector4(self.x + val.x, self.y + val.y, self.z + val.z, self.w + val.w);
    };
    
    static Sub = function(val) {
        return new Vector4(self.x - val.x, self.y - val.y, self.z - val.z, self.w - val.w);
    };
    
    static Mul = function(val) {
        if (is_numeric(val)) {
            return new Vector4(self.x * val, self.y * val, self.z * val, self.w * val);
        }
        return new Vector4(self.x * val.x, self.y * val.y, self.z * val.z, self.w * val.w);
    };
    
    static Div = function(val) {
        if (is_numeric(val)) {
            return new Vector4(self.x / val, self.y / val, self.z / val, self.w / val);
        }
        return new Vector4(self.x / val.x, self.y / val.y, self.z / val.z, self.w / val.w);
    };
    
    static Magnitude = function() {
        static zero = new Vector4(0, 0, 0, 0);
        return self.DistanceTo(zero);
    };
    
    static DistanceTo = function(val) {
        var dx = val.x - self.x;
        var dy = val.y - self.y;
        var dz = val.z - self.z;
        var dw = val.w - self.w;
        return sqrt(dx * dx + dy * dy + dz * dz + dw * dw);
    };
    
    static Dot = function(val) {
        return self.x * val.x + self.y * val.y + self.z * val.z + self.w * val.w;
    };
    
    static Equals = function(val) {
        return (self.x == val.x) && (self.y == val.y) && (self.z == val.z) && (self.w == val.w);
    };
    
    static Normalize = function() {
        var mag = self.Magnitude();
        return new Vector4(self.x / mag, self.y / mag, self.z / mag, self.w / mag);
    };
    
    static Abs = function() {
        return new Vector4(abs(self.x), abs(self.y), abs(self.z), abs(self.w));
    };
}

function BoundingBox(xmin, ymin, zmin, xmax, ymax, zmax) constructor {
    self.xmin = xmin;
    self.ymin = ymin;
    self.zmin = zmin;
    self.xmax = xmax;
    self.ymax = ymax;
    self.zmax = zmax;
    
    static Volume = function() {
        return abs((self.xmax - self.xmin) * (self.ymax - self.ymin) * (self.zmax - self.zmin));
    };
};