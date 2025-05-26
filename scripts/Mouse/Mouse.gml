
/**
 * Mouse input singleton.
 */
function MouseSingleton() constructor {
	
	self.x = 0;
	self.y = 0;
	
	self.deltaX = 0;
	self.deltaY = 0;
	
	/// Whether the mouse has moved since last position.
	self.moved = false;	
	
	/// What amount the mouse scrolled this frame.
	self.wheel = 0;
	
	/**
	 * Update the mouse position.
	 */
	static update = function() {

		var oldX = self.x;
		var oldY = self.y;
		
		self.x = window_mouse_get_x() - (window.width / 2);
		self.y = window_mouse_get_y() - (window.height / 2);
		
		self.deltaX = oldX - self.x;
		self.deltaY = oldY - self.y;
		self.moved = (self.deltaX != 0) || (self.deltaY != 0);
		
		self.wheel = real(mouse_wheel_up()) - real(mouse_wheel_down());
		
	}
	
}

function __mouse_get() {
	static __mouse = new MouseSingleton();
	return __mouse;
}

#macro Mouse __mouse_get()
