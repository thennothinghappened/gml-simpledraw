/// Main controlling instance for gml-simpledraw.

/// Current drawing canvas instance.
canvas = new Canvas(800, 600);
canvas.clear();

/// Camera instance to view the canvas!
camera = new Camera(0, [canvas.width / 2, canvas.height / 2], 400);

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

