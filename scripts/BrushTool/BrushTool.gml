
/// A brush tool, which simply draws the mouse path with a given width.
function BrushTool() : Tool() constructor {
	
	static name = "Brush";
	static desc = "Draw a brush stroke with a width.";
	static icon = sToolBrush;
	
	self.mouse_path = [];
	self.state = ToolStrokeState.None;
	
	/// Begin a stroke with this tool.
	/// @param {Array<Real>} mouse_canvas_pos Initial position of the mouse on the canvas.
	static beginStroke = function(mouse_canvas_pos) {
		self.mouse_path = [mouse_canvas_pos];
		self.state = ToolStrokeState.StrokeBegin;
	}
	
	/// Update stroke with a new mouse position, if it has moved.
	/// @param {Array<Real>} mouse_canvas_pos New position of the mouse on the canvas.
	static updateStroke = function(mouse_canvas_pos) {
		array_push(self.mouse_path, mouse_canvas_pos);
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
			
			draw_circle(prev[X] - real(!IsGMRT), prev[Y] - real(!IsGMRT), ts.brush_width / 2, false);
			draw_line_width(prev[X] - real(!IsGMRT), prev[Y] - real(!IsGMRT), curr[X] - real(!IsGMRT), curr[Y] - real(!IsGMRT), ts.brush_width);
			
			return curr;
			
		});
		
		draw_circle(mouse_canvas_pos[X] - real(!IsGMRT), mouse_canvas_pos[Y] - real(!IsGMRT), ts.brush_width / 2, false);
		
		draw_set_color(c_white);
	}
	
	/// Draw the tool action to display.
	/// @param {Array<Real>} mouse_canvas_pos Current position of the mouse on the canvas.
	static draw = function(mouse_canvas_pos) {

		if (self.state != ToolStrokeState.None) {
			self.drawCanvasPath(mouse_canvas_pos);
		}
		
		/// Draw the mouse overlay.
		gpu_set_blendmode(bm_subtract);
		draw_circle(mouse_canvas_pos[X] - real(!IsGMRT), mouse_canvas_pos[Y] - real(!IsGMRT), ts.brush_width / 2, true);
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
