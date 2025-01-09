
/**
 * Set of utilities for draw state.
 */
function Draw() constructor {
	
	/**
	 * Stack of draw colours.
	 * 
	 * @ignore
	 */
	static colourStack = ds_stack_create();
	
	/**
	 * Stack of surface targets.
	 * 
	 * @ignore
	 */
	static surfaceStack = ds_stack_create();
	
	/**
	 * Draw with the specified colour, appending to the colour stack.
	 * @param {Constant.Color} colour
	 */
	static pushColour = function(colour) {
		ds_stack_push(colourStack, draw_get_colour());
		draw_set_colour(colour);
	};
	
	/**
	 * Pop the last colour from the stack, re-setting it as the draw colour.
	 */
	static popColour = function() {
		draw_set_colour(ds_stack_pop(colourStack));
	};
	
	/**
	 * Push a new target surface, appending to the surface stack.
	 * @param {Id.Surface} surface
	 */
	static pushSurface = function(surface) {
		
		var previous = surface_get_target();
		
		if (surface_exists(previous)) {
			ds_stack_push(surfaceStack, surface_get_target());
			surface_reset_target();
		}
		
		surface_set_target(surface);
		
	};
	
	/**
	 * Pop the last surface from the stack, re-setting it as the target.
	 */
	static popSurface = function() {
		
		surface_reset_target();
		
		if (!ds_stack_empty(surfaceStack)) {
			surface_set_target(ds_stack_pop(surfaceStack));
		}
		
	};
	
}

new Draw();
