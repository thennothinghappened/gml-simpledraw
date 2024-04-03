
/// Controller wrapper for the application window
/// @param {Real} _fps_foreground Framerate to run at while the application is focused.
/// @param {Real} _fps_background Framerate to run at while the application is in the background.
function AppWindow(
    _fps_foreground = 120,
    _fps_background = 5,
) : EventEmitter(["resize", "focuschange"]) constructor {
    
    fps_background = _fps_background;
    fps_foreground = _fps_foreground;
    
    focused = window_has_focus();
    
    width = window_get_width();
    height = window_get_height();
    
    aspect_ratio = width / height;
    
    static __window_get_width = function() {
        
        if (os_browser != browser_not_a_browser) {
            return browser_width;
        }
        
        if (os_type == os_android) {
            return display_get_width();
        }
        
        return window_get_width();
        
    }
        
    static __window_get_height = function() {
        
        if (os_browser != browser_not_a_browser) {
            return browser_height;
        }
        
        if (os_type == os_android) {
            return display_get_height();
        }
        
        return window_get_height();
        
    }
    
    /// Setup the application window!
    init = function() {
        
        // Set framerate on focus changed
        on("focuschange", function(params) {
            game_set_speed(params.focused ? fps_foreground : fps_background, gamespeed_fps);
        });
        
        // Resize app surface & GUI.
        on("resize", __on_resize);
        
        // On Android we want to be the full screen size at startup.
        if (os_type == os_android) {
            resize(__window_get_width(), __window_get_height());
        }
        
    }
    
    /// Update any window changes.
    update = function() {
        
        var old_focused = focused;
        focused = window_has_focus();
        
        if (focused != old_focused) {
            emit("focuschange", { focused });
        }
        
        var old_width = width;
        var old_height = height;
        
        width = __window_get_width();
        height = __window_get_height();
        
        if (width != old_width || height != old_height) {
            emit("resize", { width, height });
        }
    }
    
    /// Callback for when the window is resized.
    __on_resize = function(params) {
        
        aspect_ratio = params.width / params.height;
        
        // The browser requires we also resize the window itself
        if (os_browser != browser_not_a_browser) {
            
            window_set_size(params.width, params.height);
            logger.debug("AppWindow", "TODO: implement proper resizing on HTML5");
            
            return;
        }
        
        surface_resize(application_surface, max(params.width, 1), max(params.height, 1));
    }
    
    /// Resize the application window to a given width and height.
    /// @param {Real} _width
    /// @param {Real} _height
    resize = function(_width, _height) {
        
        width = _width;
        height = _height;
        
        window_set_size(width, height);
        
        emit("resize", { width, height });
    }
    
}

function __window_get() {
    
    static __window = new AppWindow();
    return __window;
    
}

#macro window __window_get()
