/**
 * Wrapper for a camera that behaves how we're wanting for viewing the canvas.
 */
function Camera(x, y, zoom = 1, rot = pi / 2) constructor {
	
	self.camera = camera_create();
	
	self.x = x;
	self.y = y;
	self.zoom = zoom;
	self.rot = rot;
	
	self.recalculateViewMat();
	self.recalculateProjMat();
	
	/**
	 * Move to the given coordinates in worldspace.
	 * 
	 * @param {Real} x
	 * @param {Real} y
	 */
	static setPosition = function(x, y) {
		self.x = x;
		self.y = y;
		self.recalculateViewMat();
	};
	
	/**
	 * Pan by the given deltas in worldspace.
	 * 
	 * @param {Real} deltaX
	 * @param {Real} deltaY
	 */
	static pan = function(deltaX, deltaY) {
		self.setPosition(self.x + deltaX, self.y + deltaY);
	};
	
	/**
	 * Set the camera rotation.
	 * 
	 * @param {Real} radians
	 */
	static setRotation = function(radians) {
		self.rot = eucmod(radians, 2*pi);
		self.recalculateViewMat();
	};
	
	/**
	 * Rotate the camera by the given amount.
	 * 
	 * @param {Real} radians
	 */
	static rotateBy = function(radians) {
		self.setRotation(self.rot + radians);
	};
	
	/**
	 * Set the zoom amount.
	 * 
	 * @param {Real} zoom
	 */
	static setZoom = function(zoom) {
		self.zoom = clamp(zoom, PrefsData.camZoomMin, PrefsData.camZoomMax);
		self.recalculateProjMat();
	};
	
	/**
	 * Zoom in or out by the given amount.
	 * 
	 * @param {Real} amount
	 */
	static zoomBy = function(amount) {
		self.setZoom(self.zoom + amount);
	};
	
	/**
	 * Recalculate the view matrix for this camera.
	 */
	static recalculateViewMat = function() {
		camera_set_view_mat(self.camera, matrix_build_lookat(
			self.x, self.y, -1,
			self.x, self.y, 0,
			cos(self.rot), sin(self.rot), 0
		));
	};
	
	/**
	 * Recalculate the projection matrix for this camera.
	 */
	static recalculateProjMat = function() {
		camera_set_proj_mat(self.camera, matrix_build_projection_ortho(
			window.width / self.zoom, window.height / self.zoom,
			0.1, 10
		));
	};
	
	/**
	 * Convert the given screen-space position to a position on the canvas.
	 * 
	 * @param {Real} screenX X coordinate of the position on the screen.
	 * @param {Real} screenY Y coordinate of the position on the screen.
	 * @param {Bool} [relative] Whether the position should be relative to the camera.
	 * @returns {Array<Real>}
	 */
	static fromScreen = function(screenX, screenY, relative = false) {
		
		var worldX = (-screenX * sin(pi*2 - self.rot) + screenY * cos(self.rot)) / self.zoom;
		var worldY = (-screenX * cos(pi*2 - self.rot) + screenY * sin(self.rot)) / self.zoom;
		
		if (!relative) {
			worldX += self.x;
			worldY += self.y;
		}
		
		return [worldX, worldY];
		
	}
	
	/**
	 * Apply this camera.
	 */ 
	static apply = function() {
		camera_apply(self.camera);
	}
	
}
