function set_cursor_sprite_auto() {
    window_set_cursor(cr_none);
    switch (obj_demo.demo_mode) {
        case EOperationModes.SELECTION:
            cursor_sprite = spr_modes_single_selection;
            break;
        case EOperationModes.EYEDROPPER:
            cursor_sprite = spr_modes_single_eyedropper;
            break;
        case EOperationModes.BUCKET:
            cursor_sprite = spr_modes_single_bucket;
            break;
    }
}