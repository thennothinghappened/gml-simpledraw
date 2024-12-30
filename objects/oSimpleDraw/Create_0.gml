/// Main controlling instance for gml-simpledraw.

/// "Pre-Initialise"
prefs.init();
window.init();

window.fpsForeground = prefs.data.frameRate;

/// Current drawing canvas instance.
canvas = new Canvas(800, 600);
canvas.clear();

/// Camera instance to view the canvas!
camera = instance_create_depth(canvas.width / 2, canvas.height / 2, 0, oCamera);

/// List of tools!
tools = [
	new BrushTool(),
	new PixelTool(),
	new StampTool()
];

/// Current tool.
tool = tools[0];

fsm = new FSM("none");

fsm.state("none", {
	
	/**
	 * @param {Real} duration How long we've been in this state.
	 * @returns {String|undefined}
	 */
	step: function(duration) {
		
		// Start tool stroke.
		if (mouse_check_button(mb_left)) {
			return "toolStroke";
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
	}
	
});

fsm.state("toolStroke", {
	
	enter: function() {
		ts.colour = make_color_hsv(irandom(255), 255, 255);
		tool.beginStroke(self.camera.fromScreen(mouse.pos[X], mouse.pos[Y]));
	},
	
	/**
	 * @param {Real} duration How long we've been in this state.
	 */
	step: function(duration) {
		
		if (!mouse_check_button(mb_left)) {
			tool.endStroke();
			return "none";
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

});
