
enum CanvasAnchorHorizontal {
	Left,
	Centre,
	Right
}

enum CanvasAnchorVertical {
	Top,
	Middle,
	Bottom
}

/// A "safe" surface that can be drawn to.
/// @param {Real} width
/// @param {Real} height
function Canvas(width, height) constructor {
	
	self.width = width;
	self.height = height;
	
	/// @ignore
	self.__surf = surface_create(width, height);
	
	/// @ignore
	self.__buf = buffer_create(surface_get_buffersize(width, height), buffer_fixed, 1);
	
	/// Resize the canvas!
	/// @param {Real} width
	/// @param {Real} height
	/// @param {Enum.CanvasAnchorHorizontal} [anchor_horizontal]
	/// @param {Enum.CanvasAnchorVertical} [anchor_vertical]
	static resize = function(
		width,
		height,
		anchor_horizontal = CanvasAnchorHorizontal.Left,
		anchor_vertical = CanvasAnchorVertical.Top 
	) {
		
		var surf_temp = surface_create(width, height);
		
		// TODO: Respect anchor points!
		
		surface_set_target(surf_temp);
		
			self.__ensureSurface();
			draw_surface(self.__surf, 0, 0);
		
		surface_reset_target();
		
		surface_free(self.__surf);
		self.__surf = surf_temp;
		self.width = width;
		self.height = height;
		
		buffer_resize(self.__buf, surface_get_buffersize(width, height));
		self.__saveSurface();
		
	}
	
	/// Clear the canvas!
	static clear = function() {
	
		self.drawAtomic(function() {
			draw_clear_alpha(c_black, 0);
		});
		
	}
	
	/**
	 * Draw on the surface & immediately save, takes in a method to run for the surface.
	 * 
	 * @param {Function} block
	 * @param {Bool} [blend] Whether alpha-blending should be used. If enabled, we are drawing atop the canvas, not replacing.
	 */
	static drawAtomic = function(block, blend = true) {
		
		var oldBlendMode = gpu_get_blendmode_ext_sepalpha();
		
		self.__ensureSurface();
		
		gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_one);
			surface_drawto(self.__surf, block);
		gpu_set_blendmode_ext_sepalpha(oldBlendMode);
		
		self.__saveSurface();
		
	}
	
	/// Destroy & clean up this canvas instance.
	static destroy = function() {
		
		if (surface_exists(self.__surf)) {
			surface_free(self.__surf);
		}
		
		buffer_delete(self.__buf);
	}
	
	/// @ignore
	/// Ensure the surface exists, or recreate from buffer.
	static __ensureSurface = function() {
		
		if (surface_exists(self.__surf)) {
			return;
		}
		
		self.__surf = surface_create(self.width, self.height);
		buffer_set_surface(self.__buf, self.__surf, 0);
		
	}
	
	/// @ignore
	/// Save surface to the buffer.
	static __saveSurface = function() {
		buffer_get_surface(self.__buf, self.__surf, 0);
	}
	
}
