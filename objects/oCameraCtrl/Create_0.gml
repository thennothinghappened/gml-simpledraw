/**
 * @desc Camera controller state-machine thingy! Singleton that works in tandem with the "main game object".
 */

enum CameraState {
	None,
	Rotate,
	Zoom,
	MiddleClickZoom,
	Pan
}

FEATHERHINT self.prefsData = new PrefsData();

self.camera = new Camera(self.x, self.y, self.prefsData.camZoomMin, self.prefsData.camZoomMax);
self.fsm = new FSM(CameraState.None);

self.fsm.state(CameraState.None, {
	
	step: function() {
		
		if (Mouse.wheel != 0) {
			return CameraState.Zoom;
		}

		if (mouse_check_button(mb_middle)) {
			return CameraState.Pan;
		}
		
	}
	
});

self.fsm.state(CameraState.Rotate, {
	
	enter: ident(function() {
		self.rotateStartPos = Mouse.x;
		self.initialRotation = self.camera.rot;
	}),
	
	step: ident(function() {
		
		if (!mouse_check_button(mb_middle) || !keyboard_check(vk_shift)) {
			return CameraState.None;
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
		
	}),
	
	leave: ident(function() {
		self.rotateStartPos = undefined;
		self.initialRotation = undefined;
	})
	
});

self.fsm.state(CameraState.Zoom, {
	
	enter: ident(function() {
		// Cheating a bit so we don't lose a singular scroll input.
		self.fsm.run("step");
	}),
	
	step: ident(function() {

		if (Mouse.wheel == 0) {
			return CameraState.None;
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
		
	})
	
});

self.fsm.state(CameraState.MiddleClickZoom, {
	
	step: ident(function() {

		if (!mouse_check_button(mb_middle) || !keyboard_check(vk_control)) {
			return CameraState.None;
		}
		
		self.camera.zoomBy(Mouse.deltaX * self.prefsData.camZoomSpeed * self.camera.zoom * -0.1);
		
	})
	
});

self.fsm.state(CameraState.Pan, {
	
	step: ident(function() {

		if (!mouse_check_button(mb_middle)) {
			return CameraState.None;
		}
		
		if (keyboard_check(vk_shift)) {
			return CameraState.Rotate;
		}
		
		if (keyboard_check(vk_control)) {
			return CameraState.MiddleClickZoom;
		}
		
		var panDelta = self.camera.fromScreen(Mouse.deltaX, Mouse.deltaY, true);
		self.camera.pan(panDelta[X], panDelta[Y]);
		
	})
	
});

window.on("resize", function() {
	self.camera.recalculateProjMat();
});
