/// Main controlling instance for gml-simpledraw.

/// Preferences for the application.
prefs = new Preferences();

var prefs_load_result = prefs.load();

if (is_instanceof(prefs_load_result, Err)) {
    show_message($"Failed to load preferences, using defaults:\n{prefs_load_result}");
}

/// Current drawing canvas instance.
canvas = new Canvas(800, 600);
canvas.clear();

/// Camera instance to view the canvas!
camera = new Camera(0, [canvas.width / 2, canvas.height / 2], 400);

/// Current mouse position in world/canvas space.
mouse_worldspace = [0, 0];

/// States!
enum State {
    
}
