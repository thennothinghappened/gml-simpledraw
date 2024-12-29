
/**
 * Controller wrapper for the application window.
 */
function AppWindow() : EventEmitter(["resize", "focuschange"]) constructor {
	
	self.fps_background = 5;
	self.fps_foreground = game_get_speed(gamespeed_fps);
	
	self.focused = window_has_focus();
	self.width = window_get_width();
	self.height = window_get_height();
	self.aspect_ratio = width / height;
	
	/**
	 * @ignore
	 * @pure
	 */
	__window_get_width = function() {
		
		if (os_browser != browser_not_a_browser) {
			return browser_width;
		}
		
		if (os_type == os_android) {
			return display_get_width();
		}
		
		return window_get_width();
		
	}
	
	/**
	 * @ignore
	 * @pure
	 */
	__window_get_height = function() {
		
		if (os_browser != browser_not_a_browser) {
			return browser_height;
		}
		
		if (os_type == os_android) {
			return display_get_height();
		}
		
		return window_get_height();
		
	}
	
	/**
	 * Setup the application window!
	 */
	init = function() {
		
		// Set framerate on focus changed
		self.on("focuschange", function(params) {
			game_set_speed(params.focused ? fps_foreground : fps_background, gamespeed_fps);
		});
		
		// Resize app surface & GUI.
		self.on("resize", self.__on_resize);
		
		// On Android we want to be the full screen size at startup.
		if (os_type == os_android) {
			self.resize(self.__window_get_width(), self.__window_get_height());
		}
		
	}
	
	/**
	 * Update any window changes.
	 */
	update = function() {
		
		var old_focused = self.focused;
		self.focused = window_has_focus();
		
		if (self.focused != old_focused) {
			emit("focuschange", { focused });
		}
		
		var old_width = self.width;
		var old_height = self.height;
		
		self.width = self.__window_get_width();
		self.height = self.__window_get_height();
		
		if (self.width != old_width || self.height != old_height) {
			self.emit("resize", { width, height });
		}
	}
	
	/**
	 * Callback for when the window is resized.
	 * 
	 * @param {Struct} params
	 */
	__on_resize = function(params) {
		
		self.aspect_ratio = params.width / params.height;
		
		// The browser requires we also resize the window itself
		if (os_browser != browser_not_a_browser) {
			
			window_set_size(params.width, params.height);
			logger.debug("AppWindow", "TODO: implement proper resizing on HTML5");
			
			return;
		}
		
		surface_resize(application_surface, max(params.width, 1), max(params.height, 1));
		
	}
	
	/**
	 * Resize the application window to a given width and height.
	 * 
	 * @param {Real} width
	 * @param {Real} height
	 */
	resize = function(width, height) {
		
		self.width = width;
		self.height = height;
		
		window_set_size(width, height);
		
		self.emit("resize", { width, height });
	}
	
}

function __window_get() {
	static inst = new AppWindow();
	return inst;
}

#macro window __window_get()


