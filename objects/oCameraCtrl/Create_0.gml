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
	
	enter: function() {
		self.rotateStartPos = mouse.pos[X];
		self.initialRotation = self.camera.rot;
	},
	
	step: function() {
		
		if (!mouse_check_button(mb_middle)) {
			return "none";
		}
		
		if (keyboard_check_pressed(vk_shift)) {
			self.rotateStartPos = mouse.pos[X];
			self.initialRotation = self.camera.rot;
		}
		
		if (!keyboard_check(vk_shift)) {
			return self.camera.rotateBy(mouse.delta[X] * prefs.data.camRotSpeed);
		}
		
		// Anchor to 8-directional rotation from the start position.
		var diff = (self.rotateStartPos - mouse.pos[X]) * prefs.data.camRotSpeed;
		var newRot = round((self.initialRotation + diff) * 4 / pi) / 4 * pi;
		
		self.camera.setRotation(newRot);
		
	},
	
	leave: function() {
		self.rotateStartPos = undefined;
		self.initialRotation = undefined;
	}
	
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
