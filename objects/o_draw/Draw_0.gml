
var _window_width = window_get_width();
var _window_height = window_get_height();

if (window_width != _window_width || window_height != _window_height) {
    window_width = _window_width;
    window_height = _window_height;
    
    surface_free(gui_surf);
    surface_free(canvas_holder_surf);
    
}

#region Canvas holder drawing

if (!surface_exists(canvas_holder_surf)) {
    canvas_holder_surf = surface_create(window_width, window_height);
    canvas_holder_redraw = true;
}

if (canvas_holder_redraw) {

    surface_set_target(canvas_holder_surf);
    draw_clear_alpha(c_white, 0);
    
    draw_canvas_container();
    
    surface_reset_target();
    canvas_holder_redraw = false;

}

#endregion

#region GUI drawing

if (!surface_exists(gui_surf)) {
    gui_surf = surface_create(window_width, window_height);
    gui_redraw = true;
}

if (gui_redraw) {
    
    surface_set_target(gui_surf);
    draw_clear_alpha(c_white, 0);
    
    draw_gui();
    
    surface_reset_target();
    gui_redraw = false;

}

#endregion