
/// Handler for the application mouse.
function Mouse() constructor {
    
    /// The mouse position in screenspace.
    self.screenspace = [0, 0];
    
    /// Whether the mouse has moved since last position.
    self.screenspace_moved = false;    
    /// The mouse position in worldspace (canvas space).
    self.worldspace = [0, 0];
    
    /// Whether the mouse has moved in worldspace (can be from camera motion).
    self.worldspace_moved = false;
    
    /// What amount the mouse scrolled this frame.
    self.wheel = 0;
    
    /// Update the mouse position.
    /// @param {Struct.Camera} camera
    static update = function(camera) {

        var screenspace_old = array_clone(self.screenspace);
        
        self.screenspace = [
            window_mouse_get_x(),
            window_mouse_get_y()
        ];
        
        self.screenspace_moved = !array_equals(self.screenspace, screenspace_old);
        
        var ray = screen_to_world(self.screenspace[X], self.screenspace[Y], camera.view_mat, camera.proj_mat);
        
        var worldspace_old = array_clone(self.worldspace);
        
        self.worldspace = [
            ray[X + 3] + ray[X] * camera.distance - 1,
            ray[Y + 3] + ray[Y] * camera.distance - 1 
        ];
        
        self.worldspace_moved = !array_equals(self.worldspace, worldspace_old);
        
        self.wheel = mouse_wheel_value();
        
    }
    
}

function __mouse_get() {
    static __mouse = new Mouse();
    return __mouse;
}

#macro mouse __mouse_get()
