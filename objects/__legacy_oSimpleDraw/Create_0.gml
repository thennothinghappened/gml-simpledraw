/// TODO: gonna implement a multi-step undo!
/// plan is to take an extra old buffer snapshot, and record X amount
/// of actions after it, in a way that you could literally step through and replay them
/// to undo and redo.

#region Initial window setup

application_surface_enable(false);
application_surface_draw_enable(false);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

window_width = window_get_width();
window_height = window_get_height();

/// fps to run at normally
normal_fps = 60;
/// fps to run at while drawing
draw_fps = 240;

#endregion

#region State

enum State {
    Idle,
    ClickPanning,
    Zooming,
    Drawing
}

/// What we're currently doing!
state = State.Idle;

handlers = [];

handlers[State.Idle] = function() {
    
    if (click[MouseButtons.Right][0] == ClickState.Pressed) {
        game_set_speed(draw_fps, gamespeed_fps);
        
        state = State.ClickPanning;
        return;
    }
    
    if (click[MouseButtons.Left][0] == ClickState.Pressed) {
        game_set_speed(draw_fps, gamespeed_fps);
        
        state = State.Drawing;
        return;
    }
    
    var scroll_delta = real(mouse_wheel_up()) - real(mouse_wheel_down());
    
    if (scroll_delta != 0) {
        on_zoom(scroll_delta, current_mouse_x, current_mouse_y);
        return;
    }
}

handlers[State.ClickPanning] = function() {
    
    /// min distance before the pan won't open context menu
    static pan_dist_threshold = 16;
    
    if (click[MouseButtons.Right][0] == ClickState.Released) {
        
        game_set_speed(normal_fps, gamespeed_fps);
        
        state = State.Idle;
        
        if (point_distance(
            click[MouseButtons.Right][2],
            click[MouseButtons.Right][3],
            current_mouse_x,
            current_mouse_y) < pan_dist_threshold) {
                
            on_view_context();
        }
        
        return;
    }
    
    canvas_translate(current_mouse_x - prev_mouse_x, current_mouse_y - prev_mouse_y);
}

