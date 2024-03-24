/// Main controlling instance for gml-simpledraw.

/// Preferences for the application.
prefs = new Preferences();

var prefs_load_result = prefs.load();

if (is_instanceof(prefs_load_result, Err)) {
    show_message($"Failed to load preferences, using defaults:\n{prefs_load_result}");
}

/// Current drawing canvas instance.
canvas = new Canvas(800, 600);
canvas.clear();

/// Camera instance to view the canvas!
camera = new Camera(0, [canvas.width / 2, canvas.height / 2], 400);

/// Current mouse position in world/canvas space.
mouse_worldspace = [0, 0];

/// Whether the mouse has moved since last frame.
mouse_moved = false;

/// States!
enum ActionState {
    None,
    ToolStroke
}

/// Handlers for each state!
state_handlers = [];

/// Current state
state = ActionState.None;

/// How long we've been in the current state.
state_duration = 0;

/// Handler for idle/none state, ie no action is going on.
state_handlers[ActionState.None] = {
    
    enter: function() {
        
    },
    
    /// @param {Real} duration How long we've been in this state.
    step: function(duration) {
        
        // Start tool stroke.
        if (mouse_check_button(mb_left)) {
            return ActionState.ToolStroke;
        }        
        var mwheel = mouse_wheel_value();
        
        if (mwheel != 0) {
            
            camera.distance += mwheel * prefs.data.camera_zoom_speed * camera.distance;
            camera.distance = clamp(camera.distance, prefs.data.camera_distance_min, prefs.data.camera_distance_max);
    
            camera.update();            
        }
    
        if (mouse_check_button(mb_middle)) {
            camera.rotate(window_mouse_get_delta_x() * prefs.data.camera_rotation_speed);
        }

        if (mouse_check_button(mb_right)) {
        
            camera.pan(
                window_mouse_get_delta_x() * prefs.data.camera_pan_speed,
                window_mouse_get_delta_y() * prefs.data.camera_pan_speed
            );
        }   
    },
    
    leave: function() {
        
    }
    
};

/// Handler for using a tool!
state_handlers[ActionState.ToolStroke] = {
    
    enter: function() {
        
        var tool = tools[tool_current];
        
        tool_colour = make_color_hsv(irandom(255), 255, 255);
        tool.stroke_begin(mouse_worldspace);
        
    },
    
    /// @param {Real} duration How long we've been in this state.
    step: function(duration) {
    
        var tool = tools[tool_current];
    
        if (mouse_check_button_released(mb_left)) {
        
            tool.stroke_end(mouse_worldspace);
            return;
        }
        
        if (mouse_moved) {
            tool.stroke_update(mouse_worldspace);
        }
        
        var status = tool.update();
        
        if (status == ToolUpdateStatus.Commit) {
            return ActionState.None;
        }
    
    },
    
    /// Draw the tool's path as it is now.
    /// @param {Real} duration How long we've been in this state.
    draw: function(duration) {
                var tool = tools[tool_current];
        tool.draw(mouse_worldspace, tool_colour);
        
    },
    
    /// Draw the tool path to the canvas.
    leave: function() {
    
        var tool = tools[tool_current];
        tool.commit(canvas, tool_colour);
        
    }
    
};

/// List of tools!
tools = [
    new BrushTool()
];

/// Tool index currently selected.
tool_current = 0;

/// Current tool draw colour.
tool_colour = c_white;

/// Update the current application state.
/// This is basically the main loop!
state_update = function() {
    
    var state_handler = state_handlers[state];
    var new_state = state_handler.step(state_duration);

    if (new_state == undefined) {
        state_duration ++;
        return;
    }
    
    state_duration = 0;
    
    state_handler.leave();
    
    state = new_state;
    state_handler = state_handlers[state];
    
    state_handler.enter();
    
}

/// Process the given event name for the current state, or none.
/// @param {String} event
state_process = function(event) {
    
    var state_handler = state_handlers[state];
    
    if (!struct_exists(state_handler, event)) {
        return;
    }
    
    return state_handler[$ event](state_duration);
    
}
/// Initialize states (change their scope)
array_foreach(state_handlers, function(state_handler) {
    
    var keys = struct_get_names(state_handler);
    
    for (var i = 0; i < array_length(keys); i ++) {
    
        var key = keys[i];
        state_handler[$ key] = method(self, state_handler[$ key]);
    }
    
});
