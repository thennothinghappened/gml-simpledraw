
#region Initial window setup

application_surface_enable(false);
application_surface_draw_enable(false);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

window_width = window_get_width();
window_height = window_get_height();

#endregion

#region State

enum State {
	Idle,
	Panning,
	Zooming,
	Drawing
}

/// What we're currently doing!
state = State.Idle;

#endregion

#region Mouse

enum MouseButtons {
	Left,
	Middle,
	Right
}

prev_mouse_x = window_mouse_get_x();
prev_mouse_y = window_mouse_get_y();

current_mouse_x = prev_mouse_x;
current_mouse_y = prev_mouse_y;

/// click state last frame
prev_click = [];
prev_click[MouseButtons.Left]		= false;
prev_click[MouseButtons.Middle]		= false;
prev_click[MouseButtons.Right]		= false;

/// click state this frame
current_click = [];
current_click[MouseButtons.Left]	= false;
current_click[MouseButtons.Middle]	= false;
current_click[MouseButtons.Right]	= false;

/// load the current mouse state
mouse_state_load = function() {
	
	prev_click[MouseButtons.Left]	= current_click[MouseButtons.Left];
	prev_click[MouseButtons.Middle] = current_click[MouseButtons.Middle];
	prev_click[MouseButtons.Right]	= current_click[MouseButtons.Right];
	
	current_click[MouseButtons.Left]	= device_mouse_check_button(0, mb_left);
	current_click[MouseButtons.Middle]	= device_mouse_check_button(0, mb_middle);
	current_click[MouseButtons.Right]	= device_mouse_check_button(0, mb_right);
	
	prev_mouse_x = current_mouse_x;
	prev_mouse_y = current_mouse_y;

	current_mouse_x = window_mouse_get_x();
	current_mouse_y = window_mouse_get_y();
}

#endregion

#region Brushes and Tools!

/// a new surface to draw into with the selected brush!
brush_surface = -1;


#endregion

#region Canvas setup and manipulation

canvas_width = window_width;
canvas_height = window_height;

/// how much we've panned the canvas on screen!
canvas_pan_x = 0;
canvas_pan_y = 0;

/// how much we've zoomed the canvas!
canvas_scale = 1;

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

/// load the canvas from a file!
/// @param {string} filepath
canvas_load_from_file = function(filepath) {
	throw "Not implemented!";
}

#endregion

#region GUI

// temp
bg_surface = surface_create(canvas_width, canvas_height);


bg_ensure_exists = function() {
	
	if (!surface_exists(bg_surface)) {
		bg_surface = surface_create(canvas_width, canvas_height);
	}
	
	surface_set_target(bg_surface);

	draw_sprite_tiled(bg, 0, 0, 0);

	surface_reset_target();
}

/// gui's draw surface
gui_surface = surface_create(window_width, window_height);

/// whether we need to redraw the gui
gui_redraw = true;

gui_focused = undefined;

gui_container = new GuiRect(0, 0, 1, 0.2, [
	new GuiButton(0.1, 0.2, 0.1, 0.1, [
		
	], function() {
		show_message("hi!");
	})
], c_white, 0.6);

gui_draw = function() {
	gui_container.draw(
		window_width * gui_container.rel_x,
		window_height * gui_container.rel_y,
		window_width * gui_container.rel_w,
		window_height * gui_container.rel_h
	);
	
	gui_redraw = false;
}

gui_ensure_exists = function() {
	if (surface_exists(gui_surface)) {
		return;
	}
	
	gui_surface = surface_create(window_width, window_height);
	gui_redraw = true;
}

gui_check_input = function() {
	var new_gui_focus = gui_container.get_focused(
		current_mouse_x,
		current_mouse_y,
		window_width * gui_container.rel_x,
		window_height * gui_container.rel_y,
		window_width * gui_container.rel_w,
		window_height * gui_container.rel_h
	);

	if (new_gui_focus == undefined && gui_focused == undefined) {
		return false;
	}
	
	var click_changed = current_click[MouseButtons.Left] != prev_click[MouseButtons.Left];
	
	if (new_gui_focus == gui_focused) {
		
		if (!click_changed || gui_focused == undefined) {
			return true;
		}
		
		gui_focused.on_click(current_click[MouseButtons.Left]);
		
		return true;
	}
	
	if (!click_changed) {
		// continue a drag click
		if (current_click[MouseButtons.Left]) {
			return true;
		}
		
		if (gui_focused != undefined) {
			gui_focused.on_hover(false);
		}
		
		gui_focused = new_gui_focus;
	
		if (gui_focused != undefined) {
			gui_focused.on_hover(true);
		}
		
		return true;
	}
	
	if (gui_focused != undefined) {
		gui_focused.on_hover(false);
		gui_focused.on_click(prev_click[MouseButtons.Left]);
	}
	
	gui_focused = new_gui_focus;
	
	if (gui_focused != undefined) {
		gui_focused.on_hover(true);
		gui_focused.on_click(current_click[MouseButtons.Left]);
	}
	
	return true;
	
}

#endregion

#region Event handlers

/// called upon window resize.
/// @param {number} new_width
/// @param {number} new_height
on_window_resize = function(new_width, new_height) {
    window_width = new_width;
    window_height = new_height;
	
	surface_free(gui_surface);
}

/// called when the user hits save
on_save_canvas = function() {
	var filepath = get_save_filename("*.png", "Canvas");
	
	if (filepath == "") {
		return;
	}
	
	canvas_save_to_file(filepath);
}

/// called when the user hits load
on_load_canvas = function() {
	if (canvas_unsaved_changes) {
		var ok = show_question("You have unsaved changes! Are you sure?");
		
		if (!ok) {
			return;
		}
	}
	
	var filepath = get_open_filename("*.png", "Canvas");
	
	if (filepath == "") {
		return;
	}
	
	canvas_load_from_file(filepath);
}

on_pan = function() {
	canvas_pan_x += current_mouse_x - prev_mouse_x;
	canvas_pan_y += current_mouse_y - prev_mouse_y;
}

#endregion

#region Final Init!

canvas = surface_create(canvas_width, canvas_height);
canvas_create_backup();

#endregion