
if (keyboard_check_pressed(vk_f6)) {
    return on_save_canvas();
}

if (keyboard_check_pressed(vk_f7)) {
    return on_load_canvas();
}

if (keyboard_check_pressed(vk_f8)) {
    return on_resize_canvas();
    
}

mouse_state_load();

if (false) {
    window_set_cursor(cr_default);
    return;
}

//canvas_rotation -= 0.1;

window_set_cursor(cr_none);
handlers[state]();