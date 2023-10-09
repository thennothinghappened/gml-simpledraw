
draw_surface_ext(bg_surface, canvas_pan_x, canvas_pan_y, canvas_scale, canvas_scale, 0, c_white, 1);

canvas_ensure_exists();
draw_surface_ext(canvas, canvas_pan_x, canvas_pan_y, canvas_scale, canvas_scale, 0, c_white, 1);

gui_ensure_exists();
draw_surface(gui_surface, 0, 0);

var tool = tools[tool_ind];
draw_sprite_stretched(tool.icon, 0, current_mouse_x, current_mouse_y, 64, 64);