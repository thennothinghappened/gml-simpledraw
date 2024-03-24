/// Process user actions.

var mouse_wheel = real(mouse_wheel_down()) - real(mouse_wheel_up());

if (mouse_wheel != 0) {

    camera.distance += mouse_wheel * camera_zoom_speed * camera.distance;
    camera.distance = clamp(camera.distance, camera_distance_min, camera_distance_max);
    
    camera.update();
}

if (mouse_check_button(mb_middle)) {

    camera.rotate(window_mouse_get_delta_x() * camera_rotation_speed);
}

if (mouse_check_button(mb_right)) {
    
    camera.pan(
        window_mouse_get_delta_x() * camera_pan_speed,
        window_mouse_get_delta_y() * camera_pan_speed
    );
    
}

if (mouse_check_button(mb_left)) {
    canvas.draw_atomic(function() {
    
        draw_set_color(c_red);
        draw_circle(mouse_worldspace[X], mouse_worldspace[Y], 10, false);
        draw_set_color(c_white);
    
    });
}
