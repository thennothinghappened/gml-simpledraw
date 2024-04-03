
/// A brush tool, which simply draws the mouse path with a given width.
function BrushTool() : Tool() constructor {
    
    static name = "Brush";
    static desc = "Brush tool simply draws a stroke where the mouse has been.";
    static icon = sToolBrush;
    
    self.mouse_path = [];
    self.stroke_finished = false;
    
    /// Begin a stroke with this tool.
    /// @param {Array<Real>} mouse_canvas_pos Initial position of the mouse on the canvas.
    static stroke_begin = function(mouse_canvas_pos) {
        self.mouse_path = [mouse_canvas_pos];
    }
    
    /// Update stroke with a new mouse position, if it has moved.
    /// @param {Array<Real>} mouse_canvas_pos New position of the mouse on the canvas.
    static stroke_update = function(mouse_canvas_pos) {
        array_push(self.mouse_path, mouse_canvas_pos);
    }
    
    /// End a stroke with this tool.
    /// @param {Array<Real>} mouse_canvas_pos Final position of the mouse on the canvas.
    static stroke_end = function(mouse_canvas_pos) {
    
        array_push(self.mouse_path, mouse_canvas_pos);
        self.stroke_finished = true;
        
    }
    
    /// General update function for this tool.
    /// @returns {Enum.ToolUpdateStatus} What action should occur.
    static update = function() {
        
        if (!self.stroke_finished) {
            return ToolUpdateStatus.None;
        }
        
        self.stroke_finished = false;
        return ToolUpdateStatus.Commit;
        
    }
    
    /// Draw the tool action to display.
    /// @param {Array<Real>} mouse_canvas_pos Current position of the mouse on the canvas.
    /// @param {Real} colour Colour to draw with.
    static draw = function(mouse_canvas_pos, colour) {
        
        draw_set_color(colour);
        
        array_reduce(self.mouse_path, function(prev, curr) {
            
            draw_circle(prev[X], prev[Y], self.settings.width.value / 2, false);
            draw_line_width(prev[X], prev[Y], curr[X], curr[Y], self.settings.width.value);
            
            return curr;
            
        });
        
        draw_circle(mouse_canvas_pos[X], mouse_canvas_pos[Y], self.settings.width.value / 2, false);
        
        draw_set_color(c_white);
        
    }    
    
    /// Commit modifications to the canvas!
    /// For a pencil tool for example, this will be called after the end of a stroke.
    /// @param {Struct.Canvas} canvas Canvas to draw to.
    /// @param {Real} colour Colour to draw with.
    static commit = function(canvas, colour) {
        
        var this = self;
        
        canvas.draw_atomic(method({ this, colour }, function() {
            this.draw(array_last(this.mouse_path), colour);
        }));
        
    }
}
