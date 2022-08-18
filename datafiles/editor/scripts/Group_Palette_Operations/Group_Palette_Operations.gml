function operation_shift_left(data) {
    var value0 = data[0];
    array_delete(data, 0, 1);
    array_push(data, -1);
    for (var i = 0, n = array_length(data); i < n; i++) {
        if (data[i] == -1) {
            data[i] = value0;
            break;
        }
    }
}

function operation_shift_right(data) {
    for (var i = array_length(data) - 1; i >= 0; i--) {
        if (data[i] != -1) {
            array_insert(data, 0, data[i]);
            array_delete(data, i + 1, 1);
            break;
        }
    }
}