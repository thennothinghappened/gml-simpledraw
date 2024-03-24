
/// Tool setting with a numerical value that can be incremented.
/// @param {String} name
/// @param {String} desc
/// @param {Real} def_value
/// @param {Real} min_value Minimum numerical value.
/// @param {Real} max_value Maximum numerical value.
function IncrementableToolSetting(
    name,
    desc,
    def_value,
    min_value,
    max_value
) : ToolSetting(name, desc, def_value) constructor {
    
    /// How much horizontal space this setting takes up in the GUI.
    static width = 50;
    
    /// How much vertical space this setting takes up in the GUI.
    static height = 20;
    
    self.min_value = min_value;
    self.max_value = max_value;
    
    /// Display the tool in the GUI.
    /// @param {Real} x X position to start drawing.
    /// @param {Real} y Y position to start drawing.
    static display = function(x, y) {
        
        var hoffset = x;
        var value_width = width - (height * 2);
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);  
              
        /// [-]
        draw_rectangle(hoffset, y, hoffset + height, y + height, true);
        draw_text(hoffset + height/2, y + height/2, "-");
        hoffset += height;
        
        /// Value
        draw_text(hoffset + (value_width / 2), y + (height / 2), string(self.value));
        hoffset += value_width;
        
        /// [+]
        draw_rectangle(hoffset, y, hoffset + height, y + height, true);
        draw_text(hoffset + height/2, y + height/2, "+");
        
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        
    }
    
    /// Handle this element being interacted with. Called repeatedly while mouse is over.
    /// @param {Array<Real>} local_mouse_pos Position of the mouse local to where this element is.
    static handle_interact = function(local_mouse_pos) {
        
    }    
}
