/// Main controlling instance for gml-simpledraw.

/// Current drawing canvas instance.
canvas = new Canvas(800, 600);
canvas.clear();

/// Camera to view & move canvas!
camera = camera_create();
camera_view_mat = matrix_build_identity();
camera_proj_mat = matrix_build_identity();

/// Distance from camera to the canvas.
camera_distance = 200;

/// Camera rotation (radians).
camera_rotation = 0;

/// Camera pan position.
camera_pan = [canvas.width / 2, canvas.height / 2];

/// How fast the camera rotates.
camera_rotation_speed = 0.01;

/// How fast the camera zooms.
camera_zoom_speed = 0.1;

/// How fast the camera pans.
camera_pan_speed = 0.005;

/// Maximum camera distance.
camera_distance_max = 1000;

/// Minimum camera distance.
camera_distance_min = 1;

/// Current mouse position in world/canvas space.
mouse_worldspace = [0, 0];

