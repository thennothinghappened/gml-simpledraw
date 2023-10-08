
#region Initial window setup

application_surface_enable(false);
application_surface_draw_enable(false);

window_width = window_get_width();
window_height = window_get_height();

#endregion

#region Mouse

prev_mouse_x = window_mouse_get_x();
prev_mouse_y = window_mouse_get_y();

current_mouse_x = prev_mouse_x;
current_mouse_y = prev_mouse_y;

#endregion

#region Brushes and Tools!

/// a new surface to draw into with the selected brush!
brush_surface = -1;


#endregion

#region Canvas setup and manipulation

canvas_width = window_width;
canvas_height = window_height;

/// surface id for the canvas
canvas = -1;

/// backup buffer to reload canvas from if freed
canvas_backup_buf = -1;

/// whether the canvas has unsaved changes (duh)
canvas_unsaved_changes = false;

/// create the backup buffer for the canvas
canvas_create_backup = function() {
	if (buffer_exists(canvas_backup_buf)) {
		buffer_delete(canvas_backup_buf);
	}
	
	canvas_backup_buf = buffer_create(surface_buffer_size(canvas_width, canvas_height), buffer_fixed, 1);
	canvas_backup();
}

/// backup the surface into memory
canvas_backup = function() {
	buffer_get_surface(canvas_backup_buf, canvas, 0);
}

/// make sure the canvas exists. if not, restore from the backup
canvas_ensure_exists = function() {
	if (surface_exists(canvas)) {
		return;
	}
	
	buffer_set_surface(canvas_backup_buf, canvas, 0);
}

/// resize the canvas to a given size, placing the original contents at the top left.
/// @param {number} new_width
/// @param {number} new_height
canvas_resize = function(new_width, new_height) {
	var new_canvas = surface_create(new_width, new_height);
	
	canvas_ensure_exists();
	
	surface_copy(new_canvas, 0, 0, canvas);
	surface_free(canvas);
	
	canvas = new_canvas;
	canvas_create_backup();
	
}

/// save the canvas to a file!
/// @param {string} filepath
canvas_save_to_file = function(filepath) {
	surface_save(canvas, filepath);
}

#endregion

#region Event handlers

/// called upon window resize.
/// @param {number} new_width
/// @param {number} new_height
on_window_resize = function(new_width, new_height) {
    window_width = new_width;
    window_height = new_height;
}

/// called when the user hits save
on_save = function() {
	var filepath = get_save_filename("*.png", "Canvas");
	
	if (filepath == "") {
		return;
	}
	
	canvas_save_to_file(filepath);
}

/// called when the user hits load
on_load = function() {
	
}

#endregion

#region Final Init!

canvas = surface_create(canvas_width, canvas_height);
canvas_create_backup();

#endregion