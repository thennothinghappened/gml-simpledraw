/// Main controlling instance for gml-simpledraw.

/// "Pre-Initialise"
prefs.init();
window.init();

window.fpsForeground = prefs.data.frameRate;

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
stateHandlers = [];

/// Current state
state = ActionState.None;

/// How long we've been in the current state.
stateDuration = 0;

/// Handler for idle/none state, ie no action is going on.
stateHandlers[ActionState.None] = {
	
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
			
			self.camera.zoomBy(mouse.wheel * prefs.data.camZoomSpeed * camera.zoom);
			
			var mouseCanvasPosAfter = self.camera.fromScreen(
				mouse.pos[X],
				mouse.pos[Y],
				true
			);
			
			self.camera.pan(
				mouseCanvasPosBefore[X] - mouseCanvasPosAfter[X],
				mouseCanvasPosBefore[Y] - mouseCanvasPosAfter[Y]
			);
			
			return;
			
		}
	
		if (mouse_check_button(mb_middle)) {
			self.camera.rotateBy(mouse.delta[X] * prefs.data.camRotSpeed);
		}

		if (mouse_check_button(mb_right)) {
			
			if (keyboard_check(vk_control)) {
				self.camera.zoomBy(mouse.delta[Y] * prefs.data.camZoomSpeed * camera.zoom * -0.1);
				return;
			}
			
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
stateHandlers[ActionState.ToolStroke] = {
	
	enter: function() {
		
		ts.colour = make_color_hsv(irandom(255), 255, 255);
		tool.beginStroke(self.camera.fromScreen(mouse.pos[X], mouse.pos[Y]));
		
	},
	
	/// @param {Real} duration How long we've been in this state.
	step: function(duration) {
		
		if (mouse_check_button_released(mb_right)) {
			tool.endStroke(self.camera.fromScreen(mouse.pos[X], mouse.pos[Y]));
			return ActionState.None;
		}
		
		// Workaround for drawing tablet weirdly not sending the release event??
		if (!mouse_check_button(mb_left)) {
			tool.endStroke();
			return ActionState.None;
		}
		
		if (mouse.moved) {
			tool.updateStroke(self.camera.fromScreen(mouse.pos[X], mouse.pos[Y]));
		}
	},
	
	/// Draw the tool's path as it is now.
	/// @param {Real} duration How long we've been in this state.
	draw: function(duration) {
		tool.draw(self.camera.fromScreen(mouse.pos[X], mouse.pos[Y]));
	},
	
	/// Complete the stroke.
	leave: function() {
		
	}

};

/// List of tools!
tools = [
	new BrushTool(),
	new PixelTool(),
	new StampTool()
];

/// Current tool.
tool = tools[0];

/// Update the current application state.
/// This is basically the main loop!
stateUpdate = function() {
	
	var state_handler = stateHandlers[state];
	var new_state = state_handler.step(stateDuration);

	if (new_state == undefined) {
		stateDuration ++;
		return;
	}
	
	stateDuration = 0;
	
	state_handler.leave();
	
	state = new_state;
	state_handler = stateHandlers[state];
	
	state_handler.enter();
	
}

/// Process the given event name for the current state, or none.
/// @param {String} event
stateRunEvent = function(event) {
	
	var state_handler = stateHandlers[state];
	
	if (!struct_exists(state_handler, event)) {
		return;
	}
	
	return state_handler[$ event](stateDuration);
	
}

/// Initialize states (change their scope)
array_foreach(stateHandlers, function(state_handler) {
	
	var keys = struct_get_names(state_handler);
	
	for (var i = 0; i < array_length(keys); i ++) {
	
		var key = keys[i];
		state_handler[$ key] = method(self, state_handler[$ key]);
	}
	
});