handlers[State.Drawing] = function() {
    
    if (click[MouseButtons.Left][0] == ClickState.Released) {
        
        canvas_unsaved_changes = true;
        
        game_set_speed(normal_fps, gamespeed_fps);
        
        canvas_backup();
        state = State.Idle;
        
        return;
        
    }
    
    surface_set_target(canvas);

    var mprev = point_to_canvas(prev_mouse_x, prev_mouse_y);
    var m = point_to_canvas(current_mouse_x, current_mouse_y);

    draw_set_alpha(brush_alpha);
    draw_set_colour(brush_colour);
    
    var tool = tools[tool_ind];
    tool.draw(mprev[X], mprev[Y], m[X], m[Y]);
    
    draw_set_color(c_white);
    draw_set_alpha(1);

    surface_reset_target();
    
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

/// click state this frame [state, time (for last Held), start drag pos_x, start drag pos_y]
click = [];
click[MouseButtons.Left]    = [ClickState.None, 0, current_mouse_x, current_mouse_y];
click[MouseButtons.Middle]    = [ClickState.None, 0, current_mouse_x, current_mouse_y];
click[MouseButtons.Right]    = [ClickState.None, 0, current_mouse_x, current_mouse_y];

/// load the current mouse state for a button
mouse_btn_state_load = function(index) {
    
    if (device_mouse_check_button_released(0, _clickstatemap[index])) {
        click[index][0] = ClickState.Released;
        return;
    }
    
    if (device_mouse_check_button_pressed(0, _clickstatemap[index])) {
        click[index][0] = ClickState.Pressed;
        click[index][2] = current_mouse_x;
        click[index][3] = current_mouse_y;
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

#endregion

#region Brushes and Tools!

enum Tools {
    Pencil,
    Brush,
    Eraser
}

brush_colour = c_white;
brush_alpha = 1;
brush_size = 5;

colours = [
    c_white,
    c_black,
    c_red,
    c_orange,
    c_yellow,
    c_green,
    c_aqua,
    c_blue,
    c_purple,
    c_fuchsia
];

tools = [];

tools[Tools.Pencil] = {
    draw: function(prev_x, prev_y, new_x, new_y) {
        draw_line(prev_x, prev_y, new_x, new_y);
        draw_point(new_x, new_y);
    },
    icon: sToolPencil
}

tools[Tools.Brush] = {
    draw: function(prev_x, prev_y, new_x, new_y) {
        draw_line_width(prev_x, prev_y, new_x, new_y, o_draw.brush_size);
        draw_circle(new_x, new_y, o_draw.brush_size / 2, false);
    },
    icon: sToolBrush
}

tool_ind = Tools.Pencil;

/// set the brush colour to a colour index
set_brush_colour = function(colour_ind) {
    brush_colour = colours[colour_ind];
}

#endregion

#region Canvas setup and manipulation

canvas_width = window_width;
canvas_height = window_height;

/// how much we've panned the canvas on screen!
canvas_pan_x = 0;
canvas_pan_y = 0;

/// how much we've zoomed the canvas!
canvas_scale = 1;

/// canvas rotation (degrees)!
canvas_rotation = 0;

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
    
    canvas_backup_buf = buffer_create(__legacy_surface_buffer_size(canvas_width, canvas_height), buffer_fixed, 1);
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
    
    if (!surface_exists(new_canvas)) {
        throw "Failed to resize the canvas!";
    }
    
    canvas_ensure_exists();
    
    surface_copy(new_canvas, 0, 0, canvas);
    surface_free(canvas);
    
    canvas = new_canvas;
    canvas_width = new_width;
    canvas_height = new_height;
    
    canvas_create_backup();
    
}

/// zoom in or out of the canvas around a point in window space
/// @param {real} scale_factor
/// @param {real} window_center_x center x position in window space
/// @param {real} window_center_y center y position in window space
canvas_zoom = function(scale_factor, window_center_x, window_center_y) {
    
    static min_zoom = 0.01;
    static max_zoom = 100;
    
    // see: https://stackoverflow.com/questions/19999694/how-to-scale-about-point
    
    // todo: this is totally broken with rotation
    
    var pt = point_to_canvas(window_center_x, window_center_y);

    canvas_translate(pt[X] * canvas_scale , pt[Y] * canvas_scale);
    canvas_scale = clamp(canvas_scale + (canvas_scale * scale_factor), min_zoom, max_zoom);
    
    //pt = point_to_canvas(window_center_x, window_center_y);
    canvas_translate(-pt[X] * canvas_scale, -pt[Y] * canvas_scale);
}

/// move the canvas
canvas_translate = function(x, y) {
    canvas_pan_x += x;
    canvas_pan_y += y;
}

/// rotate the canvas around a point
canvas_rotate = function(degrees, window_center_x, window_center_y) {
    
    // see: https://stackoverflow.com/questions/2259476/rotating-a-point-about-another-point-2d#2259502
    
    var center = point_to_canvas(window_center_x, window_center_y);
    var new_rotation = canvas_rotation + degrees;
    
    var s = dsin(new_rotation);
    var c = dcos(new_rotation);

    // translate point back to origin:
    canvas_translate(center[X], center[Y]);

    // rotate point
    canvas_rotation = new_rotation;
    
    var xnew = canvas_pan_x * c - canvas_pan_y * s;
    var ynew = canvas_pan_x * s + canvas_pan_y * c;

    // translate point back:
    canvas_pan_x = xnew + center[X];
    canvas_pan_y = ynew + center[Y];
}

/// convert a point in window space to a point in canvas space!
/// @param {real} x
/// @param {real} y
/// @returns {real[]}
point_to_canvas = function(x, y) {
    
    var s = dsin(canvas_rotation);
    var c = dcos(canvas_rotation);
    
    // translate the coordinate to the pan origin
    var zeroed_x = x - canvas_pan_x;
    var zeroed_y = y - canvas_pan_y;
    
    
    // rotate the coordinate
    var rot_x = zeroed_x * c - zeroed_y * s;
    var rot_y = zeroed_x * s + zeroed_y * c;
    
    // scale the coordinate
    var scaled_x = rot_x / canvas_scale;
    var scaled_y = rot_y / canvas_scale;
    
    return [
        scaled_x, scaled_y
    ];
}

/// convert a point in canvas space back to window space!
/// @param {real} x
/// @param {real} y
/// @returns {real[]}
point_from_canvas = function(x, y) {
    return [
        (x * canvas_scale) + canvas_pan_x,
        (y * canvas_scale) + canvas_pan_y
    ];
}

/// save the canvas to a file!
/// @param {string} filepath
canvas_save_to_file = function(filepath) {
    surface_save(canvas, filepath);
}

/// load the canvas from a file!
/// @param {string} filepath
/// @returns {Enum.ImageLoadResult}
canvas_load_from_file = function(filepath) {
    
    var res = __legacy_image_load(filepath);
    
    if (res.result != ImageLoadResult.Loaded) {
        return res.result;
    }
    
    canvas_replace(res.img);
    
    sprite_delete(res.img);
    
    return res.result;
}

/// replace the canvas with a new image! (i.e. load a new img)
/// @param {Id.Sprite} img
canvas_replace = function(img) {
    canvas_width = sprite_get_width(img);
    canvas_height = sprite_get_height(img);
    
    surface_free(canvas);
    canvas = surface_create(canvas_width, canvas_height);
    
    surface_set_target(canvas);
    draw_sprite(img, 0, 0, 0);
    surface_reset_target();
    
    canvas_backup();
    bg_refresh();
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

    draw_sprite_tiled(sCheckerboard, 0, 0, 0);

    surface_reset_target();
}

/// force a refresh of the background
bg_refresh = function() {
    surface_free(bg_surface);
}

/// gui's draw surface
gui_surface = surface_create(window_width, window_height);

/// whether we need to redraw the gui
gui_redraw = true;

/// draw the gui
gui_draw = function() {
    
    gui_redraw = false;
}

/// ensure the gui layer exists, if not, mark for redraw
gui_ensure_exists = function() {
    if (surface_exists(gui_surface)) {
        return;
    }
    
    gui_surface = surface_create(window_width, window_height);
    gui_redraw = true;
}

/// check if the gui has received input. if not, pass
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
                break;
            }
            
            case ClickState.Released: {
                gui_focused.on_click(false);
                break;
            }
        }
        
        return true;
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
        absorb_input = true;
        
        if (lmb == ClickState.Pressed) {
            new_gui_focus.on_click(true);
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

/// called when the user is resizing the canvas
on_resize_canvas = function() {
    canvas_resize(canvas_width + 100, canvas_height + 100);
    bg_refresh();
}

/// called when the user hits load
on_load_canvas = function() {
    if (canvas_unsaved_changes) {
        // TODO!
    }
    
    var filepath = get_open_filename("*", "Canvas");
    
    if (filepath == "") {
        return;
    }
    
    canvas_load_from_file(filepath);
}

/// called on viewing the context menu
on_view_context = function() {
    state = State.Idle;
    
}

/// called on zooming in and out on the canvas
/// @param {real} delta
/// @param {real} window_center_x center x position in window space
/// @param {real} window_center_y center y position in window space
on_zoom = function(delta, window_center_x, window_center_y) {
    static zoom_multiplier = 0.04;
    var zoom_factor = delta * zoom_multiplier;
    
    canvas_zoom(zoom_factor, window_center_x, window_center_y);
}

#endregion

#region Final Init!

canvas = surface_create(canvas_width, canvas_height);
canvas_create_backup();

#endregion