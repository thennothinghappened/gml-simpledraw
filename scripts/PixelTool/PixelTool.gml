
/// A pixel painting tool, which draws single pixels at the mouse position.
function PixelTool() : Tool() constructor {
	
	static name = "Pixel";
	static desc = "Draw single pixels at the mouse position.";
	static icon = sToolPencil;
	
	self.mouse_path = [];
	self.state = ToolStrokeState.None;
	
	/// Begin a stroke with this tool.
	/// @param {Array<Real>} mouse_canvas_pos Initial position of the mouse on the canvas.
	static beginStroke = function(mouse_canvas_pos) {

		self.mouse_path = [array_map(mouse_canvas_pos, floor)];
		self.state = ToolStrokeState.StrokeBegin;
	}
	
	/// Update stroke with a new mouse position, if it has moved.
	/// @param {Array<Real>} mouse_canvas_pos New position of the mouse on the canvas.
	static updateStroke = function(mouse_canvas_pos) {

		array_push(self.mouse_path, array_map(mouse_canvas_pos, floor));
		self.state = ToolStrokeState.Stroke;
	}
	
	/// End a stroke with this tool.
	static endStroke = function(mouse_canvas_pos) {
		self.state = ToolStrokeState.StrokeEnd;
	}
	
	/// General update function for this tool.
	/// @returns {Enum.ToolUpdateStatus} What action should occur.
	static update = function() {
		
		switch (self.state) {
			
			case ToolStrokeState.StrokeEnd: {
				return ToolUpdateStatus.Commit;
			}
			
			default: {
				return ToolUpdateStatus.None;
			}
			
		}
		
	}
	
	/// Draw the path of the brush on the canvas.
	/// @param {Array<Real>} mouse_canvas_pos Final position of the mouse on the canvas.
	static drawCanvasPath = function(mouse_canvas_pos) {

		if (array_length(self.mouse_path) == 0) {
			return;
		}
		
		draw_set_color(ts.colour);
		
		array_reduce(self.mouse_path, function(prev, curr) {
			
			draw_rectangle(prev[X] - real(IsGMRT), prev[Y] - real(IsGMRT), prev[X], prev[Y], false);
			draw_line_width(prev[X] - 0.5, prev[Y] - 0.5, curr[X] - 0.5, curr[Y] - 0.5, 1);
			
			return curr;
			
		});
		
		draw_point(mouse_canvas_pos[X], mouse_canvas_pos[Y]);
		draw_set_color(c_white);
	}
	
	/// Draw the tool action to display.
	/// @param {Array<Real>} mouse_canvas_pos Current position of the mouse on the canvas.
	static draw = function(mouse_canvas_pos) {

		var floored = array_map(mouse_canvas_pos, floor);

		if (self.state != ToolStrokeState.None) {
			self.drawCanvasPath(floored);
		}
		
		/// Draw the mouse overlay.
		gpu_set_blendmode(bm_subtract);
		draw_rectangle(floored[X] - real(IsGMRT), floored[Y] - real(IsGMRT), floored[X], floored[Y], true);
		gpu_set_blendmode(bm_normal);
		
	}
	
	/// Commit modifications to the canvas!
	/// For a pencil tool for example, this will be called after the end of a stroke.
	/// @param {Struct.Canvas} canvas Canvas to draw to.
	static commit = function(canvas) {
		
		canvas.drawAtomic(function() {
			self.drawCanvasPath(array_last(self.mouse_path));
		});
		
		self.mouse_path = [];
		
	}
}
