
/// A setting for a given tool that can be modified via GUI.
/// @param {String} name
/// @param {String} desc
/// @param {Any} def_value
function ToolSetting(name, desc, def_value) constructor {
    
    self.name = name;
    self.desc = desc;
    self.value = def_value;
    
    /// How much horizontal space this setting takes up in the GUI.
    static width = string_width("helllllllllooooooooooooooo");
    
    /// How much vertical space this setting takes up in the GUI.
    static height = string_height("hi!") * 3;
    
    /// Display the tool in the GUI.
    /// @param {Real} x X position to start drawing.
    /// @param {Real} y Y position to start drawing.
    static display = function(x, y) {
    
        var line1 = $"[unspecified display] Tool {self.name}";
        var line2 = $"Description: {self.desc}";
        var line3 = $"Value: {self.value}";
    
        var voffset = y;
        
        draw_rectangle(x, y, x + width, y + height, true);
        
        draw_text(x, voffset, line1);
        voffset += string_height(line1);
        
        draw_text(x, voffset, line2);
        voffset += string_height(line2);
        
        draw_text(x, voffset, line3);
        
    }
    
    /// Handle this element being interacted with. Called repeatedly while mouse is over.
    /// @param {Array<Real>} local_mouse_pos Position of the mouse local to where this element is.
    static handle_interact = function(local_mouse_pos) {        
    }
    
}
