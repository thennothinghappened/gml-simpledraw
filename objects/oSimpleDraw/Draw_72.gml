
var ray = screen_to_world(window_mouse_get_x(), window_mouse_get_y(), camera.view_mat, camera.proj_mat);

mouse_worldspace = [
    ray[X + 3] + ray[X] * camera.distance,
    ray[Y + 3] + ray[Y] * camera.distance 
];

camera.apply();
