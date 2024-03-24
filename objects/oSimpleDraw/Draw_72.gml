
var ray = screen_to_world(window_mouse_get_x(), window_mouse_get_y(), camera.view_mat, camera.proj_mat);

var mouse_worldspace_old = mouse_worldspace;
mouse_moved = false;

mouse_worldspace = [
    ray[X + 3] + ray[X] * camera.distance,
    ray[Y + 3] + ray[Y] * camera.distance 
];

if (mouse_worldspace[X] != mouse_worldspace_old[X] || mouse_worldspace[Y] != mouse_worldspace_old[Y]) {
    mouse_moved = true;
}

camera.apply();
