
function Preferences() constructor {
    
    static filename = "preferences.json";
    
    /// Preferences data.
    self.data = {
        
    };
    
    /// Attempt to load the preferences file.
    /// @returns {Struct.Err|undefined}
    static load = function() {
        
        if (!file_exists(filename)) {
            
        }
        
    }

    static save = function() {
        
    }
    
}
