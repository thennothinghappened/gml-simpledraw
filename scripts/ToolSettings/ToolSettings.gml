
/// Global tool settings.
function ToolSettings() constructor {
    
    /// Current draw colour.
    self.colour = c_gray;    
    /// Current brush width.
    self.brush_width = 5;
    
}

function __tool_settings_get() {
    
    static __tool_settings = new ToolSettings();
    return __tool_settings;
}

#macro ts __tool_settings_get()
