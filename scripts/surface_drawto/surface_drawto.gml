
/// Draw to a given surface with the given function block.
/// @param {Id.Surface} surface
/// @param {Function} block
function surface_drawto(surface, block) {

	var prev_surf = surface_get_target();
	
	if (surface_exists(prev_surf)) {
		surface_reset_target();
	}
	
	surface_set_target(surface);
	
		block();
	
	surface_reset_target();
	
	if (surface_exists(prev_surf)) {
		surface_set_target(prev_surf);
	}	
}