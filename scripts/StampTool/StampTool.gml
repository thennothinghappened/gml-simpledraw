
/**
 * The stamp tool lets you import images and stamp them onto the page!
 */
function StampTool() : Tool() constructor {
	
	static name = "Stamp";
	static desc = "Import images and stamp them onto the page!";
	static icon = sToolBrush;
	
	self.state = ToolStrokeState.None;
	self.image = undefined;
	
	/// Begin a stroke with this tool.
	/// @param {Array<Real>} mouse_canvas_pos Initial position of the mouse on the canvas.
	static stroke_begin = function(mouse_canvas_pos) {
		
		self.position = mouse_canvas_pos;
		self.rotation = 0;
		
		if (sprite_exists(self.image)) {
			self.state = ToolStrokeState.StrokeBegin;
			return;
		}
		
		var url = get_open_filename("*.png", "");
					
		if (string_length(url) == 0) {
			return;
		}
		
		self.image = sprite_add(url, 0, false, false, 0, 0);
		
		if (!sprite_exists(self.image)) {
			return;
		}
		
		sprite_set_offset(self.image, sprite_get_width(self.image) / 2, sprite_get_height(self.image) / 2);
		
	}
	
	/// Update stroke with a new mouse position, if it has moved.
	/// @param {Array<Real>} mouse_canvas_pos New position of the mouse on the canvas.
	static stroke_update = function(mouse_canvas_pos) {
		if (self.state != ToolStrokeState.None) {
			self.rotation = toRadians(point_direction(self.position[X], self.position[Y], mouse_canvas_pos[X], mouse_canvas_pos[Y]));
			self.state = ToolStrokeState.Stroke;
		}
	}
	
	/// End a stroke with this tool.
	/// @param {Array<Real>|undefined} mouse_canvas_pos Final position of the mouse on the canvas.
	static stroke_end = function(mouse_canvas_pos) {
		if (self.state != ToolStrokeState.None) {
			self.state = ToolStrokeState.StrokeEnd;
		}
	}
	
	/// General update function for this tool.
	/// @returns {Enum.ToolUpdateStatus} What action should occur.
	static update = function() {
		
		switch (self.state) {
			
			case ToolStrokeState.StrokeEnd: {
				self.state = ToolStrokeState.None;
				return ToolUpdateStatus.Commit;
			}
			
			default: {
				return ToolUpdateStatus.None;
			}
			
		}
		
	}
	
	/// Draw the tool action to display.
	/// @param {Array<Real>} mouse_canvas_pos Current position of the mouse on the canvas.
	static draw = function(mouse_canvas_pos) {
		
		var drawPos = mouse_canvas_pos;
		
		if (self.state != ToolStrokeState.None) {
			drawPos = self.position;
		}
		
		if (sprite_exists(self.image)) {
			draw_sprite_ext(self.image, 0, drawPos[X], drawPos[Y], 1, 1, toDegrees(self.rotation), c_white, 1);
		}
		
	}
	
	/// Commit modifications to the canvas!
	/// For a pencil tool for example, this will be called after the end of a stroke.
	/// @param {Struct.Canvas} canvas Canvas to draw to.
	static commit = function(canvas) {
		
		canvas.draw_atomic(function() {
			self.draw(self.position);
		});
		
		sprite_delete(self.image);
		
	}
}
