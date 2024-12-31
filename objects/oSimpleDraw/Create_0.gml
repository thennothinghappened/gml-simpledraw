/// Main controlling instance for gml-simpledraw.

/// "Pre-Initialise"
prefs.init();
window.init();
window.fpsForeground = prefs.data.frameRate;

draw_set_font(fntMain);

font_enable_effects(fntMain, true, {
	outlineEnable: true,
	outlineDistance: 1,
	outlineColour: c_black
});

/// Current drawing canvas instance.
canvas = new Canvas(800, 600);
canvas.clear();

/// List of tools!
tools = [
	new BrushTool(),
	new PixelTool(),
	new StampTool()
];

/// Current tool.
tool = tools[0];

/**
 * Path to the current document on disk.
 */
self.filePath = undefined;

FEATHERHINT {
	self.filePath = "";
}

fsm = new FSM("none");

fsm.state("none", {
	
	/**
	 * @param {Real} duration How long we've been in this state.
	 * @returns {String|undefined}
	 */
	step: function(duration) {
		
		var status = tool.update();
		
		if (status == ToolUpdateStatus.Commit) {
			tool.commit(canvas);
		}
		
		if (keyboard_check(vk_control)) {
			
			if (keyboard_check_pressed(ord("S"))) {
				
				if (keyboard_check(vk_shift)) {
					self.filePath = undefined;
				}
				
				return "saveImage";
			}
			
			if (keyboard_check_pressed(ord("L"))) {
				return "loadImage";
			}
			
		}
		
		if (mouse_check_button(mb_left)) {
			return "toolStroke";
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
			
			if (keyboard_check(vk_control)) {
				ts.brushWidth = max(ts.brushWidth + mouse.wheel, 1);
				return;
			}
			
		}
		
		if (oCameraCtrl.fsm.run("step") != "none") {
			return "cameraMove";
		}
		
	},

	/// Draw the tool's path as it is now.
	/// @param {Real} duration How long we've been in this state.
	draw: function(duration) {
		tool.draw(oCameraCtrl.camera.fromScreen(mouse.pos[X], mouse.pos[Y]));
	}
	
});

fsm.state("cameraMove", {
	step: function() {
		if (oCameraCtrl.fsm.run("step") == "none") {
			return "none";
		}
	}
});

fsm.state("toolStroke", {
	
	enter: function() {
		ts.colour = make_color_hsv(irandom(255), 255, 255);
		tool.beginStroke(oCameraCtrl.camera.fromScreen(mouse.pos[X], mouse.pos[Y]));
	},
	
	/**
	 * @param {Real} duration How long we've been in this state.
	 */
	step: function(duration) {
		
		if (!mouse_check_button(mb_left)) {
			return "none";
		}
		
		if (mouse.moved) {
			tool.updateStroke(oCameraCtrl.camera.fromScreen(mouse.pos[X], mouse.pos[Y]));
		}
	},
	
	/// Draw the tool's path as it is now.
	/// @param {Real} duration How long we've been in this state.
	draw: function(duration) {
		tool.draw(oCameraCtrl.camera.fromScreen(mouse.pos[X], mouse.pos[Y]));
	},
	
	/// Complete the stroke.
	leave: function() {
		tool.endStroke();
	}

});

fsm.state("saveImage", {
	
	enter: function() {

		var path = "";
		
		if (is_undefined(self.filePath)) {
			
			path = get_save_filename(".png|*.png", $"{self.canvas.width}x{self.canvas.height} Canvas.png");
			
		} else if (filename_ext(self.filePath) != ".png") {
			
			show_message("GameMaker can only save PNGs!");
			path = get_save_filename(".png|*.png", filename_change_ext(self.filePath, ".png"));
			
		} else {
			
			path = self.filePath;
			
		}
		
		if (string_length(path) == 0) {
			return;
		}
		
		self.filePath = path;
		window_set_caption($"{game_display_name} - {self.filePath}");
		
		self.canvas.__ensureSurface();
		surface_save(self.canvas.__surf, self.filePath);
		
	},
	
	step: function() {
		return "none";
	}

});

fsm.state("loadImage", {
	
	enter: function() {
		
		self.filePath = get_open_filename("*.png", "");
		
		if (string_length(self.filePath) == 0) {
			return;
		}
		
		window_set_caption($"{game_display_name} - {self.filePath}");
		
		var image = sprite_add(self.filePath, 0, false, false, 0, 0);
		
		if (!sprite_exists(image)) {
			return;
		}
		
		canvas.resize(sprite_get_width(image), sprite_get_height(image));
		canvas.drawAtomic(method({ image }, function() {
			draw_sprite(image, 0, 0, 0);
		}));
		
		sprite_delete(image);
		
	},
	
	step: function() {
		return "none";
	},
	
	leave: function() {
		
	}

});

instance_create_depth(canvas.width / 2, canvas.height / 2, 0, oCameraCtrl);
