
/// A brush tool, which simply draws the mouse path with a given width.
function BrushTool() : Tool() constructor {
    
    static name = "Brush";
    static desc = "Brush tool simply draws a stroke where the mouse has been.";
    static icon = sToolBrush;
    
    self.mouse_path = [];
    self.state = ToolStrokeState.None;
    
    /// Begin a stroke with this tool.
    /// @param {Array<Real>} mouse_canvas_pos Initial position of the mouse on the canvas.
    static stroke_begin = function(mouse_canvas_pos) {
        self.mouse_path = [mouse_canvas_pos];
        self.state = ToolStrokeState.StrokeBegin;
    }
    
    /// Update stroke with a new mouse position, if it has moved.
    /// @param {Array<Real>} mouse_canvas_pos New position of the mouse on the canvas.
    static stroke_update = function(mouse_canvas_pos) {
        array_push(self.mouse_path, mouse_canvas_pos);
        self.state = ToolStrokeState.Stroke;
    }
    
    /// End a stroke with this tool.
    /// @param {Array<Real>} mouse_canvas_pos Final position of the mouse on the canvas.
    static stroke_end = function(mouse_canvas_pos) {
    
        array_push(self.mouse_path, mouse_canvas_pos);
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
    static draw_canvas_path = function(mouse_canvas_pos) {
        if (array_length(self.mouse_path) == 0) {
            return;
        }
        
        draw_set_color(ts.colour);
        
        array_reduce(self.mouse_path, function(prev, curr) {
            
            draw_circle(prev[X], prev[Y], ts.brush_width / 2, false);
            draw_line_width(prev[X], prev[Y], curr[X], curr[Y], ts.brush_width);
            
            return curr;
            
        });
        
        draw_circle(mouse_canvas_pos[X], mouse_canvas_pos[Y], ts.brush_width / 2, false);
        
        draw_set_color(c_white);        
    }
    
    /// Draw the tool action to display.
    /// @param {Array<Real>} mouse_canvas_pos Current position of the mouse on the canvas.
    static draw = function(mouse_canvas_pos) {

        if (self.state != ToolStrokeState.None) {
            self.draw_canvas_path(mouse_canvas_pos);
        }
        
        /// Draw the mouse overlay.
        gpu_set_blendmode(bm_subtract);
        draw_circle(mouse_canvas_pos[X], mouse_canvas_pos[Y], ts.brush_width / 2, true);
        gpu_set_blendmode(bm_normal);
        
    }
    
    /// Commit modifications to the canvas!
    /// For a pencil tool for example, this will be called after the end of a stroke.
    /// @param {Struct.Canvas} canvas Canvas to draw to.
    static commit = function(canvas) {
        
        canvas.draw_atomic(function() {
            gpu_set_blendmode(ts.blendmode);
            self.draw_canvas_path(array_last(self.mouse_path));
            gpu_set_blendmode(bm_normal);
        });
        
        self.mouse_path = [];
        
    }
}