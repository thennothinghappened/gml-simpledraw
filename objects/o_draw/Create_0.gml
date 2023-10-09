
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

/// figure out what the current state is
get_current_state = function() {
	
}

#endregion

#region Mouse

enum MouseButtons {
	Left,
	Middle,
	Right
}

enum ClickState {
	None,
	Pressed,
	Held,
	Released
}

prev_mouse_x = window_mouse_get_x();
prev_mouse_y = window_mouse_get_y();

current_mouse_x = prev_mouse_x;
current_mouse_y = prev_mouse_y;

/// mapping for click states, util stuff
_clickstatemap = [];
_clickstatemap[MouseButtons.Left] = mb_left;
_clickstatemap[MouseButtons.Middle] = mb_middle;
_clickstatemap[MouseButtons.Right] = mb_right;

/// click state this frame [state, time (for last Held)]
click = [];
click[MouseButtons.Left]	= [ClickState.None, 0];
click[MouseButtons.Middle]	= [ClickState.None, 0];
click[MouseButtons.Right]	= [ClickState.None, 0];

/// load the current mouse state for a button
mouse_btn_state_load = function(index) {
	
	if (device_mouse_check_button_released(0, _clickstatemap[index])) {
		click[index][0] = ClickState.Released;
		return;
	}
	
	if (device_mouse_check_button_pressed(0, _clickstatemap[index])) {
		click[index][0] = ClickState.Pressed;
		return;
	}
	
	if (device_mouse_check_button(0, _clickstatemap[index])) {
		click[index][0] = ClickState.Held;
		click[index][1] += 1;
		return;
	}
	
	click[index][0] = ClickState.None;
	click[index][1] = 0;
	
}

/// load the mouse position state
mouse_pos_state_load = function() {
	prev_mouse_x = current_mouse_x;
	prev_mouse_y = current_mouse_y;

	current_mouse_x = window_mouse_get_x();
	current_mouse_y = window_mouse_get_y();
}

/// load the current mouse state
mouse_state_load = function() {
	mouse_btn_state_load(MouseButtons.Left);
	mouse_btn_state_load(MouseButtons.Middle);
	mouse_btn_state_load(MouseButtons.Right);
	
	mouse_pos_state_load();
}

/// returns whether the mouse moved
mouse_moved = function() {
	return prev_mouse_x != current_mouse_x || prev_mouse_y != current_mouse_y;
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

	var lmb = click[MouseButtons.Left][0];
	
	if (new_gui_focus == gui_focused) {
		
		if (gui_focused == undefined) {
			return false;
		}
		
		switch (lmb) {
			case ClickState.Pressed: {
				gui_focused.on_click(true);
				return true;
			}
			
			case ClickState.Released: {
				gui_focused.on_click(false);
				return true;
			}
			
			default: return false;
		}
	}
	
	var absorb_input = false;
	
	if (gui_focused != undefined) {
		gui_focused.on_hover(false);
		
		if (lmb == ClickState.Released) {
			gui_focused.on_click(false);
			absorb_input = true;
		}
	}
	
	if (new_gui_focus != undefined) {
		new_gui_focus.on_hover(true);
		
		if (lmb == ClickState.Pressed) {
			new_gui_focus.on_click(true);
			absorb_input = true;
		}
	}
	
	gui_focused = new_gui_focus;
	
	return absorb_input;
	
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

/// called on panning the canvas
on_pan = function(change_x, change_y) {
	canvas_pan_x += change_x;
	canvas_pan_y += change_y;
}

/// called on zooming the canvas
on_zoom = function(change) {
	
}

/// called on viewing the context menu
on_view_context = function() {
	state = State.Idle;
	show_message("view context menu!");
}

#endregion

#region Final Init!

canvas = surface_create(canvas_width, canvas_height);
canvas_create_backup();

#endregion