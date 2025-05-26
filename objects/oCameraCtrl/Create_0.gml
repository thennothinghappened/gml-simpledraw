/**
 * @desc Camera controller state-machine thingy! Singleton that works in tandem with the "main game object".
 */

FEATHERHINT self.prefsData = new PrefsData();

self.camera = new Camera(self.x, self.y, self.prefsData.camZoomMin, self.prefsData.camZoomMax);
self.fsm = new FSM("none");

self.fsm.state("none", {
	
	step: function() {
		
		if (Mouse.wheel != 0) {
			return "zoom";
		}

		if (mouse_check_button(mb_middle)) {
			return "pan";
		}
		
	}
	
});

self.fsm.state("rotate", {
	
	enter: function() {
		self.rotateStartPos = Mouse.x;
		self.initialRotation = self.camera.rot;
	},
	
	step: function() {
		
		if (!mouse_check_button(mb_middle) || !keyboard_check(vk_shift)) {
			return "none";
		}
		
		if (keyboard_check_pressed(vk_alt)) {
			self.rotateStartPos = Mouse.x;
			self.initialRotation = self.camera.rot;
		}
		
		if (!keyboard_check(vk_alt)) {
			return self.camera.rotateBy(Mouse.deltaX * self.prefsData.camRotSpeed);
		}
		
		// Anchor to 8-directional rotation from the start position.
		var diff = (self.rotateStartPos - Mouse.x) * self.prefsData.camRotSpeed;
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

		if (Mouse.wheel == 0) {
			return "none";
		}

		var mouseCanvasPosBefore = self.camera.fromScreen(
			Mouse.x,
			Mouse.y,
			true
		);
		
		self.camera.zoomBy(Mouse.wheel * self.prefsData.camZoomSpeed * self.camera.zoom);
		
		var mouseCanvasPosAfter = self.camera.fromScreen(
			Mouse.x,
			Mouse.y,
			true
		);
		
		self.camera.pan(
			mouseCanvasPosBefore[X] - mouseCanvasPosAfter[X],
			mouseCanvasPosBefore[Y] - mouseCanvasPosAfter[Y]
		);
		
	}
	
});

self.fsm.state("middleClickZoom", {
	
	step: function() {

		if (!mouse_check_button(mb_middle) || !keyboard_check(vk_control)) {
			return "none";
		}
		
		self.camera.zoomBy(Mouse.deltaX * self.prefsData.camZoomSpeed * self.camera.zoom * -0.1);
		
	}
	
});

self.fsm.state("pan", {
	
	step: function() {

		if (!mouse_check_button(mb_middle)) {
			return "none";
		}
		
		if (keyboard_check(vk_shift)) {
			return "rotate";
		}
		
		if (keyboard_check(vk_control)) {
			return "middleClickZoom";
		}
		
		var panDelta = self.camera.fromScreen(Mouse.deltaX, Mouse.deltaY, true);
		self.camera.pan(panDelta[X], panDelta[Y]);
		
	}
	
});

window.on("resize", function() {
	self.camera.recalculateProjMat();
});
