INPUT_DEFAULT_PROFILES = {
    keyboard_and_mouse: {
        left:  [input_binding_key(ord("A")), input_binding_key(vk_left)],
        right: [input_binding_key(ord("D")), input_binding_key(vk_right)],
        up: [input_binding_key(ord("W")), input_binding_key(vk_up)],
        down: [input_binding_key(ord("S")), input_binding_key(vk_down)],
    },
    
    gamepad: {
        left:  [input_binding_gamepad_axis(gp_axislh, true), input_binding_gamepad_button(gp_padl)],
        right: [input_binding_gamepad_axis(gp_axislh, false), input_binding_gamepad_button(gp_padr)],
        up: [input_binding_gamepad_axis(gp_axislv, true), input_binding_gamepad_button(gp_padu)],
        down: [input_binding_gamepad_axis(gp_axislv, false), input_binding_gamepad_button(gp_padd)],
    },
}