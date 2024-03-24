
enum ToolUpdateStatus {
    None,
    Commit
}

/// Base class for a tool that can modify the canvas!
function Tool() constructor {
    
    static name = "[Base Tool]";
    static desc = "Base tool struct for other tool types. This tool doesn't do anything!";
    static icon = sMissing;
    
    /// Begin a stroke with this tool.
    /// @param {Array<Real>} mouse_canvas_pos Initial position of the mouse on the canvas.
    static stroke_begin = function(mouse_canvas_pos) {
    
    }
    
    /// Update stroke with a new mouse position, if it has moved.
    /// @param {Array<Real>} mouse_canvas_pos New position of the mouse on the canvas.
    static stroke_update = function(mouse_canvas_pos) {
        
    }
    
    /// End a stroke with this tool.
    /// @param {Array<Real>} mouse_canvas_pos Final position of the mouse on the canvas.
    static stroke_end = function(mouse_canvas_pos) {
    
    }
    
    /// General update function for this tool.
    /// @returns {Enum.ToolUpdateStatus} What action should occur.
    static update = function() {
    
    }
    
    /// Commit modifications to the canvas!
    /// For a pencil tool for example, this will be called after the end of a stroke.
    /// @param {Struct.Canvas} canvas
    static commit = function(canvas) {
        
    }
}
