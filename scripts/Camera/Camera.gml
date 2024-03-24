
/// Camera struct for viewing the canvas!
/// @param {Real} rotation (Radians) Camera rotation angle
/// @param {Array<Real>} pan Camera pan position as `[x,y]`.
/// @param {Real} distance Camera `z` distance.
function Camera(rotation, pan, distance) constructor {

    self.rotation = rotation;
    self.pan = pan;
    self.distance = distance;
    
    /// @ignore
    /// Whether the camera needs to rebuild matricies.
    self.__update = true;
    
    /// @ignore
    self.__camera = camera_create();
    
    self.view_mat = matrix_build_identity();
    self.proj_mat = matrix_build_identity();    
    static update = function() {
        self.__update = true;
    }
    
    /// Apply this camera.
    static apply = function() {
    
        if (self.__update) {
            
            self.view_mat = matrix_build_lookat(self.pan[X], self.pan[Y], -self.distance, self.pan[X], self.pan[Y], 0, sin(self.rotation), cos(self.rotation), 0);
            self.proj_mat = matrix_build_projection_perspective_fov(90, window_get_width()/window_get_height(), 1, 1000);            
            camera_set_view_mat(self.__camera, self.view_mat);
            camera_set_proj_mat(self.__camera, self.proj_mat)
            
            self.__update = false;
            
        }
    
        camera_apply(self.__camera);
    }
    
}