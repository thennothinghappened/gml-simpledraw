
/// Camera struct for viewing the canvas!
/// @param {Real} rotation (Radians) Camera rotation angle
/// @param {Array<Real>} pan_value Camera pan position as `[x,y]`.
/// @param {Real} distance Camera `z` distance.
function Camera(rotation, pan_value, distance) constructor {

    self.rotation = rotation;
    self.pan_value = pan_value;
    self.distance = distance;
    
    /// @ignore
    /// Whether the camera needs to rebuild matricies.
    self.__update = true;
    
    /// @ignore
    self.__camera = camera_create();
    
    self.view_mat = matrix_build_identity();
    self.proj_mat = matrix_build_identity();    
    /// Mark the camera as needing to update matricies.
    static update = function() {
        self.__update = true;
    }
    
    /// Pan the camera position from window space.
    /// @param {Real} delta_x Amount in the x axis to move by.
    /// @param {Real} delta_y Amount in the y axis to move by.
    static pan = function(delta_x, delta_y) {
        
        var s = sin(-self.rotation);
        var c = cos(-self.rotation);
        
        var pan_x = delta_x * self.distance;
        var pan_y = delta_y * self.distance;
        
        self.pan_value[X] -= pan_x * c - pan_y * s;
        self.pan_value[Y] -= pan_x * s + pan_y * c;
        
        self.update();
        
    }    
    /// Rotate the camera.
    /// @param {Real} amount Amount to rotate by.
    static rotate = function(amount) {
        
        self.rotation += (amount / (2 * pi));
        self.update();
        
    }    
    /// Apply this camera.
    static apply = function() {
    
        if (self.__update) {
            
            self.view_mat = matrix_build_lookat(self.pan_value[X], self.pan_value[Y], -self.distance, self.pan_value[X], self.pan_value[Y], 0, sin(self.rotation), cos(self.rotation), 0);
            self.proj_mat = matrix_build_projection_perspective_fov(90, window_get_width()/window_get_height(), 1, 1000);            
            camera_set_view_mat(self.__camera, self.view_mat);
            camera_set_proj_mat(self.__camera, self.proj_mat)
            
            self.__update = false;
            
        }
    
        camera_apply(self.__camera);
    }
    
}