/**
 * @desc Camera controller state-machine thingy! Singleton that works in tandem with the "main game object".
 */

FEATHERHINT {
	self.camera = new Camera(self.x, self.y);
}

self.fsm = new FSM("none");

self.fsm.state("none", {
	
	step: function() {

		if (mouse_check_button(mb_middle)) {
			return "rotate";
		}
		
		if (mouse.wheel != 0) {
			return "zoom";
		}

		if (mouse_check_button(mb_right)) {
			
			if (keyboard_check(vk_control)) {
				return "rightClickZoom";
			}
			
			return "pan";
		}
		
	}
	
});

self.fsm.state("rotate", {
	
	step: function() {
		
		if (!mouse_check_button(mb_middle)) {
			return "none";
		}
		
		self.camera.rotateBy(mouse.delta[X] * prefs.data.camRotSpeed);
		
	},
	
});

self.fsm.state("zoom", {
	
	enter: function() {
		// Cheating a bit so we don't lose a singular scroll input.
		self.fsm.run("step");
	},
	
	step: function() {

		if (mouse.wheel == 0) {
			return "none";
		}

		var mouseCanvasPosBefore = self.camera.fromScreen(
			mouse.pos[X],
			mouse.pos[Y],
			true
		);
		
		self.camera.zoomBy(mouse.wheel * prefs.data.camZoomSpeed * self.camera.zoom);
		
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
	
});

self.fsm.state("rightClickZoom", {
	
	step: function() {

		if (!mouse_check_button(mb_right) || !keyboard_check(vk_control)) {
			return "none";
		}
		
		self.camera.zoomBy(mouse.delta[Y] * prefs.data.camZoomSpeed * self.camera.zoom * -0.1);
		
	}
	
});

self.fsm.state("pan", {
	
	step: function() {

		if (!mouse_check_button(mb_right)) {
			return "none";
		}

		var panDelta = self.camera.fromScreen(mouse.delta[X], mouse.delta[Y], true);
		self.camera.pan(panDelta[X], panDelta[Y]);
		
	}
	
});

window.on("resize", function() {
	self.camera.recalculateProjMat();
});
