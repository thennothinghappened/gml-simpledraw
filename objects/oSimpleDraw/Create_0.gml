/// Main controlling instance for gml-simpledraw.

/// "Pre-Initialise"
prefs.init();
window.init();

/// Current drawing canvas instance.
canvas = new Canvas(800, 600);
canvas.clear();

/// Camera instance to view the canvas!
camera = new Camera(canvas.width / 2, canvas.height / 2);

window.on("resize", function() {
	self.camera.recalculateProjMat();
});

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
	
	/**
	* @param {Real} duration How long we've been in this state.
	* @returns {Enum.ActionState|undefined}
	*/
	step: function(duration) {
		
		// Start tool stroke.
		if (mouse_check_button(mb_left)) {
			return ActionState.ToolStroke;
		}
		
		var status = tool.update();
		
		if (status == ToolUpdateStatus.Commit) {
			tool.commit(canvas);
		}
		
		if (mouse.wheel != 0) {
			
			if (keyboard_check(vk_shift)) {
				
				var tool_index = array_find_index(tools, function(tool) {
					return tool == self.tool;
				})
				
				tool_index = eucmod(tool_index + mouse.wheel, array_length(tools));
				tool = tools[tool_index];
				
				return;
			}
			
			var mouseCanvasPosBefore = self.camera.fromScreen(
				mouse.pos[X],
				mouse.pos[Y],
				true
			);
			
			camera.zoomBy(mouse.wheel * prefs.data.camZoomSpeed * camera.zoom);
			
			var mouseCanvasPosAfter = self.camera.fromScreen(
				mouse.pos[X],
				mouse.pos[Y],
				true
			);
			
			self.camera.pan(
				mouseCanvasPosBefore[X] - mouseCanvasPosAfter[X],
				mouseCanvasPosBefore[Y] - mouseCanvasPosAfter[Y]
			);
			
		}
	
		if (mouse_check_button(mb_middle)) {
			self.camera.rotateBy(mouse.delta[X] * prefs.data.camRotSpeed);
		}

		if (mouse_check_button(mb_right)) {
			var panDelta = self.camera.fromScreen(mouse.delta[X], mouse.delta[Y], true);
			self.camera.pan(panDelta[X], panDelta[Y]);
		}
	},

	/// Draw the tool's path as it is now.
	/// @param {Real} duration How long we've been in this state.
	draw: function(duration) {
		
		tool.draw(self.camera.fromScreen(mouse.pos[X], mouse.pos[Y]));
		
	},	
	leave: function() {
		
	}	
};

/// Handler for using a tool!
state_handlers[ActionState.ToolStroke] = {
	
	enter: function() {
		
		ts.colour = make_color_hsv(irandom(255), 255, 255);
		tool.stroke_begin(self.camera.fromScreen(mouse.pos[X], mouse.pos[Y]));
		
	},
	
	/// @param {Real} duration How long we've been in this state.
	step: function(duration) {
		
		if (mouse_check_button_released(mb_left)) {
			return ActionState.None;
		}
		
		if (mouse.moved) {
			tool.stroke_update(self.camera.fromScreen(mouse.pos[X], mouse.pos[Y]));
		}
	},
	
	/// Draw the tool's path as it is now.
	/// @param {Real} duration How long we've been in this state.
	draw: function(duration) {
		tool.draw(self.camera.fromScreen(mouse.pos[X], mouse.pos[Y]));
	},
	
	/// Complete the stroke.
	leave: function() {
		tool.stroke_end(self.camera.fromScreen(mouse.pos[X], mouse.pos[Y]));
	}

};

/// List of tools!
tools = [
	new BrushTool(),
	new PixelTool()
];

/// Current tool.
tool = tools[0];

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
