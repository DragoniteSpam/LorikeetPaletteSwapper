
function screen_to_world(x, y, view_mat, proj_mat, w = window_get_width(), h = window_get_height()) {
    /*
        Transforms a 2D coordinate (in window space) to a 3D vector.
        Works for both orthographic and perspective projections.
        Script created by TheSnidr
        (slightly modified by @dragonitespam)
    */
    var mx = 2 * (x / w - .5) / proj_mat[0];
    var my = 2 * (y / h - .5) / proj_mat[5];
    var camX = - (view_mat[12] * view_mat[0] + view_mat[13] * view_mat[1] + view_mat[14] * view_mat[2]);
    var camY = - (view_mat[12] * view_mat[4] + view_mat[13] * view_mat[5] + view_mat[14] * view_mat[6]);
    var camZ = - (view_mat[12] * view_mat[8] + view_mat[13] * view_mat[9] + view_mat[14] * view_mat[10]);
    
    if (proj_mat[15] == 0) {    //This is a perspective projection
        return new Vector3(view_mat[2] + mx * view_mat[0] + my * view_mat[1], view_mat[6] + mx * view_mat[4] + my * view_mat[5], view_mat[10] + mx * view_mat[8] + my * view_mat[9]);
    } else {    //This is an ortho projection
        return new Vector3(view_mat[2], view_mat[6], view_mat[10]);
    }
};

function world_to_screen(x, y, z, view_mat, proj_mat, w = window_get_width(), h = window_get_height()) {
    /*
        Transforms a 3D world-space coordinate to a 2D window-space coordinate.
        Returns [-1, -1] if the 3D point is not in view
   
        Script created by TheSnidr
        www.thesnidr.com
    */
    var cx, cy;
    if (proj_mat[15] == 0) {   //This is a perspective projection
        var ww = view_mat[2] * x + view_mat[6] * y + view_mat[10] * z + view_mat[14];
        if (ww <= 0) return new Vector2(-1, -1);
        cx = proj_mat[8] + proj_mat[0] * (view_mat[0] * x + view_mat[4] * y + view_mat[8] * z + view_mat[12]) / ww;
        cy = proj_mat[9] + proj_mat[5] * (view_mat[1] * x + view_mat[5] * y + view_mat[9] * z + view_mat[13]) / ww;
    } else {    //This is an ortho projection
        cx = proj_mat[12] + proj_mat[0] * (view_mat[0] * x + view_mat[4] * y + view_mat[8]  * z + view_mat[12]);
        cy = proj_mat[13] + proj_mat[5] * (view_mat[1] * x + view_mat[5] * y + view_mat[9]  * z + view_mat[13]);
    }
    
    return new Vector2((0.5 + 0.5 * cx) * w, (0.5 - 0.5 * cy) * h);
};