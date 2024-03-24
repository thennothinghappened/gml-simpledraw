/// Process user actions.

if (mouse_check_button_pressed(mb_left)) {
    mouse_trail = [];
    mouse_trail_start_x = window_mouse_get_x();
    mouse_trail_start_y = window_mouse_get_y();
}

if (mouse_check_button(mb_left)) {
    array_push(mouse_trail, [window_mouse_get_delta_x(), window_mouse_get_delta_y()]);
}

canvas.draw(function() {
    
    draw_set_colour(c_red);

    array_reduce(mouse_trail, function(prev, change) {

        var curr = [prev[X] + change[X], prev[Y] + change[Y]];
        var dist = clamp(point_distance(0, 0, change[X], change[Y]), 1, 10);
    
        draw_line_width(prev[X], prev[Y], curr[X], curr[Y], dist);
        draw_circle(curr[X], curr[Y], dist / 2, false);
    
        return curr;
    
    }, [mouse_trail_start_x, mouse_trail_start_y]);    
    draw_set_colour(c_white);
    
});
