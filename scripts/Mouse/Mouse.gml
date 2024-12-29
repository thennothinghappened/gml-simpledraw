
/// Handler for the application mouse.
function Mouse() constructor {
    
    /// The mouse position in pos.
    self.pos = [0, 0];
    
    /// The movement from the last pos positon of the mouse.
    self.delta = [0, 0];
    
    /// Whether the mouse has moved since last position.
    self.moved = false;    
    
    /// What amount the mouse scrolled this frame.
    self.wheel = 0;
    
    /// Update the mouse position.
    static update = function() {

        var pos_old = self.pos;
        
        self.pos = [
            window_mouse_get_x() - window.width / 2,
            window_mouse_get_y() - window.height / 2
        ];
        
		self.delta[X] = pos_old[X] - self.pos[X];
		self.delta[Y] = pos_old[Y] - self.pos[Y];
        self.moved = point_distance(0, 0, self.delta[X], self.delta[Y]) > 0;
        
        self.wheel = real(mouse_wheel_up()) - real(mouse_wheel_down());
        
    }
    
}

function __mouse_get() {
    static __mouse = new Mouse();
    return __mouse;
}

#macro mouse __mouse_get()
