camera_view_mat = matrix_build_lookat(camera_pan[X], camera_pan[Y], -camera_distance, camera_pan[X], camera_pan[Y], 0, sin(camera_rotation), cos(camera_rotation), 0);
camera_proj_mat = matrix_build_projection_perspective_fov(90, window_get_width()/window_get_height(), 1, 1000);

var ray = screen_to_world(window_mouse_get_x(), window_mouse_get_y(), camera_view_mat, camera_proj_mat);

mouse_worldspace = [
    ray[X + 3] + ray[X] * camera_distance,
    ray[Y + 3] + ray[Y] * camera_distance 
];

camera_set_view_mat(camera, camera_view_mat);
camera_set_proj_mat(camera, camera_proj_mat);

camera_apply(camera);

