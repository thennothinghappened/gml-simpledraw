/// Process user actions.

var mouse_wheel = real(mouse_wheel_down()) - real(mouse_wheel_up());

if (mouse_wheel != 0) {

    camera.distance += mouse_wheel * camera_zoom_speed * camera.distance;
    camera.distance = clamp(camera.distance, camera_distance_min, camera_distance_max);
    
    camera.update();
}

if (mouse_check_button(mb_middle)) {

    camera.rotation += (real(window_mouse_get_delta_x()) / (2 * pi)) * camera_rotation_speed;
    camera.update();
}

if (mouse_check_button(mb_right)) {
    
    var s = sin(-camera.rotation);
    var c = cos(-camera.rotation);
    
    var pan_x = real(window_mouse_get_delta_x()) * camera_pan_speed * camera.distance;
    var pan_y = real(window_mouse_get_delta_y()) * camera_pan_speed * camera.distance;

    camera.pan[X] -= pan_x * c - pan_y * s;
    camera.pan[Y] -= pan_x * s + pan_y * c;
    
    camera.update();
}

if (mouse_check_button(mb_left)) {
    canvas.draw(function() {
    
        draw_set_color(c_red);
        draw_circle(mouse_worldspace[X], mouse_worldspace[Y], 10, false);
        draw_set_color(c_white);
    
    });    
}
