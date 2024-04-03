
/// Handler for the application mouse.
function Mouse() constructor {
    
    /// The mouse position in screenspace.
    self.screenspace = [0, 0];
    
    /// The movement from the last screenspace positon of the mouse.
    self.screenspace_delta = [0, 0];
    
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
            device_mouse_x(0),
            device_mouse_y(0)
        ];
        
        self.screenspace_delta = [
            self.screenspace[X] - screenspace_old[X],
            self.screenspace[Y] - screenspace_old[Y],
        ];
        
        self.screenspace_moved = !array_equals(self.screenspace, screenspace_old);
        
        var ray = screen_to_world(self.screenspace[X], self.screenspace[Y], camera.view_mat, camera.proj_mat);
        
        var worldspace_old = array_clone(self.worldspace);
        
        self.worldspace = [
            ray[X + 3] + ray[X] * camera.distance - real(!IS_GMRT),
            ray[Y + 3] + ray[Y] * camera.distance - real(!IS_GMRT) 
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
