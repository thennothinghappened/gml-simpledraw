/// Process user actions.

camera_distance += (real(mouse_wheel_down()) - real(mouse_wheel_up())) * camera_zoom_speed * camera_distance;
camera_distance = clamp(camera_distance, camera_distance_min, camera_distance_max);

if (mouse_check_button(mb_middle)) {
    camera_rotation += (real(window_mouse_get_delta_x()) / (2 * pi)) * camera_rotation_speed;
}

if (mouse_check_button(mb_right)) {
    
    var s = sin(-camera_rotation);
    var c = cos(-camera_rotation);
    
    var pan_x = real(window_mouse_get_delta_x()) * camera_pan_speed * camera_distance;
    var pan_y = real(window_mouse_get_delta_y()) * camera_pan_speed * camera_distance;

    camera_pan[X] -= pan_x * c - pan_y * s;
    camera_pan[Y] -= pan_x * s + pan_y * c;
}

if (mouse_check_button(mb_left)) {
    canvas.draw(function() {
    
        draw_set_color(c_red);
        draw_circle(mouse_worldspace[X], mouse_worldspace[Y], 10, false);
        draw_set_color(c_white);
    
    });    
}
