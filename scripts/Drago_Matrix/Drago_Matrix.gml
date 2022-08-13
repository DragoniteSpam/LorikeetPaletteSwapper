function matrix_inverse(matrix) {
    // from https://web.archive.org/web/20220520205338/https://github.com/JujuAdams/Scribble/blob/master/scripts/__scribble_system/__scribble_system.gml
    var inv = array_create(16, undefined);

    inv[@  0] =  matrix[5]  * matrix[10] * matrix[15] - 
                  matrix[5]  * matrix[11] * matrix[14] - 
                  matrix[9]  * matrix[6]  * matrix[15] + 
                  matrix[9]  * matrix[7]  * matrix[14] +
                  matrix[13] * matrix[6]  * matrix[11] - 
                  matrix[13] * matrix[7]  * matrix[10];
                
    inv[@  4] = -matrix[4]  * matrix[10] * matrix[15] + 
                  matrix[4]  * matrix[11] * matrix[14] + 
                  matrix[8]  * matrix[6]  * matrix[15] - 
                  matrix[8]  * matrix[7]  * matrix[14] - 
                  matrix[12] * matrix[6]  * matrix[11] + 
                  matrix[12] * matrix[7]  * matrix[10];
                
    inv[@  8] =  matrix[4]  * matrix[9] * matrix[15] - 
                  matrix[4]  * matrix[11] * matrix[13] - 
                  matrix[8]  * matrix[5] * matrix[15] + 
                  matrix[8]  * matrix[7] * matrix[13] + 
                  matrix[12] * matrix[5] * matrix[11] - 
                  matrix[12] * matrix[7] * matrix[9];
                
    inv[@ 12] = -matrix[4]  * matrix[9] * matrix[14] + 
                  matrix[4]  * matrix[10] * matrix[13] +
                  matrix[8]  * matrix[5] * matrix[14] - 
                  matrix[8]  * matrix[6] * matrix[13] - 
                  matrix[12] * matrix[5] * matrix[10] + 
                  matrix[12] * matrix[6] * matrix[9];
                
    inv[@  1] = -matrix[1]  * matrix[10] * matrix[15] + 
                  matrix[1]  * matrix[11] * matrix[14] + 
                  matrix[9]  * matrix[2] * matrix[15] - 
                  matrix[9]  * matrix[3] * matrix[14] - 
                  matrix[13] * matrix[2] * matrix[11] + 
                  matrix[13] * matrix[3] * matrix[10];
                
    inv[@  5] =  matrix[0]  * matrix[10] * matrix[15] - 
                  matrix[0]  * matrix[11] * matrix[14] - 
                  matrix[8]  * matrix[2] * matrix[15] + 
                  matrix[8]  * matrix[3] * matrix[14] + 
                  matrix[12] * matrix[2] * matrix[11] - 
                  matrix[12] * matrix[3] * matrix[10];
                
    inv[@  9] = -matrix[0]  * matrix[9] * matrix[15] + 
                  matrix[0]  * matrix[11] * matrix[13] + 
                  matrix[8]  * matrix[1] * matrix[15] - 
                  matrix[8]  * matrix[3] * matrix[13] - 
                  matrix[12] * matrix[1] * matrix[11] + 
                  matrix[12] * matrix[3] * matrix[9];
                
    inv[@ 13] =  matrix[0]  * matrix[9] * matrix[14] - 
                  matrix[0]  * matrix[10] * matrix[13] - 
                  matrix[8]  * matrix[1] * matrix[14] + 
                  matrix[8]  * matrix[2] * matrix[13] + 
                  matrix[12] * matrix[1] * matrix[10] - 
                  matrix[12] * matrix[2] * matrix[9];
                
    inv[@  2] =  matrix[1]  * matrix[6] * matrix[15] - 
                  matrix[1]  * matrix[7] * matrix[14] - 
                  matrix[5]  * matrix[2] * matrix[15] + 
                  matrix[5]  * matrix[3] * matrix[14] + 
                  matrix[13] * matrix[2] * matrix[7] - 
                  matrix[13] * matrix[3] * matrix[6];
                
    inv[@  6] = -matrix[0]  * matrix[6] * matrix[15] + 
                  matrix[0]  * matrix[7] * matrix[14] + 
                  matrix[4]  * matrix[2] * matrix[15] - 
                  matrix[4]  * matrix[3] * matrix[14] - 
                  matrix[12] * matrix[2] * matrix[7] + 
                  matrix[12] * matrix[3] * matrix[6];
                
    inv[@ 10] =  matrix[0]  * matrix[5] * matrix[15] - 
                  matrix[0]  * matrix[7] * matrix[13] - 
                  matrix[4]  * matrix[1] * matrix[15] + 
                  matrix[4]  * matrix[3] * matrix[13] + 
                  matrix[12] * matrix[1] * matrix[7] - 
                  matrix[12] * matrix[3] * matrix[5];
                
    inv[@ 14] = -matrix[0]  * matrix[5] * matrix[14] + 
                  matrix[0]  * matrix[6] * matrix[13] + 
                  matrix[4]  * matrix[1] * matrix[14] - 
                  matrix[4]  * matrix[2] * matrix[13] - 
                  matrix[12] * matrix[1] * matrix[6] + 
                  matrix[12] * matrix[2] * matrix[5];
                
    inv[@  3] = -matrix[1] * matrix[6] * matrix[11] + 
                  matrix[1] * matrix[7] * matrix[10] + 
                  matrix[5] * matrix[2] * matrix[11] - 
                  matrix[5] * matrix[3] * matrix[10] - 
                  matrix[9] * matrix[2] * matrix[7] + 
                  matrix[9] * matrix[3] * matrix[6];
                
    inv[@  7] =  matrix[0] * matrix[6] * matrix[11] - 
                  matrix[0] * matrix[7] * matrix[10] - 
                  matrix[4] * matrix[2] * matrix[11] + 
                  matrix[4] * matrix[3] * matrix[10] + 
                  matrix[8] * matrix[2] * matrix[7] - 
                  matrix[8] * matrix[3] * matrix[6];
                
    inv[@ 11] = -matrix[0] * matrix[5] * matrix[11] + 
                  matrix[0] * matrix[7] * matrix[9] + 
                  matrix[4] * matrix[1] * matrix[11] - 
                  matrix[4] * matrix[3] * matrix[9] - 
                  matrix[8] * matrix[1] * matrix[7] + 
                  matrix[8] * matrix[3] * matrix[5];
                
    inv[@ 15] =  matrix[0] * matrix[5] * matrix[10] - 
                  matrix[0] * matrix[6] * matrix[9] - 
                  matrix[4] * matrix[1] * matrix[10] + 
                  matrix[4] * matrix[2] * matrix[9] + 
                  matrix[8] * matrix[1] * matrix[6] - 
                  matrix[8] * matrix[2] * matrix[5];

    var det = matrix[0]*inv[0] + matrix[1]*inv[4] + matrix[2]*inv[8] + matrix[3]*inv[12];
    if (det == 0)
    {
        return matrix;
    }

    det = 1 / det;
    
    inv[@  0] *= det;
    inv[@  1] *= det;
    inv[@  2] *= det;
    inv[@  3] *= det;
    inv[@  4] *= det;
    inv[@  5] *= det;
    inv[@  6] *= det;
    inv[@  7] *= det;
    inv[@  8] *= det;
    inv[@  9] *= det;
    inv[@ 10] *= det;
    inv[@ 11] *= det;
    inv[@ 12] *= det;
    inv[@ 13] *= det;
    inv[@ 14] *= det;
    inv[@ 15] *= det;

    return inv;
}

function matrix_multiply_vec4(point, matrix) {
    var xx = point.x;
    var yy = point.y;
    var zz = point.z;
    var ww = point.w;
    
    return new Vector4(
        matrix[0] * xx + matrix[4] * yy + matrix[8] * zz + matrix[12] * ww,
        matrix[1] * xx + matrix[5] * yy + matrix[9] * zz + matrix[13] * ww,
        matrix[2] * xx + matrix[6] * yy + matrix[10] * zz + matrix[14] * ww,
        matrix[3] * xx + matrix[7] * yy + matrix[11] * zz + matrix[15] * ww,
    );
}